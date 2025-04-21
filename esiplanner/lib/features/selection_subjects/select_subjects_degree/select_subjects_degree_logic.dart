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
  Map<String, String> codeToIcs = {}; // Mapeo de código original a code_ics

  SelectSubjectsDegreeLogic({
    required this.context,
    required this.subjectService,
    required this.degreeName,
    required this.refreshUI,
    required this.initiallySelected,
  }) {
    selectedSubjects = Set.from(initiallySelected);
  }

  Future<void> loadSubjects() async {
    try {
      // 1. Cargar el mapeo de códigos primero
      await _loadCodeMappings();

      // 2. Cargar los datos del grado
      final degreeData = await subjectService.getDegreeData(
        degreeName: degreeName,
      );

      if (!_isMounted()) return;

      if (degreeData['subjects'] != null) {
        List<Map<String, dynamic>> loadedSubjects = [];

        for (var subject in degreeData['subjects']) {
          final originalCode = subject['code'];
          final icsCode = codeToIcs[originalCode] ?? originalCode;
          
          // 3. Obtener datos usando el code_ics
          final subjectData = await subjectService.getSubjectData(
            codeSubject: icsCode, // Usamos el code_ics para la petición
          );
          
          if (!_isMounted()) return;
          
          loadedSubjects.add({
            'name': subjectData['name'] ?? 'Sin nombre',
            'code': originalCode, // Mostramos el código original
            'code_ics': icsCode, // Guardamos el ICS para referencias futuras
          });
        }
        
        if (!_isMounted()) return;
        
        subjects = loadedSubjects;
        isLoading = false;
        refreshUI();
      }
    } catch (e) {
      isLoading = false;
      refreshUI();
      showError('Error al cargar asignaturas: $e');
    }
  }

  Future<void> _loadCodeMappings() async {
    try {
      final mappings = await subjectService.getSubjectMapping();
      codeToIcs = {
        for (var mapping in mappings)
          mapping['code'].toString(): mapping['code_ics'].toString()
      };
    } catch (e) {
      debugPrint('Error cargando mapeo de códigos: $e');
      // Si falla, codeToIcs quedará vacío y usaremos los códigos originales
    }
  }

  // Método para obtener datos de una asignatura usando el code_ics correcto
  Future<Map<String, dynamic>> getSubjectDetails(String originalCode) async {
    final icsCode = codeToIcs[originalCode] ?? originalCode;
    return await subjectService.getSubjectData(codeSubject: icsCode);
  }

  // ... (resto de métodos permanecen igual)
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