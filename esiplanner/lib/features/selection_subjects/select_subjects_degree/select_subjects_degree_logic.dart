import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/subject_service.dart';

/// Lógica para la selección de asignaturas de un grado específico.
/// Maneja:
/// - Carga de asignaturas del grado
/// - Selección/deselección de asignaturas
/// - Estado de carga
/// - Manejo de errores
class SelectSubjectsDegreeLogic {
  // Contexto necesario para acceder a características de Flutter como navegación, temas, etc.
  final BuildContext context;
  
  // Servicio para obtener datos de asignaturas y grados desde la fuente de datos
  final SubjectService subjectService;
  
  // Nombre del grado académico cuyas asignaturas se van a cargar
  final String degreeName;
  
  // Lista de códigos de asignaturas que deben venir preseleccionadas
  final List<String> initiallySelected;
  
  // Callback para notificar a la UI que debe actualizarse
  final VoidCallback refreshUI;

  // Indica si los datos están siendo cargados
  bool isLoading = true;
  
  // Lista de todas las asignaturas disponibles para este grado
  List<Map<String, dynamic>> subjects = [];
  
  // Conjunto de códigos de asignaturas seleccionadas por el usuario
  Set<String> selectedSubjects = {};

  /// Constructor que inicializa el estado con las asignaturas preseleccionadas
  SelectSubjectsDegreeLogic({
    required this.context,
    required this.subjectService,
    required this.degreeName,
    required this.refreshUI,
    required this.initiallySelected,
  }) {
    selectedSubjects = Set.from(initiallySelected);
  }

  /// Carga las asignaturas correspondientes al grado especificado
  /// Maneja estados de carga, éxito y error
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
      }
    } catch (e) {
      isLoading = false;
      refreshUI();
      showError('Error al cargar asignaturas: $e');
    }
  }

  /// Muestra un mensaje de error al usuario usando SnackBar
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  /// Alterna la selección de una asignatura
  /// [code]: Código de la asignatura a seleccionar/deseleccionar
  void toggleSelection(String code) {
    if (selectedSubjects.contains(code)) {
      selectedSubjects.remove(code); // Deselecciona
    } else {
      selectedSubjects.add(code); // Selecciona
    }
    refreshUI();
  }

  /// Verifica si el widget asociado aún está montado
  /// Previene errores al actualizar estado después de desmontar
  bool _isMounted() {
    return context.mounted;
  }

  /// Getter que determina si el tema actual es oscuro
  bool get isDarkMode {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.themeMode == ThemeMode.dark;
  }
}