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
      padding: const EdgeInsets.only(bottom: 20.0, top: 20.0, left: 40.0, right: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[400],
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Text(
              showTwoMonths 
                  ? '${headerInfo['startMonth']} - ${headerInfo['endMonth']}'
                  : headerInfo['startMonth']!,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[400],
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Text(
              showTwoYears
                  ? '${headerInfo['startYear']} - ${headerInfo['endYear']}'
                  : headerInfo['startYear']!,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeekDaysHeaderDesktop extends StatelessWidget {
  final TimetableWeekLogic logic;
  final bool isDarkMode;

  const WeekDaysHeaderDesktop({super.key, required this.logic, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final weekDays = logic.getWeekDays();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.grey.withOpacity(0.6) 
                : Colors.black.withOpacity(0.3),
            blurRadius: 10.0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: List.generate(5, (index) {
          final day = weekDays[index];
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isDarkMode ? Colors.black : Colors.grey[100],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    logic.weekDays[index],
                    style: TextStyle(
                      color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('d', 'es_ES').format(day),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
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
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode 
                        ? Colors.grey.withOpacity(0.4) 
                        : Colors.black.withOpacity(0.2),
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      logic.formatDateToFullDate(day),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Divider(height: 1),
                  if (events.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No hay clases',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: events.length,
                        itemBuilder: (context, idx) {
                          final eventData = events[idx];
                          final event = eventData['event'];
                          final classType = eventData['classType'];
                          final subjectName = eventData['subjectName'];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
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