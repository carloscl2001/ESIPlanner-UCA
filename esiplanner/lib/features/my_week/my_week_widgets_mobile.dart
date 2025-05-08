import 'dart:ui';

import 'package:esiplanner/providers/theme_provider.dart';
import 'package:esiplanner/shared/widgets/event_card.dart';
import 'package:esiplanner/utils.dart/subject_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/class_cards.dart';

class SelectedDayRowMobile extends StatelessWidget {
  final bool isDarkMode;
  final String selectedDay;
  final List<String> weekDaysFullName;
  final List<String> weekDaysShort;
  final String Function(int) getMonthName;

  const SelectedDayRowMobile({
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
      padding: EdgeInsets.only(
        left: 14, 
        right: 8, 
        top: 8, 
        bottom: 8
      ),
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
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weekDaysFullName[safeIndex],
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize:  20,
                    ),
                  ),
                  Text(
                    '${getMonthName(selectedDate.month)} ${selectedDate.year}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize:  20,
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
              padding: EdgeInsets.symmetric(
                horizontal: 16, 
                vertical: 8
              ),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.yellow.shade700 : Colors.blue.shade900,
                borderRadius: BorderRadius.circular(20),
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

class DayButtonRowMobile extends StatelessWidget {
  final List<String> weekDays;
  final List<String> weekDates;
  final bool isDarkMode;
  final String selectedDay;
  final List<Map<String, dynamic>> Function(String?) getFilteredEvents;
  final List<Map<String, dynamic>> subjects;
  final Function(String) onDaySelected;

  const DayButtonRowMobile({
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
          padding: EdgeInsets.symmetric(horizontal: 8),
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
                    margin: EdgeInsets.symmetric(horizontal: 6),
                    padding: EdgeInsets.symmetric(
                      vertical: 10, 
                      horizontal: 10
                    ),
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
                            SizedBox(height: 4),
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
                                    : (isDarkMode ? Colors.yellow.shade700: Colors.blue.shade900),
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

class EventListViewMobile extends StatelessWidget {
  final PageController pageController;
  final List<String> weekDays;
  final List<Map<String, dynamic>> Function(String?) getFilteredEvents;
  final List<Map<String, dynamic>> subjects;
  final Map<String, List<Map<String, dynamic>>> Function(List<Map<String, dynamic>>) groupEventsByDay;
  final String Function(String) getGroupLabel;
  final Function(int) onPageChanged;

  const EventListViewMobile({
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

          final groupedEvents = groupEventsByDay(dayEvents);
          final sortedDates = groupedEvents.keys.toList()..sort();

          return ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 0
            ),
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

class EventListViewMobileGoogle extends StatelessWidget {
  final PageController pageController;
  final List<String> weekDays;
  final List<Map<String, dynamic>> Function(String?) getFilteredEvents;
  final List<Map<String, dynamic>> subjects;
  final Map<String, List<Map<String, dynamic>>> Function(List<Map<String, dynamic>>) groupEventsByDay;
  final String Function(String) getGroupLabel;
  final Function(int) onPageChanged;
  final double sizeTramo = 65;

  const EventListViewMobileGoogle({
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

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900.withAlpha(153) : Colors.white,
      ),
      child: ClipRRect(
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

              return _buildDayViewGoogleStyle(dayEvents, isDarkMode, subjectColors);
            },
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
        ],
      ),
    );
  }

  Widget _buildDayViewGoogleStyle(
    List<Map<String, dynamic>> events,
    bool isDarkMode,
    SubjectColors subjectColors,
  ) {
    // Procesamiento inicial de eventos
    final processedEvents = events.map((e) {
      final start = DateTime.parse('${e['event']['date']} ${e['event']['start_hour']}');
      final end = DateTime.parse('${e['event']['date']} ${e['event']['end_hour']}');
      return {
        'data': e,
        'start': start,
        'end': end,
        'subject': e['subjectName'],
      };
    }).toList();

    // Ordenar eventos por hora de inicio
    processedEvents.sort((a, b) => a['start'].compareTo(b['start']));

    if (processedEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    final firstEventStart = processedEvents.first['start'];
    final lastEventEnd = processedEvents.last['end'];

    DateTime startTime = DateTime(
      firstEventStart.year,
      firstEventStart.month,
      firstEventStart.day,
      firstEventStart.hour,
      (firstEventStart.minute ~/ 30) * 30,
    ).subtract(const Duration(minutes: 30));

    DateTime endTime = DateTime(
      lastEventEnd.year,
      lastEventEnd.month,
      lastEventEnd.day,
      lastEventEnd.hour,
      ((lastEventEnd.minute + 29) ~/ 30) * 30,
    ).add(const Duration(minutes: 30));

    final totalHalfHours = endTime.difference(startTime).inMinutes ~/ 30;

    // Algoritmo de distribución de eventos mejorado
    final List<List<Map<String, dynamic>>> lanes = [];
    final Map<Map<String, dynamic>, Map<String, int>> eventLanesPlacement = {};

    for (final event in processedEvents) {
      int bestLane = -1;
      for (int i = 0; i < lanes.length; i++) {
        bool canPlace = true;
        for (final existingEvent in lanes[i]) {
          if (event['start'].isBefore(existingEvent['end']) && event['end'].isAfter(existingEvent['start'])) {
            canPlace = false;
            break;
          }
        }
        if (canPlace) {
          bestLane = i;
          break;
        }
      }

      if (bestLane != -1) {
        lanes[bestLane].add(event);
        eventLanesPlacement[event] = {'start': bestLane, 'end': bestLane + 1};
      } else {
        lanes.add([event]);
        eventLanesPlacement[event] = {'start': lanes.length - 1, 'end': lanes.length};
      }
    }

    // Calcular el número máximo de carriles ocupados en cualquier momento
    int maxLanes = lanes.length;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 50, bottom: 0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline izquierda
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
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 8),
                // Línea vertical de timeline
                Container(
                  width: 1,
                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
                const SizedBox(width: 8),
                // Área de eventos
                Expanded(
                  child: Stack(
                    children: [
                      // Líneas horizontales de la grid
                      Column(
                        children: List.generate(totalHalfHours + 1, (index) {
                          return Container(
                            height: sizeTramo,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                                  width: 0.5,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      // Eventos posicionados
                      ...processedEvents.map((event) {
                        final placement = eventLanesPlacement[event]!;
                        final laneStart = placement['start'];
                        final laneEnd = placement['end'];
                        final startOffset = event['start'].difference(startTime).inMinutes;
                        final duration = event['end'].difference(event['start']).inMinutes;

                        final eventWidthFactor = maxLanes > 0 ? (1 / maxLanes) : 1;
                        final eventLeftFactor = maxLanes > 0 ? (laneStart !/ maxLanes) : 0;

                        final leftPosition = eventLeftFactor * 100;
                        final eventWidth = (laneEnd !- laneStart!) * eventWidthFactor * 100;

                        return Positioned(
                          top: (startOffset / 30) * sizeTramo + 2,
                          left: leftPosition + 2,
                          width: eventWidth - 4,
                          height: (duration / 30) * sizeTramo - 4,
                          child: EventCard(
                            eventData: event['data'],
                            getGroupLabel: getGroupLabel,
                            subjectColor: subjectColors.getSubjectColor(event['subject']),
                            isDarkMode: isDarkMode,
                          ),
                        );
                      }),
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
}

class BuildEmptyCardMobile extends StatelessWidget {
  const BuildEmptyCardMobile({super.key});

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
                Navigator.pushNamed(context, '/selectionSubjects');
              },
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Seleccionar asignaturas'),
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