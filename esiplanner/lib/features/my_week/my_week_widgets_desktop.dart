import 'dart:ui';

import 'package:esiplanner/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/class_cards.dart';

class SelectedDayRowDesktop extends StatelessWidget {
  final bool isDarkMode;
  final String selectedDay;
  final List<String> weekDaysFullName;
  final List<String> weekDaysShort;
  final String Function(int) getMonthName;

  const SelectedDayRowDesktop({
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                selectedDate.day.toString(),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 72,
                  height: 0.9,
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    weekDaysFullName[safeIndex].toUpperCase(),
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${getMonthName(selectedDate.month)} ${selectedDate.year}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.yellow.shade700 : Colors.blue.shade900,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode 
                        ? Colors.yellow.shade700.withOpacity(0.3)
                        : Colors.blue.shade900.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'TODAY',
                style: TextStyle(
                  color: isDarkMode ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 1.1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DayButtonRowDesktop extends StatelessWidget {
  final List<String> weekDays;
  final List<String> weekDates;
  final bool isDarkMode;
  final String selectedDay;
  final List<Map<String, dynamic>> Function(String?) getFilteredEvents;
  final List<Map<String, dynamic>> subjects;
  final Function(String) onDaySelected;

  const DayButtonRowDesktop({
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weekDays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final date = weekDates[index];
          final hasEvents = getFilteredEvents(day).isNotEmpty;
          final isSelected = selectedDay == day;
    
          return GestureDetector(
            onTap: () => onDaySelected(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDarkMode ? Colors.yellow.shade700 : Colors.blue.shade900)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                      ? Colors.transparent
                      : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day,
                    style: TextStyle(
                      color: isSelected
                          ? (isDarkMode ? Colors.black : Colors.white)
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date,
                    style: TextStyle(
                      color: isSelected
                          ? (isDarkMode ? Colors.black : Colors.white)
                          : (isDarkMode ? Colors.white : Colors.black),
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                  if (hasEvents)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDarkMode ? Colors.black : Colors.white)
                            : (isDarkMode ? Colors.yellow.shade700 : Colors.blue.shade900),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class EventListViewDesktop extends StatelessWidget {
  final PageController pageController;
  final List<String> weekDays;
  final List<Map<String, dynamic>> Function(String?) getFilteredEvents;
  final List<Map<String, dynamic>> subjects;
  final Map<String, List<Map<String, dynamic>>> Function(List<Map<String, dynamic>>) groupEventsByDay;
  final String Function(String) getGroupLabel;
  final Function(int) onPageChanged;

  const EventListViewDesktop({
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

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isDarkMode ? Colors.grey.shade900.withOpacity(0.6) : Colors.grey.shade100,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: ScrollConfiguration(
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 60,
                          color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No classes scheduled',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Enjoy your free time!',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final groupedEvents = groupEventsByDay(dayEvents);
                final sortedDates = groupedEvents.keys.toList()..sort();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            date,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
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
                            classType: '$classType - ${getGroupLabel(classType[0])}',
                            event: event,
                            isOverlap: isOverlapping[index],
                            isDesktop: true,
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class BuildEmptyCardDesktop extends StatelessWidget {
  const BuildEmptyCardDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    
    return Center(
      child: SizedBox(
        width: 500,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      size: 80,
                      color: Theme.of(context).disabledColor,
                    ),
                    Icon(
                      Icons.arrow_right_rounded, 
                      size: 80, 
                      color: Theme.of(context).disabledColor
                    ),
                    Icon(
                      Icons.edit_note_rounded,
                      size: 80,
                      color: Theme.of(context).disabledColor,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  'Select Subjects in Profile',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).disabledColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Add your subjects to see your schedule here',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to profile
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.yellow.shade700 : Colors.blue.shade900,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Go to Profile',
                    style: TextStyle(
                      color: isDarkMode ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}