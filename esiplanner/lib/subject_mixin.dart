import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../services/subject_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

mixin SubjectMixin<T extends StatefulWidget> on State<T> {
  late ProfileService _profileService;
  late SubjectService _subjectService;

  bool _isLoading = true;
  List<Map<String, dynamic>> _subjects = [];
  String _errorMessage = '';

  Future<void> loadSubjects(BuildContext context) async {
    _profileService = ProfileService();
    _subjectService = SubjectService();

    final username = Provider.of<AuthProvider>(context, listen: false).username;

    if (username == null) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Usuario no autenticado';
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final profileData = await _profileService.getProfileData(
        username: username,
      );
      final degree = profileData["degree"];
      final userSubjects = profileData["subjects"] ?? [];

      if (degree == null || userSubjects.isEmpty) {
        setState(() {
          _errorMessage =
              degree == null
                  ? 'No se encontró el grado en los datos del perfil'
                  : 'El usuario no tiene asignaturas';
          _isLoading = false;
        });
        return;
      }

      final updatedSubjects = await _fetchAndFilterSubjects(userSubjects);

      if (mounted) {
        setState(() {
          _subjects = updatedSubjects;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al obtener los datos: $error';
          _isLoading = false;
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAndFilterSubjects(
    List<dynamic> userSubjects,
  ) async {
    List<Map<String, dynamic>> updatedSubjects = [];

    for (var subject in userSubjects) {
      final subjectData = await _subjectService.getSubjectData(
        codeSubject: subject['code'],
      );
      final filteredClasses = _filterClasses(
        subjectData['classes'],
        subject['types'],
      );

      for (var classData in filteredClasses) {
        classData['events'].sort(
          (a, b) =>
              DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])),
        );
      }

      filteredClasses.sort(
        (a, b) => DateTime.parse(
          a['events'][0]['date'],
        ).compareTo(DateTime.parse(b['events'][0]['date'])),
      );

      updatedSubjects.add({
        'name': subjectData['name'] ?? subject['name'],
        'code': subject['code'],
        'classes': filteredClasses,
      });
    }

    return updatedSubjects;
  }

  List<dynamic> _filterClasses(
    List<dynamic>? classes,
    List<dynamic>? userTypes,
  ) {
    if (classes == null) return [];
    return classes.where((classData) {
      final classType = classData['type']?.toString();
      final types = (userTypes)?.cast<String>() ?? [];
      return classType != null && types.contains(classType);
    }).toList();
  }

 String _getGroupLabel(String letter) {
    switch (letter) {
      case 'A':
        return 'Clase de teoría';
      case 'B':
        return 'Clase de problemas';
      case 'C':
        return 'Clase de prácticas informáticas';
      case 'D':
        return 'Clase de laboratorio';
      case 'X':
        return 'Clase de teória-práctica';
      default:
        return 'Clase de teória-práctica';
    }
  }

  List<Map<String, dynamic>> get subjects => _subjects;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
}