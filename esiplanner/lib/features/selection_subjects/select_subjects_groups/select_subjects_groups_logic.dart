import 'package:flutter/material.dart';
import '../../../services/subject_service.dart';

/// Lógica para manejar la selección de grupos de asignaturas.
/// Extiende ChangeNotifier para permitir notificaciones de cambios a los listeners.
class SelectGroupsLogic extends ChangeNotifier {
  // Lista de códigos de asignaturas seleccionadas
  final List<String> selectedSubjectCodes;
  
  // Mapa que relaciona códigos de asignatura con nombres de grados
  final Map<String, String> subjectDegrees;
  
  // Servicio para obtener datos de asignaturas
  late SubjectService subjectService;
  
  // Bandera que indica si se están cargando los datos
  bool isLoading = true;
  
  // Mensaje de error en caso de fallo
  String errorMessage = '';
  
  // Lista de asignaturas con sus datos completos
  List<Map<String, dynamic>> subjects = [];
  
  // Mapa que almacena los grupos seleccionados por asignatura
  // Estructura: {codigo_asignatura: {letra_grupo: tipo_grupo}}
  Map<String, Map<String, String>> selectedGroups = {};

  /// Constructor que recibe:
  /// - selectedSubjectCodes: Lista de códigos de asignaturas seleccionadas
  /// - subjectDegrees: Mapa de relación código asignatura -> nombre grado
  SelectGroupsLogic({
    required this.selectedSubjectCodes,
    required this.subjectDegrees,
  }) {
    subjectService = SubjectService();
    _init(); // Inicialización asíncrona
  }

  /// Inicialización asíncrona
  Future<void> _init() async {
    await loadSubjectsData();
  }

  /// Carga los datos de las asignaturas seleccionadas
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

  /// Verifica si todas las selecciones requeridas están completas
  bool get allSelectionsComplete {
    for (var subject in subjects) {
      final groups = subject['classes'] as List;
      // Obtenemos los tipos de grupo requeridos (primera letra del tipo)
      final requiredTypes = groups.map((g) => g['type'][0]).toSet();
      // Obtenemos los tipos ya seleccionados
      final selectedTypes = selectedGroups[subject['code']]?.keys.toSet() ?? {};

      // Si faltan tipos requeridos
      if (requiredTypes.length != selectedTypes.length) {
        return false;
      }
    }
    return true;
  }

  /// Selecciona un grupo específico para una asignatura
  void selectGroup(String subjectCode, String letter, String groupType) {
    selectedGroups[subjectCode]?[letter] = groupType;
    notifyListeners(); // Notifica a los listeners del cambio
  }

  /// Obtiene los tipos de grupo que faltan por seleccionar para una asignatura
  List<String> getMissingTypesForSubject(String subjectCode) {
    // Buscamos la asignatura por su código
    final subject = subjects.firstWhere((s) => s['code'] == subjectCode);
    final groups = subject['classes'] as List;
    
    // Tipos requeridos y seleccionados
    final requiredTypes = groups.map((g) => g['type'][0]).toSet();
    final selectedTypes = selectedGroups[subjectCode]?.keys.toSet() ?? {};

    // Devolvemos los faltantes con sus etiquetas traducidas
    return requiredTypes.difference(selectedTypes)
        .map((type) => getGroupLabel(type))
        .toList();
  }

  /// Devuelve la etiqueta descriptiva para un tipo de grupo (por su letra)
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