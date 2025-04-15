import 'dart:ui';

import 'package:esiplanner/services/subject_service.dart';
import 'package:esiplanner/services/profile_service.dart';
import 'package:esiplanner/providers/auth_provider.dart';

class SubjectSelectionHomeLogic {
  final VoidCallback refreshUI;
  final Function(String) showError;
  final SubjectService subjectService;
  final AuthProvider authProvider;
  bool _isDisposed = false;

  bool isLoading = true;
  List<String> availableDegrees = [];
  Set<String> selectedSubjects = {};
  Map<String, String> subjectNames = {};
  Map<String, String> subjectDegrees = {};
  Map<String, bool> groupsSelected = {};
  Map<String, Map<String, String>> selectedGroupsMap = {};
   // Añadimos un nuevo mapa para almacenar los code_ics
  Map<String, String> subjectIcsCodes = {};

  SubjectSelectionHomeLogic({
    required this.refreshUI,
    required this.showError,
    required this.subjectService,
    required this.authProvider,
  });

  Future<void> loadDegrees() async {
    try {
      final degrees = await subjectService.getAllDegrees();
      if (!_isDisposed) {
        availableDegrees = degrees;
        isLoading = false;
        refreshUI();
      }
    } catch (e) {
      if (!_isDisposed) {
        isLoading = false;
        refreshUI();
        showError('Error al cargar grados: $e');
      }
    }
  }

  // Modificamos updateSelections para cargar ambos códigos
  Future<void> updateSelections(Map<String, dynamic> selectionData) async {
    if (_isDisposed) return;
    
    final codes = List<String>.from(selectionData['codes'] ?? []);
    final codesIcs = List<String>.from(selectionData['codes_ics'] ?? []);
    final names = List<String>.from(selectionData['names'] ?? []);
    final degree = selectionData['degree'] as String;
    
    selectedSubjects = Set.from(codes);
    
    for (int i = 0; i < codes.length; i++) {
      final code = codes[i];
      final codeIcs = i < codesIcs.length ? codesIcs[i] : '';
      final name = i < names.length ? names[i] : 'Cargando...';
      
      if (!groupsSelected.containsKey(code)) {
        groupsSelected[code] = false;
      }
      
      subjectNames[code] = name;
      subjectDegrees[code] = degree;
      subjectIcsCodes[code] = codeIcs;
    }
    
    // Limpieza
    subjectNames.removeWhere((key, _) => !selectedSubjects.contains(key));
    subjectDegrees.removeWhere((key, _) => !selectedSubjects.contains(key));
    subjectIcsCodes.removeWhere((key, _) => !selectedSubjects.contains(key));
    groupsSelected.removeWhere((key, _) => !selectedSubjects.contains(key));
    
    refreshUI();
  }

  Future<void> confirmSelections() async {
    if (_isDisposed) return;
    
    if (selectedSubjects.isEmpty) {
      showError('No hay asignaturas seleccionadas');
      return;
    }

    if (groupsSelected.values.any((selected) => !selected)) {
      showError('Algunas asignaturas no tienen grupos asignados');
      return;
    }

    final username = authProvider.username;
    if (username == null) {
      showError('Usuario no autenticado');
      return;
    }

    try {
      final selectedSubjectsData = selectedGroupsMap.entries.map((entry) {
        return {
          'code': entry.key,
          'types': entry.value.values.toList(),
        };
      }).toList();

      await ProfileService().updateSubjects(
        username: username,
        subjects: selectedSubjectsData,
      );
    } catch (e) {
      if (!_isDisposed) {
        showError('Error al confirmar: ${e.toString()}');
      }
    }
  }

  void resetSelection() {
    if (_isDisposed) return;
    selectedSubjects.clear();
    subjectNames.clear();
    subjectDegrees.clear();
    groupsSelected.clear();
    selectedGroupsMap.clear();
    refreshUI();
  }

  void dispose() {
    _isDisposed = true;
  }
}