import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import 'timetable_principal_logic.dart';
import 'timetable_principal_widgets_mobile.dart';
import 'timetable_principal_widgets_desktop.dart';

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
      Provider.of<TimetablePrincipalLogic>(context, listen: false).loadSubjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Consumer<TimetablePrincipalLogic>(
      builder: (context, timetableLogic, child) {
        return Scaffold(
          body: timetableLogic.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    if (timetableLogic.userSubjects.isEmpty)...[
                      Expanded(
                        child: isDesktop 
                          ? const BuildEmptyCardDesktop() 
                          : const BuildEmptyCardMobile()
                      ),
                    ]
                    else if (timetableLogic.errorMessage.isNotEmpty)
                      Expanded(
                        child: Center(
                          child: Text(
                            timetableLogic.errorMessage,
                            style: const TextStyle(color: Colors.red, fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else ...[
                      isDesktop
                        ? WeekDaysHeaderDesktop(isDarkMode: isDarkMode, timetableLogic: timetableLogic)
                        : WeekDaysHeaderMobile(isDarkMode: isDarkMode, timetableLogic: timetableLogic),
                      Expanded(
                        child: isDesktop
                          ? WeekSelectorDesktop(
                              timetableLogic: timetableLogic,
                              isDarkMode: isDarkMode,
                            )
                          : WeekSelectorMobile(
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