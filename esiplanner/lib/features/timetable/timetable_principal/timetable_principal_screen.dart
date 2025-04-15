import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import 'timetable_principal_logic.dart';
import 'timetable_principal_widgets.dart';

class TimetablePrincipalScreen extends StatefulWidget {
  const TimetablePrincipalScreen({super.key});

  @override
  State<TimetablePrincipalScreen> createState() => _TimetablePrincipalScreenState();
}

class _TimetablePrincipalScreenState extends State<TimetablePrincipalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TimetableLogic>(context, listen: false).loadSubjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Consumer<TimetableLogic>(
      builder: (context, timetableLogic, child) {
        return Scaffold(
          body: timetableLogic.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    if (timetableLogic.userSubjects.isEmpty)...[
                      Expanded(child: BuildEmptyCard()),
                    ]
                    else if (timetableLogic.errorMessage.isNotEmpty)
                      Expanded( // Ocupa todo el espacio restante
                        child: Center( // Centrado vertical y horizontal
                          child: Text(
                            timetableLogic.errorMessage,
                            style: const TextStyle(color: Colors.red, fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else ...[
                      WeekDaysHeader(isDarkMode: isDarkMode),
                      Expanded(
                        child: WeekSelector(
                          timetableLogic: timetableLogic,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    ],
                  ],
                ),
        );
      },
    );
  }
}