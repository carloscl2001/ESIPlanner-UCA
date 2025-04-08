import 'package:flutter/material.dart';
import '../../../services/subject_service.dart';

class SelectGroupsLogic extends ChangeNotifier {
  final List<String> selectedSubjectCodes;
  final Map<String, String> subjectDegrees;
  
  late SubjectService subjectService;
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> subjects = [];
  Map<String, Map<String, String>> selectedGroups = {};

  SelectGroupsLogic({
    required this.selectedSubjectCodes,
    required this.subjectDegrees,
  }) {
    subjectService = SubjectService();
    _init();
  }

  Future<void> _init() async {
    await loadSubjectsData();
  }

  Future<void> loadSubjectsData() async {
    try {
      List<Map<String, dynamic>> loadedSubjects = [];
      
      for (var code in selectedSubjectCodes) {
        final subjectData = await subjectService.getSubjectData(codeSubject: code);
        loadedSubjects.add({
          'name': subjectData['name'],
          'code': code,
          'classes': subjectData['classes'] ?? [],
        });
      }

      subjects = loadedSubjects;
      // Inicializar selectedGroups para cada asignatura
      selectedGroups = {
        for (var subject in subjects) 
          subject['code']: {}
      };
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al cargar los datos: $e';
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  bool get allSelectionsComplete {
    for (var subject in subjects) {
      final groups = subject['classes'] as List;
      final requiredTypes = groups.map((g) => g['type'][0]).toSet();
      final selectedTypes = selectedGroups[subject['code']]?.keys.toSet() ?? {};

      if (requiredTypes.length != selectedTypes.length) {
        return false;
      }
    }
    return true;
  }

  void selectGroup(String subjectCode, String letter, String groupType) {
    selectedGroups[subjectCode]?[letter] = groupType;
    notifyListeners();
  }

  List<String> getMissingTypesForSubject(String subjectCode) {
    final subject = subjects.firstWhere((s) => s['code'] == subjectCode);
    final groups = subject['classes'] as List;
    final requiredTypes = groups.map((g) => g['type'][0]).toSet();
    final selectedTypes = selectedGroups[subjectCode]?.keys.toSet() ?? {};

    return requiredTypes.difference(selectedTypes).map((type) => getGroupLabel(type)).toList();
  }

  String getGroupLabel(String letter) {
    switch (letter) {
      case 'A': return 'Teoría';
      case 'B': return 'Problemas';
      case 'C': return 'Prácticas';
      case 'D': return 'Laboratorio';
      case 'X': return 'Teoría-Prácticas';
      case 'E': return 'Salidas de campo';
      default: return 'Grupo $letter';
    }
  }
}