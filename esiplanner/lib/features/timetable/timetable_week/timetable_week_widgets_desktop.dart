import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'timetable_week_logic.dart';
import '../../../utils.dart/subject_colors.dart';
import '../../../shared/widgets/event_card.dart';

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
        final timeColumnWidth = 60.0;
        final hourSlotHeight = 60.0;
        final dayColumnWidth = (constraints.maxWidth - timeColumnWidth) / 5;

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
      height: 50,
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
                border: Border(
                  right: BorderSide(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
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
            isToday: _isToday(weekDates[index]),
          );
        }),
      ],
    );
  }

  Widget _buildTimeColumn(int totalSlots, double timeColumnWidth, double hourSlotHeight) {
    return Container(
      width: timeColumnWidth,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
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
    required bool isToday,
  }) {
    final overlappingInfo = logic.calculateOverlappingEvents(events);

    return Container(
      width: dayColumnWidth,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        color: isToday 
            ? (isDarkMode ? Colors.blue.shade900.withOpacity(0.1) : Colors.blue.shade50)
            : null,
      ),
      child: Stack(
        children: [
          // Hour lines
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
          // Events
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
      
      // Calculate width based on overlapping
      double left = 2;
      double width = dayColumnWidth - 4;
      
      if (overlappingInfo[i]) {
        // Find all overlapping events
        final overlappingEvents = [eventData];
        for (int j = i + 1; j < events.length; j++) {
          final nextEvent = events[j];
          final nextStart = DateTime.parse('${nextEvent['event']['date']} ${nextEvent['event']['start_hour']}');
          if (nextStart.isBefore(endTime)) {
            overlappingEvents.add(nextEvent);
          } else {
            break;
          }
        }
        
        final overlapCount = overlappingEvents.length;
        final overlapIndex = overlappingEvents.indexOf(eventData);
        
        width = (dayColumnWidth - 4) / overlapCount;
        left = 2 + (width * overlapIndex);
      }
      
      widgets.add(
        Positioned(
          top: topPosition + 50, // 50 for header
          left: left,
          width: width,
          height: height - 2, // small margin
          child: EventCard(
            eventData: eventData,
            getGroupLabel: logic.getGroupLabel,
            subjectColor: subjectColor,
            isDarkMode: isDarkMode,
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