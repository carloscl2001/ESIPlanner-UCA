import 'package:flutter/material.dart';
import 'timetable_week_logic.dart';
import 'timetable_week_widgets_desktop.dart';
import 'timetable_week_widgets_mobile.dart';

class TimetableWeekScreen extends StatefulWidget {
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
  State<TimetableWeekScreen> createState() => _TimetableWeekScreenState();
}

class _TimetableWeekScreenState extends State<TimetableWeekScreen> {
  bool _showGoogleView = false;

  void _toggleView() {
    setState(() {
      _showGoogleView = !_showGoogleView;
    });
  }

  @override
  Widget build(BuildContext context) {
    final logic = TimetableWeekLogic(events: widget.events, weekStartDate: widget.weekStartDate);

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
            gradient: widget.isDarkMode
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
            color: widget.isDarkMode ? Colors.black : null,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 1024;

          return Column(
            children: [
              if (isDesktop) ...[
                WeekHeaderDesktop(logic: logic, isDarkMode: widget.isDarkMode),
                Expanded(
                  child: EventListDesktop(logic: logic, isDarkMode: widget.isDarkMode),
                ),
              ] else ...[
                WeekHeaderMobile(logic: logic, isDarkMode: widget.isDarkMode),
                WeekDaysHeaderMobile(logic: logic, isDarkMode: widget.isDarkMode),
                Expanded(
                  child: _showGoogleView
                      ? EventListMobileGoogle(
                          logic: logic,
                          isDarkMode: widget.isDarkMode,
                        )
                      : EventListMobile(
                          logic: logic,
                          isDarkMode: widget.isDarkMode,
                        ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: Builder(
        builder: (context) {
          final isDesktop = MediaQuery.of(context).size.width > 1024;
          return !isDesktop
              ? ViewToggleFab(
                  isDarkMode: widget.isDarkMode,
                  showGoogleView: _showGoogleView,
                  onPressed: _toggleView,
                )
              : const SizedBox.shrink(); // Devuelve un Widget en lugar de null
        },
      ),
    );
  }
}