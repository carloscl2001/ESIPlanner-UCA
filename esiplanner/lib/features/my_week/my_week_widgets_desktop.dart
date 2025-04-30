import 'dart:ui';
import 'package:esiplanner/providers/theme_provider.dart';
import 'package:esiplanner/shared/widgets/event_card.dart';
import 'package:esiplanner/utils.dart/subject_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
      padding: const EdgeInsets.only(left: 70, top: 12, bottom: 12),
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
                    weekDaysFullName[safeIndex],
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${getMonthName(selectedDate.month)} ${selectedDate.year}',
                    style: TextStyle(
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.yellow.shade700 : Colors.blue.shade900,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Hoy',
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
            child: Container(
              width: 80,
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 8), // Más espacio entre botones
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
                borderRadius: BorderRadius.circular(20),
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
                  Text(
                    date,
                    style: TextStyle(
                      color: isSelected
                          ? (isDarkMode ? Colors.black : Colors.white)
                          : (isDarkMode ? Colors.white : Colors.black),
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  if (hasEvents)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 6,
                      height: 6,
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
  final double sizeTramo = 65;

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
    final subjectColors = SubjectColors(isDarkMode);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isDarkMode ? Colors.grey.shade900.withAlpha(153) : Colors.grey.shade100, // 0.6 opacity equivalent
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
                  return _buildEmptyState(isDarkMode);
                }

                return _buildDayViewVertical(dayEvents, isDarkMode, subjectColors);
              },
            ),
          ),
        ),
      ),
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
        padding: const EdgeInsets.only(left: 15, right: 10, top: 50, bottom: 0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: Column(
                    children: List.generate(totalHalfHours + 1, (index) {
                      final currentTime = startTime.add(Duration(minutes: 30 * index));
                      return SizedBox(
                        height: sizeTramo,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Transform.translate(
                            offset: const Offset(-30, -33),
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
        right: 10,
        child: Row(
          children: group.map((eventData) {
            final subjectName = eventData['subjectName'];
            final subjectColor = subjectColors.getSubjectColor(subjectName);
            
            return Expanded(
              child: EventCard(
                eventData: eventData,
                getGroupLabel: getGroupLabel,
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

class BuildEmptyCardDesktop extends StatelessWidget {
  const BuildEmptyCardDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white70 : Colors.black54;
    
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        margin: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 120,
              color: textColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Planifica tu horario',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Selecciona tus asignaturas en la sección de perfil para comenzar a visualizar tu horario semanal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // Navegar a la sección de perfil
              },
              icon: const Icon(Icons.person),
              label: const Text('Ir a Perfil'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}