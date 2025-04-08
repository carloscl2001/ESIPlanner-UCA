import 'package:flutter/material.dart';
import 'timetable_week_logic.dart';
import 'timetable_week_widgets.dart';

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
      body: Column(
        children: [
          WeekHeader(logic: logic, isDarkMode: isDarkMode),
          WeekDaysHeader(logic: logic, isDarkMode: isDarkMode),
          Expanded(
            child: EventList(logic: logic, isDarkMode: isDarkMode),
          ),
        ],
      ),
    );
  }
}