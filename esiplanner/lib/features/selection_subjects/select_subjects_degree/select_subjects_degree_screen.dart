import 'package:flutter/material.dart';
import '../../../services/subject_service.dart';
import 'select_subjects_degree_logic.dart';
import 'select_subjects_degree_widgets.dart';

/// Pantalla que muestra las asignaturas de un grado específico para su selección.
/// Permite:
/// - Visualizar la lista de asignaturas del grado
/// - Seleccionar/deseleccionar asignaturas
/// - Guardar la selección final
class DegreeSubjectsScreen extends StatefulWidget {
  final String degreeName;         // Nombre del grado académico
  final List<String> initiallySelected; // Lista de asignaturas preseleccionadas

  const DegreeSubjectsScreen({
    super.key,
    required this.degreeName,
    required this.initiallySelected,
  });

  @override
  State<DegreeSubjectsScreen> createState() => _DegreeSubjectsScreenState();
}

class _DegreeSubjectsScreenState extends State<DegreeSubjectsScreen> {
  late SelectSubjectsDegreeLogic logic; // Lógica de negocio de la pantalla

  @override
  void initState() {
    super.initState();
    // Inicialización de la lógica con:
    // - Contexto actual
    // - Instancia del servicio
    // - Nombre del grado (de los parámetros del widget)
    // - Asignaturas preseleccionadas (de los parámetros del widget)
    // - Función para refrescar la UI (setState)
    logic = SelectSubjectsDegreeLogic(
      context: context,
      subjectService: SubjectService(),
      degreeName: widget.degreeName,
      initiallySelected: widget.initiallySelected,
      refreshUI: () => setState(() {}),
    );
    // Carga inicial de las asignaturas
    logic.loadSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.degreeName), // Muestra el nombre del grado como título
        actions: [
          // Botón de guardar en la AppBar
          IconButton(
            icon: const Icon(Icons.save),
            // Al presionar, regresa a la pantalla anterior con la lista de seleccionados
            onPressed: () {
                final result = {
                  'codes': logic.selectedSubjects.keys.toList(),
                  'codes_ics': logic.selectedSubjects.values.toList(),
                  'names': logic.subjects
                    .where((subject) => logic.selectedSubjects.containsKey(subject['code']))
                    .map((subject) => subject['name'] as String)
                    .toList(), // Enviamos los nombres
                  'degree': widget.degreeName,
                };
              Navigator.pop(context, result);
            },
            tooltip: 'Guardar selecciones',
          ),
        ],
      ),
      body: _buildBody(), // Construye el cuerpo principal de la pantalla
    );
  }

  /// Construye el widget principal del cuerpo según el estado actual
  Widget _buildBody() {
    // Estado de carga - muestra indicador de progreso
    if (logic.isLoading) {
      return SelectSubjectsDegreeWdigets.buildLoadingIndicator();
    }

    // Estado sin asignaturas - muestra mensaje de error
    if (logic.subjects.isEmpty) {
      return SelectSubjectsDegreeWdigets.buildErrorWidget(
        'No hay asignaturas disponibles', 
        context,
      );
    }

    // Estado con datos - muestra lista de asignaturas
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: logic.subjects.length,
      separatorBuilder: (context, index) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        final subject = logic.subjects[index];
        // Tarjeta individual para cada asignatura
        return SelectSubjectsDegreeWdigets.buildSubjectCard(
          context: context,
          name: subject['name'],      // Nombre de la asignatura
          code: subject['code'],   
          codeIcs: subject['code_ics'],   // Código identificador
          isSelected: logic.selectedSubjects.containsKey(subject['code']), // Estado de selección
          onTap: () => logic.toggleSelection(subject['code'], subject['code_ics']),// Acción al tocar
          isDarkMode: logic.isDarkMode, // Estado del tema
        );
      },
    );
  }
}