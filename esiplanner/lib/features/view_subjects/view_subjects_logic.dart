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

  ViewSubjectsProfileLogic({
    required this.refreshUI,
    required this.showError,
  });

  Future<void> loadUserSubjects(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final username = authProvider.username;

      if (username == null || username.isEmpty) {
        errorMessage = "El nombre de usuario no está disponible";
        isLoading = false;
        refreshUI();
        return;
      }

      final response = await profileService.getUserSubjects(username: username);

      if (response['success'] == true) {
        List<dynamic> subjects = response['data'];

        userSubjects = await Future.wait(
          subjects.map((subject) async {
            final subjectDetails = await subjectService.getSubjectData(
              codeSubject: subject['code'],
            );

            return {
              'code': subject['code'],
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