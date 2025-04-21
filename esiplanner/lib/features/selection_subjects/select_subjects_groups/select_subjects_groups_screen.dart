import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import 'select_subjects_groups_logic.dart';
import 'select_subjects_groups_widgets.dart';

/// Pantalla para seleccionar grupos/clases de asignaturas académicas.
/// Permite:
/// - Visualizar los grupos disponibles por asignatura
/// - Seleccionar grupos específicos
/// - Validar que todas las selecciones requeridas estén completas
/// - Guardar la selección final
class SelectGroupsScreen extends StatefulWidget {
  final List<String> selectedSubjectCodes;
  final Map<String, String> subjectDegrees;

  const SelectGroupsScreen({
    super.key, 
    required this.selectedSubjectCodes,
    required this.subjectDegrees,
  });

  @override
  State<SelectGroupsScreen> createState() => _SelectGroupsScreenState();
}

class _SelectGroupsScreenState extends State<SelectGroupsScreen> {
  late SelectGroupsLogic logic;

  @override
  void initState() {
    super.initState();
    logic = SelectGroupsLogic(
      selectedSubjectCodes: widget.selectedSubjectCodes,
      subjectDegrees: widget.subjectDegrees,
    );
  }

  /// Guarda las selecciones si están completas, o muestra error
  Future<void> _saveSelections() async {
    if (!logic.allSelectionsComplete) {
      // Muestra mensaje si faltan selecciones
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona un grupo de cada tipo para cada asignatura', 
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Si todo está completo, regresa con los grupos seleccionados
    if (mounted) {
      Navigator.pop(context, logic.selectedGroups);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtiene el tema actual
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return ChangeNotifierProvider.value(
      // Provee la lógica a los widgets hijos
      value: logic,
      child: Consumer<SelectGroupsLogic>(
        builder: (context, logic, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Selección de grupos', 
                style: TextStyle(color: Colors.white)
              ),
              centerTitle: true,
              actions: [
                // Botón para guardar las selecciones
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveSelections,
                )
              ],
            ),
            body: logic.isLoading
                ? const Center(child: CircularProgressIndicator()) // Indicador de carga
                : SelectGroupsContent( // Contenido principal
                    isDarkMode: isDarkMode,
                  ),
          );
        }
      ),
    );
  }
}