import 'package:esiplanner/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_subjects_logic.dart';
import 'view_subjects_widgets.dart';

class ViewSubjectsScreen extends StatefulWidget {
  const ViewSubjectsScreen({super.key});

  @override
  State<ViewSubjectsScreen> createState() => _ViewSubjectsScreenState();
}

class _ViewSubjectsScreenState extends State<ViewSubjectsScreen> {
  late ViewSubjectsProfileLogic logic;

  @override
  void initState() {
    super.initState();
    logic = ViewSubjectsProfileLogic(
      refreshUI: () => setState(() {}),
      showError: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
    );
    // Pasamos el context aquí
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logic.loadUserSubjects(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis asignaturas'),
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
      body: _buildBody(isDarkMode),
    );
  }

  Widget _buildBody(bool isDarkMode) {
    if (logic.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if(logic.userSubjects.isEmpty){
      
      return BuildEmptyCard();
    }

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        children: <Widget>[
          if (logic.errorMessage.isNotEmpty) ...[
            Text(
              logic.errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
          if (logic.userSubjects.isNotEmpty) ...[
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: logic.userSubjects.length,
                itemBuilder: (context, index) {
                  final subject = logic.userSubjects[index];
                  return SubjectCard(
                    subject: subject,
                    isDarkMode: isDarkMode,
                  );
                },
              ),
            ),
          ] else ...[
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'No has seleccionado ninguna asignatura',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}