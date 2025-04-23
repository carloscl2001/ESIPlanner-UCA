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
  Map<String, String> codeToIcs = {};

  SelectGroupsLogic({
    required this.selectedSubjectCodes,
    required this.subjectDegrees,
  }) {
    subjectService = SubjectService();
    _init();
  }

  Future<void> _init() async {
    await _loadCodeMappings();
    await loadSubjectsData();
  }

  Future<void> _loadCodeMappings() async {
    try {
      final mappings = await subjectService.getSubjectMapping();
      codeToIcs = {
        for (var mapping in mappings)
          mapping['code'].toString(): mapping['code_ics'].toString()
      };
    } catch (e) {
      debugPrint('Error loading code mappings: $e');
    }
  }

  Future<void> loadSubjectsData() async {
    try {
      List<Map<String, dynamic>> loadedSubjects = [];
      
      for (var originalCode in selectedSubjectCodes) {
        final icsCode = codeToIcs[originalCode] ?? originalCode;
        final subjectData = await subjectService.getSubjectData(codeSubject: icsCode);
        
        final classes = subjectData['classes'] ?? [];
        classes.sort((a, b) {
          final regExp = RegExp(r'([A-Z]+)(\d+)');
          final matchA = regExp.firstMatch(a['type'])!;
          final matchB = regExp.firstMatch(b['type'])!;

          final letterA = matchA.group(1)!;
          final letterB = matchB.group(1)!;
          final numberA = int.parse(matchA.group(2)!);
          final numberB = int.parse(matchB.group(2)!);

          if (letterA != letterB) {
            return letterA.compareTo(letterB);
          } else {
            return numberA.compareTo(numberB);
          }
        });
        
        loadedSubjects.add({
          'name': subjectData['name'],
          'code': originalCode,
          'code_ics': icsCode,
          'classes': classes,
        });
      }

      subjects = loadedSubjects;
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

  Future<Map<String, dynamic>> getSubjectDetails(String originalCode) async {
    final icsCode = codeToIcs[originalCode] ?? originalCode;
    return await subjectService.getSubjectData(codeSubject: icsCode);
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
    if (groupType.isEmpty) {
      selectedGroups[subjectCode]?.remove(letter);
    } else {
      selectedGroups[subjectCode]?[letter] = groupType;
    }
    notifyListeners();
  }

  List<String> getMissingTypesForSubject(String subjectCode) {
    final subject = subjects.firstWhere((s) => s['code'] == subjectCode);
    final groups = subject['classes'] as List;
    
    final requiredTypes = groups.map((g) => g['type'][0]).toSet();
    final selectedTypes = selectedGroups[subjectCode]?.keys.toSet() ?? {};

    return requiredTypes.difference(selectedTypes)
        .map((type) => getGroupLabel(type))
        .toList();
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