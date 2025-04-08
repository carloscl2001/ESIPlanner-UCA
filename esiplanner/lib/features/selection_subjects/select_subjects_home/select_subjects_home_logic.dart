import 'package:esiplanner/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/subject_service.dart';
import '../../../services/profile_service.dart';
import '../../../providers/auth_provider.dart';

class SubjectSelectionHomeLogic {
  final BuildContext context;
  final SubjectService subjectService;
  final VoidCallback refreshUI;

  bool isLoading = true;
  List<String> availableDegrees = [];
  Set<String> selectedSubjects = {};
  Map<String, String> subjectNames = {};
  Map<String, String> subjectDegrees = {};
  Map<String, bool> groupsSelected = {};
  Map<String, Map<String, String>> selectedGroupsMap = {};

  SubjectSelectionHomeLogic({
    required this.context,
    required this.subjectService,
    required this.refreshUI,
  });

  Future<void> loadDegrees() async {
    try {
      final degrees = await subjectService.getAllDegrees();
      availableDegrees = degrees;
      isLoading = false;
      refreshUI();
    } catch (e) {
      isLoading = false;
      refreshUI();
      showError('Error al cargar grados: $e');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void updateSelections(List<String> newSelections, String degree) {
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
      subjectNames[code] = data['name'] ?? 'Sin nombre';
      refreshUI();
    } catch (e) {
      subjectNames[code] = 'Error al cargar';
      refreshUI();
    }
  }

  Future<void> confirmSelections() async {
    if (selectedSubjects.isEmpty) {
      showError('No hay asignaturas seleccionadas');
      return;
    }

    if (groupsSelected.values.any((selected) => !selected)) {
      showError('Algunas asignaturas no tienen grupos asignados');
      return;
    }

    final String? username = Provider.of<AuthProvider>(context, listen: false).username;
    if (username == null) return;

    try {
      List<Map<String, dynamic>> selectedSubjectsData = selectedGroupsMap.entries.map((entry) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al confirmar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void resetSelection() {
    selectedSubjects.clear();
    subjectNames.clear();
    subjectDegrees.clear();
    groupsSelected.clear();
    selectedGroupsMap.clear();
    refreshUI();
  }

  bool get isDarkMode {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.themeMode == ThemeMode.dark;
  }
}