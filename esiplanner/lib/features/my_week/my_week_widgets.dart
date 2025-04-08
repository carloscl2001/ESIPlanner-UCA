import 'dart:ui';

import 'package:esiplanner/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/class_cards.dart';

class SelectedDayRow extends StatelessWidget {
  final bool isDarkMode;
  final String selectedDay;
  final List<String> weekDaysFullName;
  final List<String> weekDaysShort;
  final String Function(int) getMonthName;

  const SelectedDayRow({
    super.key,
    required this.isDarkMode,
    required this.selectedDay,
    required this.weekDaysFullName,
    required this.weekDaysShort,
    required this.getMonthName,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    // Encuentra el índice seguro
    final selectedDayLower = selectedDay.toLowerCase();
    final safeIndex = weekDaysShort.indexWhere(
      (day) => day.toLowerCase() == selectedDayLower.substring(0, 3),
    ).clamp(0, weekDaysFullName.length - 1);

    final selectedDate = DateTime.utc(
      now.year, 
      now.month, 
      now.day - (now.weekday - 1) + safeIndex
    );
    
    final isToday = selectedDate.year == now.year && 
                   selectedDate.month == now.month && 
                   selectedDate.day == now.day;

    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 8, top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                selectedDate.day.toString(),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 55,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weekDaysFullName[safeIndex],
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    '${getMonthName(selectedDate.month)} ${selectedDate.year}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isToday)
            Container(
              margin: const EdgeInsets.only(right: 8),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.yellow.shade700 : Colors.blue.shade900,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Hoy',
                style: TextStyle(
                  color: isDarkMode ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DayButtonRow extends StatelessWidget {
  final List<String> weekDays;
  final List<String> weekDates;
  final bool isDarkMode;
  final String selectedDay;
  final List<Map<String, dynamic>> Function(String?) getFilteredEvents;
  final List<Map<String, dynamic>> subjects;
  final Function(String) onDaySelected;

  const DayButtonRow({
    super.key,
    required this.weekDays,
    required this.weekDates,
    required this.isDarkMode,
    required this.selectedDay,
    required this.getFilteredEvents,
    required this.subjects,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: weekDays.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              final date = weekDates[index];
              final hasEvents = getFilteredEvents(day).isNotEmpty;
          
              return Expanded(
                child: GestureDetector(
                  onTap: () => onDaySelected(day),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: selectedDay == day
                          ? (isDarkMode ? Colors.yellow.shade700 : Colors.blue.shade900)
                          : null,
                      gradient: selectedDay != day
                          ? (isDarkMode
                              ? LinearGradient(
                                  colors: [Colors.black, Colors.black],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [Colors.white, Colors.white],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ))
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: !isDarkMode
                              ? Colors.black.withAlpha(115)
                              : Colors.grey.withAlpha(115),
                          blurRadius: 8.0,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              day,
                              style: TextStyle(
                                color: selectedDay == day
                                    ? (isDarkMode ? Colors.black : Colors.white)
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              date,
                              style: TextStyle(
                                color: selectedDay == day
                                    ? (isDarkMode ? Colors.black : Colors.white)
                                    : (isDarkMode ? Colors.white : Colors.black),
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                        if (hasEvents)
                          Positioned(
                            bottom: 0,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: selectedDay == day
                                    ? (isDarkMode ? Colors.black : Colors.white)
                                    : (isDarkMode ? Colors.white : Colors.black),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class EventListView extends StatelessWidget {
  final PageController pageController;
  final List<String> weekDays;
  final List<Map<String, dynamic>> Function(String?) getFilteredEvents;
  final List<Map<String, dynamic>> subjects;
  final Map<String, List<Map<String, dynamic>>> Function(List<Map<String, dynamic>>) groupEventsByDay;
  final String Function(String) getGroupLabel;
  final Function(int) onPageChanged;

  const EventListView({
    super.key,
    required this.pageController,
    required this.weekDays,
    required this.getFilteredEvents,
    required this.subjects,
    required this.groupEventsByDay,
    required this.getGroupLabel,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      child: PageView.builder(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const PageScrollPhysics().applyTo(const BouncingScrollPhysics()),
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final day = weekDays[index];
          final dayEvents = getFilteredEvents(day);

          if (dayEvents.isEmpty) {
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

          final groupedEvents = groupEventsByDay(dayEvents);
          final sortedDates = groupedEvents.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final events = groupedEvents[date]!..sort((a, b) {
                final timeA = DateTime.parse('${a['event']['date']} ${a['event']['start_hour']}');
                final timeB = DateTime.parse('${b['event']['date']} ${b['event']['start_hour']}');
                return timeA.compareTo(timeB);
              });

              final isOverlapping = List<bool>.filled(events.length, false);
              for (int i = 0; i < events.length - 1; i++) {
                final endTimeCurrent = DateTime.parse('${events[i]['event']['date']} ${events[i]['event']['end_hour']}');
                final startTimeNext = DateTime.parse('${events[i + 1]['event']['date']} ${events[i + 1]['event']['start_hour']}');

                if (endTimeCurrent.isAfter(startTimeNext)) {
                  isOverlapping[i] = true;
                  isOverlapping[i + 1] = true;
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: events.asMap().entries.map((entry) {
                  final index = entry.key;
                  final eventData = entry.value;
                  final event = eventData['event'];
                  final classType = eventData['classType'];
                  final subjectName = eventData['subjectName'];
              
                  return ClassCards(
                    subjectName: subjectName,
                    classType: '$classType - ${getGroupLabel(classType[0])}',
                    event: event,
                    isOverlap: isOverlapping[index],
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}

class BuildEmptyCard extends StatelessWidget {
  const BuildEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 64,
                    color: Theme.of(context).disabledColor,
                  ),
                  Icon(Icons.arrow_right_rounded, size: 64, color: Theme.of(context).disabledColor),
                  Icon(
                    Icons.edit_note_rounded,
                    size: 64,
                    color: Theme.of(context).disabledColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Selecciona asignaturas en perfil',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}