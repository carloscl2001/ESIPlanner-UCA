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
  bool requireAllTypes = true;
  bool oneGroupPerType = false;

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

  void updateRestrictions(bool requireAll, bool onePerType, {bool forceClean = false}) {
    if ((onePerType && !oneGroupPerType) || forceClean) {
      _cleanMultipleSelections();
    }
    
    requireAllTypes = requireAll;
    oneGroupPerType = onePerType;
    notifyListeners();
  }

  void _cleanMultipleSelections() {
    for (final subjectCode in selectedGroups.keys) {
      final Map<String, String> cleanedSelections = {};
      final groupsByType = <String, List<String>>{};
      
      // Agrupar por tipo (C, D, etc.)
      selectedGroups[subjectCode]?.keys.forEach((groupType) {
        final letter = groupType[0];
        groupsByType.putIfAbsent(letter, () => []).add(groupType);
      });
      
      // Ordenar y conservar el primero de cada tipo
      groupsByType.forEach((letter, groups) {
        groups.sort(); // Orden alfabético (C1, C2, C3)
        cleanedSelections[groups.first] = groups.first;
      });
      
      selectedGroups[subjectCode] = cleanedSelections;
    }
    notifyListeners();
  }


  void selectGroup(String subjectCode, String groupTypeFull, String groupTypeToSet) {
    // groupTypeFull viene como "C1", "C2", etc.
    // La primera letra es el tipo (C)
    final letter = groupTypeFull[0];
    
    final currentSelections = Map<String, String>.from(selectedGroups[subjectCode] ?? {});

    if (oneGroupPerType) {
      // Modo restrictivo: solo un grupo por tipo
      if (groupTypeToSet.isNotEmpty) {
        // Eliminar cualquier selección previa del mismo tipo
        currentSelections.removeWhere((key, value) => key[0] == letter);
        // Añadir la nueva selección
        currentSelections[groupTypeFull] = groupTypeToSet;
      } else {
        // Deseleccionar
        currentSelections.remove(groupTypeFull);
      }
    } else {
      // Modo no restrictivo: permitir múltiples grupos del mismo tipo
      if (groupTypeToSet.isNotEmpty) {
        currentSelections[groupTypeFull] = groupTypeToSet;
      } else {
        currentSelections.remove(groupTypeFull);
      }
    }

    selectedGroups[subjectCode] = currentSelections;
    notifyListeners();
  }

  bool isGroupSelected(String subjectCode, String groupType) {
    return selectedGroups[subjectCode]?.containsKey(groupType) ?? false;
  }

  void toggleGroupSelection(String subjectCode, String groupType) {
    final currentSelections = Map<String, String>.from(
      selectedGroups[subjectCode] ?? {}
    );

    final isSelected = currentSelections.containsKey(groupType);
    final letter = groupType[0];

    if (isSelected) {
      currentSelections.remove(groupType);
    } else {
      if (oneGroupPerType) {
        currentSelections.removeWhere((key, _) => key[0] == letter);
      }
      currentSelections[groupType] = groupType;
    }

    selectedGroups[subjectCode] = currentSelections;
    notifyListeners();
  }

  bool get allSelectionsComplete {
    if (!requireAllTypes) return true;

    for (var subject in subjects) {
      final groups = subject['classes'] as List;
      final requiredTypes = groups.map((g) => g['type'][0]).toSet();
      final selectedTypes = selectedGroups[subject['code']]?.keys.map((k) => k[0]).toSet() ?? {};

      if (requiredTypes.difference(selectedTypes).isNotEmpty) {
        return false;
      }
    }
    return true;
  }

  List<String> getMissingTypesForSubject(String subjectCode) {
    final subject = subjects.firstWhere((s) => s['code'] == subjectCode);
    final groups = subject['classes'] as List;
    
    final requiredTypes = groups.map((g) => g['type'][0]).toSet();
    final selectedTypes = selectedGroups[subjectCode]?.keys.map((k) => k[0]).toSet() ?? {};

    return requiredTypes.difference(selectedTypes)
      .map((type) => getGroupLabel(type.toString())) // Convertimos a String
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