import 'package:esiplanner/shared/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'timetable_week_logic.dart';
import '../../../shared/widgets/class_cards.dart';
import '../../../utils.dart/subject_colors.dart';

class WeekHeaderMobile extends StatelessWidget {
  final TimetableWeekLogic logic;
  final bool isDarkMode;

  const WeekHeaderMobile({super.key, required this.logic, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final headerInfo = logic.getWeekHeaderInfo();
    final showTwoMonths = headerInfo['startMonth'] != headerInfo['endMonth'];
    final showTwoYears = headerInfo['startYear'] != headerInfo['endYear'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 10.0, left: 20.0, right: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Text(
              showTwoMonths 
                  ? '${headerInfo['startMonth']} - ${headerInfo['endMonth']}'
                  : headerInfo['startMonth']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.black : Colors.white,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Text(
              showTwoYears
                  ? '${headerInfo['startYear']} - ${headerInfo['endYear']}'
                  : headerInfo['startYear']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.black : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeekDaysHeaderMobile extends StatelessWidget {
  final TimetableWeekLogic logic;
  final bool isDarkMode;

  const WeekDaysHeaderMobile({super.key, required this.logic, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final weekDays = logic.getWeekDays();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isDarkMode ? Colors.transparent : Colors.blue.shade900,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.grey.withValues(alpha: 0.45) 
                : Colors.black.withValues(alpha: 0.45),
            blurRadius: isDarkMode ? 0.0 : 6.0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final day = weekDays[index];
          return Column(
            children: [
              Text(
                (logic.weekDays[index]),
                style: TextStyle(
                  color: isDarkMode ? Colors.yellow.shade700 : Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('d', 'es_ES').format(day),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 20,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class EventListMobile extends StatelessWidget {
  final TimetableWeekLogic logic;
  final bool isDarkMode;

  const EventListMobile({super.key, required this.logic, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final groupedByDate = logic.groupEventsByDate();
    final sortedDates = groupedByDate.keys.toList()..sort();

    if (groupedByDate.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final events = groupedByDate[date]!..sort(logic.sortEventsByTime);
        final isOverlapping = logic.calculateOverlappingEvents(events);

        return Padding(
          padding: const EdgeInsets.only(top: 10.0), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  logic.formatDateToFullDate(DateTime.parse(date)),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isDarkMode ? Colors.yellow.shade700 : Colors.blue.shade900,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              ...events.asMap().entries.map((entry) {
                final index = entry.key;
                final eventData = entry.value;
                final event = eventData['event'];
                final classType = eventData['classType'];
                final subjectName = eventData['subjectName'];

                return ClassCards(
                  subjectName: subjectName,
                  classType: '$classType - ${logic.getGroupLabel(classType[0])}',
                  event: event,
                  isOverlap: isOverlapping[index],
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 60,
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'No tienes clases',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Disfruta de tu tiempo libre!',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class EventListMobileGoogle extends StatelessWidget {
  final TimetableWeekLogic logic;
  final bool isDarkMode;
  final double sizeTramo = 65;

  const EventListMobileGoogle({
    super.key,
    required this.logic,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final subjectColors = SubjectColors(isDarkMode);
    final events = logic.events;

    if (events.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900.withAlpha(153) : Colors.white,
      ),
      child: _buildDayViewVertical(events, isDarkMode, subjectColors)
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 60,
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'No tienes clases',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Disfruta de tu tiempo libre!',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayViewVertical(
    List<Map<String, dynamic>> events, 
    bool isDarkMode,
    SubjectColors subjectColors,
  ) {
    events.sort((a, b) {
      final timeA = DateTime.parse('${a['event']['date']} ${a['event']['start_hour']}');
      final timeB = DateTime.parse('${b['event']['date']} ${b['event']['start_hour']}');
      return timeA.compareTo(timeB);
    });

    DateTime firstEventStart = DateTime.parse('${events.first['event']['date']} ${events.first['event']['start_hour']}');
    DateTime lastEventEnd = DateTime.parse('${events.last['event']['date']} ${events.last['event']['end_hour']}');

    DateTime startTime = DateTime(
      firstEventStart.year, 
      firstEventStart.month, 
      firstEventStart.day, 
      firstEventStart.hour,
      (firstEventStart.minute ~/ 30) * 30
    ).subtract(const Duration(minutes: 30));

    DateTime endTime = DateTime(
      lastEventEnd.year, 
      lastEventEnd.month, 
      lastEventEnd.day, 
      lastEventEnd.hour,
      ((lastEventEnd.minute + 29) ~/ 30) * 30
    ).add(const Duration(minutes: 30));

    final totalHalfHours = endTime.difference(startTime).inMinutes ~/ 30;
    final List<List<Map<String, dynamic>>> eventGroups = [];
    List<Map<String, dynamic>> currentGroup = [];

    for (int i = 0; i < events.length; i++) {
      if (currentGroup.isEmpty) {
        currentGroup.add(events[i]);
      } else {
        final lastEventEnd = DateTime.parse('${currentGroup.last['event']['date']} ${currentGroup.last['event']['end_hour']}');
        final currentEventStart = DateTime.parse('${events[i]['event']['date']} ${events[i]['event']['start_hour']}');

        if (currentEventStart.isBefore(lastEventEnd)) {
          currentGroup.add(events[i]);
        } else {
          eventGroups.add(List.from(currentGroup));
          currentGroup.clear();
          currentGroup.add(events[i]);
        }
      }
    }

    if (currentGroup.isNotEmpty) {
      eventGroups.add(List.from(currentGroup));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 50, bottom: 0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: List.generate(totalHalfHours + 1, (index) {
                    final currentTime = startTime.add(Duration(minutes: 30 * index));
                    return SizedBox(
                      height: sizeTramo,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Transform.translate(
                          offset: const Offset(-5, -35),
                          child: Text(
                            DateFormat('HH:mm').format(currentTime),
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                Container(
                  width: 1,
                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            height: sizeTramo,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                                  width: 2.5,
                                ),
                                bottom: BorderSide(
                                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                                  width: 2.5,
                                ),
                              ),
                            ),
                          ),
                          ...List.generate(totalHalfHours - 1, (index) {
                            return Container(
                              height: sizeTramo,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                                    width: 2.5,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      ..._buildEventWidgetsVertical(eventGroups, startTime, isDarkMode, subjectColors),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEventWidgetsVertical(
    List<List<Map<String, dynamic>>> eventGroups,
    DateTime startTime,
    bool isDarkMode,
    SubjectColors subjectColors,
  ) {
    return eventGroups.map((group) {
      final firstEvent = group.first;
      final lastEvent = group.last;
      
      final groupStart = DateTime.parse('${firstEvent['event']['date']} ${firstEvent['event']['start_hour']}');
      final groupEnd = DateTime.parse('${lastEvent['event']['date']} ${lastEvent['event']['end_hour']}');
      
      final startOffset = groupStart.difference(startTime).inMinutes;
      final duration = groupEnd.difference(groupStart).inMinutes;
      
      final topPosition = (startOffset / 30) * sizeTramo + 2;
      final height = (duration / 30) * sizeTramo - 6;
      
      return Positioned(
        top: topPosition,
        height: height,
        left: 0,
        right: 4,
        child: Row(
          children: group.map((eventData) {
            final subjectName = eventData['subjectName'];
            final subjectColor = subjectColors.getSubjectColor(subjectName);
            
            return Expanded(
              child: EventCard(
                eventData: eventData,
                getGroupLabel: logic.getGroupLabel,
                subjectColor: subjectColor,
                isDarkMode: isDarkMode,
              ),
            );
          }).toList(),
        ),
      );
    }).toList();
  }
}

class ViewToggleFab extends StatelessWidget {
  final bool isDarkMode;
  final bool showGoogleView;
  final VoidCallback onPressed;

  const ViewToggleFab({
    super.key,
    required this.isDarkMode,
    required this.showGoogleView,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: showGoogleView ? 'Ver vista normal' : 'Ver vista Google',
      child: Icon(
        showGoogleView ? Icons.list : Icons.calendar_view_day,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }
}