import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esiplanner/providers/theme_provider.dart';
import 'package:esiplanner/services/subject_service.dart';
import 'package:esiplanner/providers/auth_provider.dart';
import '../select_subjects_degree/select_subjects_degree_screen.dart';
import '../select_subjects_groups/select_subjects_groups_screen.dart';
import 'select_subjects_home_logic.dart';
import 'select_subjects_home_widgets.dart';

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
        title: const Text('Guía de selección'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. Añade asignaturas pulsando el botón +'),
              SizedBox(height: 8),
              Text('2. Selecciona un grado y las asignaturas'),
              SizedBox(height: 8),
              Text('3. Asigna grupos a cada asignatura'),
              SizedBox(height: 8),
              Text('4. Confirma tu selección final'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
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
      await logic.updateSelections(result);
      setState(() {});
    }
  }

  Future<void> _showConfirmationDialog() async {
    if (!_isMounted) return;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('¡Confirmado!'),
        content: const Text('Tus asignaturas han sido guardadas correctamente.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              logic.resetSelection();
              if (_isMounted) Navigator.pop(context);
            },
            child: const Text('Continuar'),
          ),
        ],
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDarkMode 
                ? null
                : LinearGradient(
                    colors: [
                      Colors.indigo.shade900,
                      Colors.blue.shade900,
                    ],
                  ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (logic.selectedSubjects.isNotEmpty)
            SelectSubjectsHomeWidgets.buildSectionTitle(
              context,
              'Asignaturas seleccionadas (${logic.selectedSubjects.length})',
            ),
          Expanded(
            child: logic.isLoading
                ? const Center(child: CircularProgressIndicator())
                : logic.selectedSubjects.isEmpty
                    ? SelectSubjectsHomeWidgets.buildEmptySelectionCard(context)
                    : ListView.builder(
                        itemCount: logic.selectedSubjects.length,
                        itemBuilder: (context, index) {
                          final code = logic.selectedSubjects.elementAt(index);
                          return SelectSubjectsHomeWidgets.buildSelectedSubjectCard(
                            context: context,
                            code: code,
                            name: logic.subjectNames[code] ?? 'Cargando...',
                            degree: logic.subjectDegrees[code] ?? 'Grado no disponible',
                            hasGroupsSelected: logic.groupsSelected[code] ?? false,
                            onDelete: () {
                              setState(() {
                                logic.selectedSubjects.remove(code);
                                logic.subjectNames.remove(code);
                                logic.subjectDegrees.remove(code);
                                logic.groupsSelected.remove(code);
                                logic.selectedGroupsMap.remove(code);
                              });
                            },
                          );
                        },
                      ),
          ),
          if (logic.selectedSubjects.isNotEmpty)
            Column(
              children: [
                if (logic.groupsSelected.values.any((selected) => !selected))
                  SelectSubjectsHomeWidgets.buildManageGroupsButton(
                    context: context,
                    onPressed: _navigateToGroupSelection,
                    hasSelectedSubjects: true,
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
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingActionButton(
          onPressed: () {
            SelectSubjectsHomeWidgets.showAddSubjectsDialog(
              context: context,
              availableDegrees: logic.availableDegrees,
              onDegreeSelected: _navigateToDegreeSubjects,
              isDarkMode: isDarkMode,
            );
          },
          child: const Icon(Icons.add),
          backgroundColor: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
          foregroundColor: isDarkMode ? Colors.black : Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}