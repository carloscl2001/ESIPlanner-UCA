import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import 'select_subjects_groups_logic.dart';
import 'select_subjects_groups_widgets.dart';

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

  Future<void> _saveSelections() async {
    if (logic.requireAllTypes && !logic.allSelectionsComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No has completado todas las selecciones requeridas', 
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (mounted) {
      Navigator.pop(context, logic.selectedGroups);
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(
        requireAllTypes: logic.requireAllTypes,
        oneGroupPerType: logic.oneGroupPerType,
        onSettingsChanged: (allTypes, onePerType) {
          logic.updateRestrictions(allTypes, onePerType);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return ChangeNotifierProvider.value(
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
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: _showSettingsDialog,
                  tooltip: 'Configurar restricciones',
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: logic.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SelectGroupsContent(
                          isDarkMode: isDarkMode,
                          requireAllTypes: logic.requireAllTypes,
                          oneGroupPerType: logic.oneGroupPerType,
                        ),
                ),
                SaveButton(
                  onPressed: _saveSelections,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}