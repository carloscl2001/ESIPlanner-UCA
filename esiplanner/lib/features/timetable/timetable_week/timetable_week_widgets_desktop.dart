import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'timetable_week_logic.dart';
import '../../../shared/widgets/class_cards.dart';

class WeekHeaderDesktop extends StatelessWidget {
  final TimetableWeekLogic logic;
  final bool isDarkMode;

  const WeekHeaderDesktop({super.key, required this.logic, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final headerInfo = logic.getWeekHeaderInfo();
    final showTwoMonths = headerInfo['startMonth'] != headerInfo['endMonth'];
    final showTwoYears = headerInfo['startYear'] != headerInfo['endYear'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 0, top: 10.0, left: 30.0, right: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.grey,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode 
                      ? Colors.grey.withValues(alpha: 0.4) 
                      : Colors.black.withValues(alpha: 0.5),
                  blurRadius: 4.0,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Text(
              showTwoMonths 
                  ? '${headerInfo['startMonth']} - ${headerInfo['endMonth']}'
                  : headerInfo['startMonth']!,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.white,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.grey,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode 
                      ? Colors.grey.withValues(alpha: 0.4) 
                      : Colors.black.withValues(alpha: 0.5),
                  blurRadius: 4.0,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Text(
              showTwoYears
                  ? '${headerInfo['startYear']} - ${headerInfo['endYear']}'
                  : headerInfo['startYear']!,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventListDesktop extends StatelessWidget {
  final TimetableWeekLogic logic;
  final bool isDarkMode;

  const EventListDesktop({super.key, required this.logic, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final weekDays = logic.getWeekDays();
    final groupedByDate = logic.groupEventsByDate();

    if (groupedByDate.isEmpty) {
      return Center(
        child: Text(
          'No hay clases esta semana',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(5, (index) {
          final day = weekDays[index];
          final dateKey = DateFormat('yyyy-MM-dd').format(day);
          final events = groupedByDate[dateKey] ?? [];
          events.sort(logic.sortEventsByTime);
          final isOverlapping = logic.calculateOverlappingEvents(events);

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode 
                        ? Colors.grey.withValues(alpha: 0.4) 
                        : Colors.black.withValues(alpha: 0.7),
                    blurRadius: 8.0,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header with day name and number
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.black : Colors.blue.shade900,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                           '${DateFormat('EEEE', 'es_ES').format(day)[0].toUpperCase()}${DateFormat('EEEE', 'es_ES').format(day).substring(1)}',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('d', 'es_ES').format(day),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (events.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No hay clases',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: events.length,
                        itemBuilder: (context, idx) {
                          final eventData = events[idx];
                          final event = eventData['event'];
                          final classType = eventData['classType'];
                          final subjectName = eventData['subjectName'];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 0.0),
                            child: ClassCards(
                              subjectName: subjectName,
                              classType: '$classType - ${logic.getGroupLabel(classType[0])}',
                              event: event,
                              isOverlap: isOverlapping[idx],
                              isDesktop: true,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}