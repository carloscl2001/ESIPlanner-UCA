import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'timetable_week_logic.dart';
import '../../../shared/widgets/class_cards.dart';

class WeekHeader extends StatelessWidget {
  final TimetableWeekLogic logic;
  final bool isDarkMode;

  const WeekHeader({super.key, required this.logic, required this.isDarkMode});

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
              borderRadius: BorderRadius.circular(16.0),
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
              borderRadius: BorderRadius.circular(16.0),
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

class WeekDaysHeader extends StatelessWidget {
  final TimetableWeekLogic logic;
  final bool isDarkMode;

  const WeekDaysHeader({super.key, required this.logic, required this.isDarkMode});

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
          color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.grey.withValues(alpha: 0.45) 
                : Colors.black.withValues(alpha: 0.45),
            blurRadius: 6.0,
            offset: const Offset(0, 3),
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
                  color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
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

class EventList extends StatelessWidget {
  final TimetableWeekLogic logic;
  final bool isDarkMode;

  const EventList({super.key, required this.logic, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final groupedByDate = logic.groupEventsByDate();
    final sortedDates = groupedByDate.keys.toList()..sort();

    if (groupedByDate.isEmpty) {
      return Center(
        child: Text(
          'No hay clases',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      );
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
                        color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
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
}