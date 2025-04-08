import 'package:flutter/material.dart';
import '../../../services/subject_service.dart';
import 'select_subjects_degree_logic.dart';
import 'select_subjects_degree_widgets.dart';

class DegreeSubjectsScreen extends StatefulWidget {
  final String degreeName;
  final List<String> initiallySelected;

  const DegreeSubjectsScreen({
    super.key,
    required this.degreeName,
    required this.initiallySelected,
  });

  @override
  State<DegreeSubjectsScreen> createState() => _DegreeSubjectsScreenState();
}

class _DegreeSubjectsScreenState extends State<DegreeSubjectsScreen> {
  late SelectSubjectsDegreeLogic logic;

  @override
  void initState() {
    super.initState();
    logic = SelectSubjectsDegreeLogic(
      context: context,
      subjectService: SubjectService(),
      degreeName: widget.degreeName,
      initiallySelected: widget.initiallySelected,
      refreshUI: () => setState(() {}),
    );
    logic.loadSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.degreeName),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => Navigator.pop(context, logic.selectedSubjects.toList()),
            tooltip: 'Guardar selecciones',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (logic.isLoading) {
      return SelectSubjectsDegreeWdigets.buildLoadingIndicator();
    }

    if (logic.subjects.isEmpty) {
      return SelectSubjectsDegreeWdigets.buildErrorWidget(
        'No hay asignaturas disponibles', 
        context,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: logic.subjects.length,
      separatorBuilder: (context, index) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        final subject = logic.subjects[index];
        return SelectSubjectsDegreeWdigets.buildSubjectCard(
          context: context,
          name: subject['name'],
          code: subject['code'],
          isSelected: logic.selectedSubjects.contains(subject['code']),
          onTap: () => logic.toggleSelection(subject['code']),
          isDarkMode: logic.isDarkMode,
        );
      },
    );
  }
}