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
    required this.initiallySelected,
    required this.refreshUI,
  }) {
    // Convertimos la lista inicial a un Set para mejor manejo de operaciones
    selectedSubjects = Set.from(initiallySelected);
  }

  /// Carga las asignaturas correspondientes al grado especificado
  /// Maneja estados de carga, éxito y error
  Future<void> loadSubjects() async {
    try {
      // 1. Obtenemos los datos del grado desde el servicio
      final degreeData = await subjectService.getDegreeData(
        degreeName: degreeName,
      );

      // Verificación de que el widget aún está montado antes de continuar
      if (!_isMounted()) return;

      // 2. Procesamos las asignaturas si existen
      if (degreeData['subjects'] != null) {
        List<Map<String, dynamic>> loadedSubjects = [];

        // 3. Para cada asignatura, obtenemos detalles adicionales
        for (var subject in degreeData['subjects']) {
          // Usamos code_ics para obtener los datos completos de la asignatura
          final subjectData = await subjectService.getSubjectData(
            codeSubject: subject['code_ics'],
          );
          
          // Nueva verificación de montaje
          if (!_isMounted()) return;
          
          // 4. Construimos el objeto de asignatura con los datos esenciales
          loadedSubjects.add({
            'name': subjectData['name'] ?? 'Sin nombre', // Nombre con valor por defecto
            'code': subject['code'], // Código identificador
          });
        }
        
        // Última verificación antes de actualizar el estado
        if (!_isMounted()) return;
        
        // 5. Actualizamos el estado
        subjects = loadedSubjects;
        isLoading = false;
        refreshUI(); // Notificamos a la UI para que se actualice
      } else {
        // Caso donde no hay asignaturas
        isLoading = false;
        refreshUI();
        showError('No se encontraron asignaturas');
      }
    } catch (e) {
      // Manejo de errores durante la carga
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
    refreshUI(); // Actualiza la UI
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