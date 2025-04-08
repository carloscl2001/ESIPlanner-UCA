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

  void updateSelections(List<String> newSelections, String degree) {
    if (_isDisposed) return;
    
    selectedSubjects = Set.from(newSelections);
    for (var code in selectedSubjects) {
      if (!groupsSelected.containsKey(code)) {
        groupsSelected[code] = false;
      }
      if (!subjectNames.containsKey(code)) {
        subjectNames[code] = "Cargando...";
        subjectDegrees[code] = degree;
        loadSubjectName(code);
      }
    }
    subjectNames.removeWhere((key, _) => !selectedSubjects.contains(key));
    subjectDegrees.removeWhere((key, _) => !selectedSubjects.contains(key));
    groupsSelected.removeWhere((key, _) => !selectedSubjects.contains(key));
    refreshUI();
  }

  Future<void> loadSubjectName(String code) async {
    try {
      final data = await subjectService.getSubjectData(codeSubject: code);
      if (!_isDisposed) {
        subjectNames[code] = data['name'] ?? 'Sin nombre';
        refreshUI();
      }
    } catch (e) {
      if (!_isDisposed) {
        subjectNames[code] = 'Error al cargar';
        refreshUI();
      }
    }
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