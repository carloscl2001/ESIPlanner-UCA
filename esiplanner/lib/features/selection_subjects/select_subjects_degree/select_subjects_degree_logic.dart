import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/subject_service.dart';

class SelectSubjectsDegreeLogic {
  final BuildContext context;
  final SubjectService subjectService;
  final String degreeName;
  final List<String> initiallySelected;
  final VoidCallback refreshUI;

  bool isLoading = true;
  List<Map<String, dynamic>> subjects = [];
  Set<String> selectedSubjects = {};

  SelectSubjectsDegreeLogic({
    required this.context,
    required this.subjectService,
    required this.degreeName,
    required this.initiallySelected,
    required this.refreshUI,
  }) {
    selectedSubjects = Set.from(initiallySelected);
  }

  Future<void> loadSubjects() async {
    try {
      final degreeData = await subjectService.getDegreeData(
        degreeName: degreeName,
      );

      if (!_isMounted()) return;

      if (degreeData['subjects'] != null) {
        List<Map<String, dynamic>> loadedSubjects = [];

        for (var subject in degreeData['subjects']) {
          final subjectData = await subjectService.getSubjectData(
            codeSubject: subject['code'],
          );
          
          if (!_isMounted()) return;
          
          loadedSubjects.add({
            'name': subjectData['name'] ?? 'Sin nombre',
            'code': subject['code'],
          });
        }
        
        if (!_isMounted()) return;
        
        subjects = loadedSubjects;
        isLoading = false;
        refreshUI();
      } else {
        isLoading = false;
        refreshUI();
        showError('No se encontraron asignaturas');
      }
    } catch (e) {
      isLoading = false;
      refreshUI();
      showError('Error al cargar asignaturas: $e');
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

  void toggleSelection(String code) {
    if (selectedSubjects.contains(code)) {
      selectedSubjects.remove(code);
    } else {
      selectedSubjects.add(code);
    }
    refreshUI();
  }

  bool _isMounted() {
    return context.mounted;
  }

  bool get isDarkMode {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.themeMode == ThemeMode.dark;
  }
}