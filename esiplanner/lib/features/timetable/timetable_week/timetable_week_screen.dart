import 'dart:ui';

import 'package:esiplanner/shared/widgets/event_card_timetable_week.dart';
import 'package:esiplanner/utils.dart/subject_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final bool _isDesktop = false;

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
                      ? WeeklyViewMobileGoogle(
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
      floatingActionButton: !_isDesktop
          ? ViewToggleFab(
              isDarkMode: widget.isDarkMode,
              showGoogleView: _showGoogleView,
              onPressed: _toggleView,
            )
          : null,
    );
  }
}

class WeeklyViewMobileGoogle extends StatelessWidget {
  final TimetableWeekLogic logic;
  final bool isDarkMode;
  final double dayColumnWidth = 250.0; // Antes era 100.0
  final double timeColumnWidth = 60.0;
  final double hourSlotHeight = 65.0;
  final TimeOfDay startHour = const TimeOfDay(hour: 8, minute: 0); // 8:00 AM
  final TimeOfDay endHour = const TimeOfDay(hour: 22, minute: 0); // 10:00 PM

  const WeeklyViewMobileGoogle({
    super.key,
    required this.logic,
    required this.isDarkMode,
  });


  @override
  Widget build(BuildContext context) {
    final weekDays = logic.weekDays;
    final weekDates = logic.getWeekDays();
    final eventsByDate = logic.groupEventsByDate();
    final subjectColors = SubjectColors(isDarkMode);

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900.withAlpha(153) : Colors.white,
      ),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical, // Scroll vertical principal
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Scroll horizontal para días
            child: Column(
              children: [
                // Header de días
                _buildDaysHeader(weekDays, weekDates),
                // Contenido principal (horas + eventos)
                _buildTimeAndEventsContent(weekDays, weekDates, eventsByDate, subjectColors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaysHeader(List<String> weekDays, List<DateTime> weekDates) {
    return Container(
      height: 40,
      color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
      child: Row(
        children: [
          SizedBox(
            width: timeColumnWidth,
            child: Center(
              child: Text(
                'Hora',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          ...weekDays.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            final isToday = _isToday(weekDates[index]);
            return Container(
              width: dayColumnWidth,
              decoration: BoxDecoration(
                color: isToday
                    ? (isDarkMode ? Colors.blue.shade900.withOpacity(0.2) : Colors.blue.shade50)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    DateFormat('d').format(weekDates[index]),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  } 

  

  Widget _buildTimeAndEventsContent(
    List<String> weekDays,
    List<DateTime> weekDates,
    Map<String, List<Map<String, dynamic>>> eventsByDate,
    SubjectColors subjectColors,
  ) {
    final totalSlots = _calculateTotalTimeSlots();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna de horas
        _buildTimeColumn(totalSlots),
        // Columnas de días
        ...List.generate(weekDays.length, (index) {
          final dateKey = DateFormat('yyyy-MM-dd').format(weekDates[index]);
          final dayEvents = eventsByDate[dateKey] ?? [];
          dayEvents.sort(logic.sortEventsByTime);
          
          return _buildDayColumn(dayEvents, subjectColors);
        }),
      ],
    );
  }

  Widget _buildTimeColumn(int totalSlots) {
    return Container(
      width: timeColumnWidth,
      child: Column(
        children: List.generate(totalSlots, (index) {
          final currentTime = _getTimeForSlot(index);
          return SizedBox(
            height: hourSlotHeight,
            child: Center(
              child: Text(
                DateFormat('HH:mm').format(currentTime),
                style: TextStyle(
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayColumn(
    List<Map<String, dynamic>> events,
    SubjectColors subjectColors,
  ) {
    final totalSlots = _calculateTotalTimeSlots();
    final overlappingInfo = logic.calculateOverlappingEvents(events);

    return Container(
      width: dayColumnWidth,
      child: Stack(
        children: [
          // Líneas horizontales
          Column(
            children: List.generate(totalSlots, (index) {
              return Container(
                height: hourSlotHeight,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                ),
              );
            }),
          ),
          // Eventos
          ..._buildEventsForDay(events, overlappingInfo, subjectColors),
        ],
      ),
    );
  }


  List<Widget> _buildEventsForDay(
    List<Map<String, dynamic>> events,
    List<bool> overlappingInfo,
    SubjectColors subjectColors,
  ) {
    return List.generate(events.length, (index) {
      final eventData = events[index];
      final event = eventData['event'];
      final isOverlapping = index < overlappingInfo.length ? overlappingInfo[index] : false;
      final subjectName = eventData['subjectName'];
      final subjectColor = subjectColors.getSubjectColor(subjectName);
      
      final startTime = DateTime.parse('${event['date']} ${event['start_hour']}');
      final endTime = DateTime.parse('${event['date']} ${event['end_hour']}');
      
      final topPosition = _calculateEventTopPosition(startTime);
      final height = _calculateEventHeight(startTime, endTime);
      
      return Positioned(
        top: topPosition + 40, // 40 for header
        left: isOverlapping ? dayColumnWidth / 2 : 2,
        right: 2,
        height: height - 4, // small margin
        child: EventCard(
          eventData: eventData,
          getGroupLabel: logic.getGroupLabel,
          subjectColor: subjectColor,
          isDarkMode: isDarkMode,
          isCompact: isOverlapping,
        ),
      );
    });
  }

  int _calculateTotalTimeSlots() {
    final startMinutes = startHour.hour * 60 + startHour.minute;
    final endMinutes = endHour.hour * 60 + endHour.minute;
    return (endMinutes - startMinutes) ~/ 30;
  }

  DateTime _getTimeForSlot(int slotIndex) {
    final minutes = startHour.hour * 60 + startHour.minute + (slotIndex * 30);
    return DateTime(2023, 1, 1, minutes ~/ 60, minutes % 60);
  }

  double _calculateEventTopPosition(DateTime eventStart) {
    final startMinutes = startHour.hour * 60 + startHour.minute;
    final eventMinutes = eventStart.hour * 60 + eventStart.minute;
    final slotIndex = (eventMinutes - startMinutes) ~/ 30;
    return slotIndex * hourSlotHeight;
  }

  double _calculateEventHeight(DateTime eventStart, DateTime eventEnd) {
    final durationMinutes = eventEnd.difference(eventStart).inMinutes;
    return (durationMinutes / 30) * hourSlotHeight;
  }
}