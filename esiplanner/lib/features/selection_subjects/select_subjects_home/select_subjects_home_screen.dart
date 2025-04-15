import 'package:esiplanner/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/subject_service.dart';
import '../select_subjects_degree/select_subjects_degree_screen.dart';
import '../select_subjects_groups/select_subjects_groups_screen.dart';
import 'package:esiplanner/features/selection_subjects/select_subjects_home/select_subjects_home_widgets.dart';
import 'select_subjects_home_logic.dart';
import 'package:esiplanner/providers/auth_provider.dart';

class SubjectSelectionScreen extends StatefulWidget {
  const SubjectSelectionScreen({super.key});

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  late SubjectSelectionHomeLogic logic;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final subjectService = SubjectService();

    logic = SubjectSelectionHomeLogic(
      authProvider: authProvider,
      subjectService: subjectService,
      refreshUI: () {
        if (_isMounted) setState(() {});
      },
      showError: (message) {
        if (_isMounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
    );
    
    logic.loadDegrees();
  }

  @override
  void dispose() {
    _isMounted = false;
    logic.dispose();
    super.dispose();
  }

  void _navigateToGroupSelection() async {
    if (!_isMounted) return;
    
    if (logic.selectedSubjects.isEmpty) {
      logic.showError('Selecciona al menos una asignatura');
      return;
    }

    final result = await Navigator.push<Map<String, Map<String, String>>>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectGroupsScreen(
          selectedSubjectCodes: logic.selectedSubjects.toList(),
          subjectDegrees: logic.subjectDegrees,
          subjectIcsCodes: logic.subjectIcsCodes, // Pasa los códigos ICS
        ),
      ),
    );

    if (result != null && _isMounted) {
      setState(() {
        logic.selectedGroupsMap = result;
        result.forEach((code, groups) {
          logic.groupsSelected[code] = groups.isNotEmpty;
        });
      });
    }
  }

  void _showSelectionInstructions() {
    if (!_isMounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guía de selección de asignaturas'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInstructionStep(1, 'Selecciona un grado académico de la lista desplegable'),
              _buildInstructionStep(2, 'Marca las asignaturas que deseas cursar'),
              _buildInstructionStep(3, 'Asigna grupos específicos para cada asignatura'),
              _buildInstructionStep(4, 'Confirma tu selección de asignaturas'),
              const SizedBox(height: 16),
              Text('* Repite los pasos 1 y 2 para asignaturas de otros grados', 
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(int step, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text('$step', style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _navigateToDegreeSubjects(String degree) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => DegreeSubjectsScreen(
          degreeName: degree,
          initiallySelected: logic.selectedSubjects.toList(),
        ),
      ),
    );

    if (result != null && _isMounted) {
      await logic.updateSelections(result); // Ahora es async
      setState(() {});
    }
  }

  Future<void> _showConfirmationDialog() async {
    if (!_isMounted) return;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('¡Asignaturas confirmadas!'),
        content: const Text('Tus asignaturas han sido guardadas exitosamente.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo
              logic.resetSelection(); // Limpia la seleccion
              if (_isMounted) Navigator.pop(context); // Navega hacia atrás
            },
            child: const Text('Continuar'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Future<void> _confirmSelections() async {
    await logic.confirmSelections();
    if (_isMounted && logic.groupsSelected.values.every((selected) => selected)) {
      await _showConfirmationDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selección de asignaturas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showSelectionInstructions,
            tooltip: 'Instrucciones',
          ),
        ],
        centerTitle: true,
        elevation: 10,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDarkMode 
                ? null
                : LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.indigo.shade900,
                      Colors.blue.shade900,
                      Colors.blueAccent.shade400,
                    ],
                  ),
            color: isDarkMode ? Colors.black : null,
          ),
        ),
      ),
      body: Column(
        children: [
          SelectSubjectsHomeWidgets.buildDegreeDropdown(
            context: context,
            availableDegrees: logic.availableDegrees,
            onDegreeSelected: _navigateToDegreeSubjects,
            isDarkMode: isDarkMode,
          ),
          Expanded(
            child: logic.isLoading
                ? const Center(child: CircularProgressIndicator())
                : logic.selectedSubjects.isEmpty
                    ? SelectSubjectsHomeWidgets.buildEmptySelectionCard(context)
                    : Column(
                        children: [
                          SelectSubjectsHomeWidgets.buildSectionTitle(
                            context,
                            'Asignaturas seleccionadas (${logic.selectedSubjects.length})',
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: logic.selectedSubjects.length,
                              itemBuilder: (context, index) {
                                final code = logic.selectedSubjects.elementAt(index);
                                return SelectSubjectsHomeWidgets.buildSelectedSubjectCard(
                                  context: context,
                                  code: code,
                                  icsCode: logic.subjectIcsCodes[code] ?? 'Cargando ICS...', // Añadimos ICS code
                                  name: logic.subjectNames[code] ?? 'Cargando...',
                                  degree: logic.subjectDegrees[code] ?? 'Grado no disponible',
                                  hasGroupsSelected: logic.groupsSelected[code] ?? false,
                                  onDelete: () {
                                    if (_isMounted) {
                                      setState(() {
                                        logic.selectedSubjects.remove(code);
                                        logic.subjectNames.remove(code);
                                        logic.subjectDegrees.remove(code);
                                        logic.subjectIcsCodes.remove(code); // Limpiamos también el ICS code
                                        logic.groupsSelected.remove(code);
                                        logic.selectedGroupsMap.remove(code);
                                      });
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                          if (logic.groupsSelected.values.any((selected) => !selected))
                            SelectSubjectsHomeWidgets.buildManageGroupsButton(
                              context: context,
                              onPressed: _navigateToGroupSelection,
                              hasSelectedSubjects: logic.selectedSubjects.isNotEmpty,
                              isDarkMode: isDarkMode,
                            ),
                          if (logic.groupsSelected.values.every((selected) => selected))
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('Confirmar Asignaturas'),
                                onPressed: _confirmSelections,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}