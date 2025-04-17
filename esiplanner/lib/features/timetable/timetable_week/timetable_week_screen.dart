import 'package:flutter/material.dart';
import 'timetable_week_logic.dart';
import 'timetable_week_widgets_desktop.dart';
import 'timetable_week_widgets_mobile.dart';

class TimetableWeekScreen extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final int selectedWeekIndex;
  final bool isDarkMode;
  final DateTime weekStartDate;

  const TimetableWeekScreen({
    super.key,
    required this.events,
    required this.selectedWeekIndex,
    required this.isDarkMode,
    required this.weekStartDate,
  });

  @override
  Widget build(BuildContext context) {
    final logic = TimetableWeekLogic(events: events, weekStartDate: weekStartDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis clases de la semana'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Usamos 600 como punto de ruptura entre móvil y escritorio
          final isDesktop = constraints.maxWidth > 1024;

          return Column(
            children: [
              if (isDesktop) ...[
                WeekHeaderDesktop(logic: logic, isDarkMode: isDarkMode),
                Expanded(
                  child: EventListDesktop(logic: logic, isDarkMode: isDarkMode),
                ),
              ] else ...[
                WeekHeaderMobile(logic: logic, isDarkMode: isDarkMode),
                WeekDaysHeaderMobile(logic: logic, isDarkMode: isDarkMode),
                Expanded(
                  child: EventListMobile(logic: logic, isDarkMode: isDarkMode),
                ),
              ],
            ],
          );

        },
      ),
    );
  }
}