import 'package:esiplanner/providers/auth_provider.dart';
import 'package:esiplanner/services/profile_service.dart';
import 'package:esiplanner/services/subject_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewSubjectsProfileLogic {
  final VoidCallback refreshUI;
  final Function(String) showError;
  final ProfileService profileService = ProfileService();
  final SubjectService subjectService = SubjectService();

  bool isLoading = true;
  List<dynamic> userSubjects = [];
  String errorMessage = '';
  Map<String, String> subjectCodeMapping = {};

  ViewSubjectsProfileLogic({
    required this.refreshUI,
    required this.showError,
  });

  Map<String, String> _createSubjectMapping(List<Map<String, dynamic>> mappingList) {
    final mapping = <String, String>{};
    for (var item in mappingList) {
      final code = item['code']?.toString();
      final codeIcs = item['code_ics']?.toString();
      if (code != null && codeIcs != null) {
        mapping[code] = codeIcs;
      }
    }
    return mapping;
  }

  Future<void> loadUserSubjects(BuildContext context) async {
    try {
      isLoading = true;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final username = authProvider.username;

      if (username == null || username.isEmpty) {
        errorMessage = "El nombre de usuario no está disponible";
        isLoading = false;
        refreshUI();
        return;
      }

      // Obtener el mapeo de asignaturas primero
      final mappingList = await subjectService.getSubjectMapping();
      subjectCodeMapping = _createSubjectMapping(mappingList);

      final response = await profileService.getUserSubjects(username: username);

      if (response['success'] == true) {
        List<dynamic> subjects = response['data'];

        userSubjects = await Future.wait(
          subjects.map((subject) async {
            final code = subject['code'];
            
            // Usar el mapping para obtener el code_ics correspondiente
            final codeIcs = subjectCodeMapping[code] ?? code;
            
            final subjectDetails = await subjectService.getSubjectData(
              codeSubject: codeIcs,
            );

            return {
              'code': code,
              'code_ics': codeIcs,
              'name': subjectDetails.isNotEmpty && subjectDetails.containsKey('name') 
                  ? subjectDetails['name']
                  : 'Información no disponible',
              'types': subject['types'],
            };
          }).toList(),
        );
      } else {
        errorMessage = response['message'] ?? 'No se pudo obtener la información de las asignaturas';
      }
    } catch (e) {
      errorMessage = 'Error al cargar las asignaturas: $e';
    } finally {
      isLoading = false;
      refreshUI();
    }
  }
}