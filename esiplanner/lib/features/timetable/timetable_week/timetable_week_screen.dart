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
  final TimeOfDay startHour = const TimeOfDay(hour: 8, minute: 0); // 8:00 AM
  final TimeOfDay endHour = const TimeOfDay(hour: 22, minute: 0); // 10:00 PM

  const WeeklyViewMobileGoogle({
    super.key,
    required this.logic,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcula dimensiones basadas en las constraints
        final timeColumnWidth = 60.0;
        final hourSlotHeight = 65.0;
        final dayColumnWidth = (constraints.maxWidth - timeColumnWidth)/5;

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
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  _buildDaysHeader(weekDays, weekDates, timeColumnWidth, dayColumnWidth),
                  _buildTimeAndEventsContent(
                    weekDays: weekDays,
                    weekDates: weekDates,
                    eventsByDate: eventsByDate,
                    subjectColors: subjectColors,
                    timeColumnWidth: timeColumnWidth,
                    dayColumnWidth: dayColumnWidth,
                    hourSlotHeight: hourSlotHeight,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDaysHeader(
    List<String> weekDays,
    List<DateTime> weekDates,
    double timeColumnWidth,
    double dayColumnWidth,
  ) {
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
                    ? (isDarkMode ? Colors.blue.shade900.withValues(alpha: 0.2) : Colors.blue.shade50)
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
          }),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Widget _buildTimeAndEventsContent({
    required List<String> weekDays,
    required List<DateTime> weekDates,
    required Map<String, List<Map<String, dynamic>>> eventsByDate,
    required SubjectColors subjectColors,
    required double timeColumnWidth,
    required double dayColumnWidth,
    required double hourSlotHeight,
  }) {
    final totalSlots = _calculateTotalTimeSlots();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimeColumn(totalSlots, timeColumnWidth, hourSlotHeight),
        ...List.generate(weekDays.length, (index) {
          final dateKey = DateFormat('yyyy-MM-dd').format(weekDates[index]);
          final dayEvents = eventsByDate[dateKey] ?? [];
          dayEvents.sort(logic.sortEventsByTime);
          
          return _buildDayColumn(
            events: dayEvents,
            subjectColors: subjectColors,
            totalSlots: totalSlots,
            dayColumnWidth: dayColumnWidth,
            hourSlotHeight: hourSlotHeight,
          );
        }),
      ],
    );
  }

  Widget _buildTimeColumn(int totalSlots, double timeColumnWidth, double hourSlotHeight) {
    return SizedBox(
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

  Widget _buildDayColumn({
    required List<Map<String, dynamic>> events,
    required SubjectColors subjectColors,
    required int totalSlots,
    required double dayColumnWidth,
    required double hourSlotHeight,
  }) {
    final overlappingInfo = logic.calculateOverlappingEvents(events);

    return SizedBox(
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
          ..._buildEventsForDay(
            events: events,
            overlappingInfo: overlappingInfo,
            subjectColors: subjectColors,
            dayColumnWidth: dayColumnWidth,
            hourSlotHeight: hourSlotHeight,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEventsForDay({
    required List<Map<String, dynamic>> events,
    required List<bool> overlappingInfo,
    required SubjectColors subjectColors,
    required double dayColumnWidth,
    required double hourSlotHeight,
  }) {
    // Primero agrupamos los eventos solapados
    final List<List<Map<String, dynamic>>> eventGroups = [];
    List<Map<String, dynamic>> currentGroup = [];

    for (int i = 0; i < events.length; i++) {
      if (i > 0) {
        final prevEvent = events[i-1];
        final currentEvent = events[i];
        
        final prevEnd = DateTime.parse('${prevEvent['event']['date']} ${prevEvent['event']['end_hour']}');
        final currentStart = DateTime.parse('${currentEvent['event']['date']} ${currentEvent['event']['start_hour']}');
        
        if (currentStart.isBefore(prevEnd)) {
          // Hay solapamiento
          if (currentGroup.isEmpty) {
            currentGroup.add(prevEvent);
          }
          currentGroup.add(currentEvent);
        } else {
          if (currentGroup.isNotEmpty) {
            eventGroups.add(List.from(currentGroup));
            currentGroup.clear();
          }
        }
      }
    }

    if (currentGroup.isNotEmpty) {
      eventGroups.add(List.from(currentGroup));
    }

    // Construimos los widgets
    final List<Widget> widgets = [];
    
    for (int i = 0; i < events.length; i++) {
      final eventData = events[i];
      final event = eventData['event'];
      final subjectName = eventData['subjectName'];
      final subjectColor = subjectColors.getSubjectColor(subjectName);
      
      final startTime = DateTime.parse('${event['date']} ${event['start_hour']}');
      final endTime = DateTime.parse('${event['date']} ${event['end_hour']}');
      
      final topPosition = _calculateEventTopPosition(startTime, hourSlotHeight);
      final height = _calculateEventHeight(startTime, endTime, hourSlotHeight);
      
      // Buscamos si este evento está en algún grupo de solapamiento
      int? groupIndex;
      int positionInGroup = 0;
      for (int g = 0; g < eventGroups.length; g++) {
        if (eventGroups[g].contains(eventData)) {
          groupIndex = g;
          positionInGroup = eventGroups[g].indexOf(eventData);
          break;
        }
      }
      
      final isOverlapping = groupIndex != null;
      final totalOverlapping = isOverlapping ? eventGroups[groupIndex].length : 1;
      
      widgets.add(
        Positioned(
          top: topPosition + 40, // 40 for header
          left: isOverlapping 
              ? (dayColumnWidth / totalOverlapping) * positionInGroup + 2
              : 2,
          width: isOverlapping 
              ? (dayColumnWidth / totalOverlapping) - 4
              : dayColumnWidth - 4,
          height: height - 4, // small margin
          child: EventCard(
            eventData: eventData,
            getGroupLabel: logic.getGroupLabel,
            subjectColor: subjectColor,
            isDarkMode: isDarkMode,
            isCompact: isOverlapping,
          ),
        ),
      );
    }
    
    return widgets;
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

  double _calculateEventTopPosition(DateTime eventStart, double hourSlotHeight) {
    final startMinutes = startHour.hour * 60 + startHour.minute;
    final eventMinutes = eventStart.hour * 60 + eventStart.minute;
    final slotIndex = (eventMinutes - startMinutes) ~/ 30;
    return slotIndex * hourSlotHeight;
  }

  double _calculateEventHeight(DateTime eventStart, DateTime eventEnd, double hourSlotHeight) {
    final durationMinutes = eventEnd.difference(eventStart).inMinutes;
    return (durationMinutes / 30) * hourSlotHeight;
  }
}