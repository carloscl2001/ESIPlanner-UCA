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
      padding: const EdgeInsets.only(left: 60, top: 10, bottom: 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weekDays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final date = weekDates[index];
          final hasEvents = getFilteredEvents(day).isNotEmpty;
          final isSelected = selectedDay == day;
          final selectedColor = isDarkMode ? Colors.yellow.shade700 : Colors.blue.shade900;
          final unselectedColor = isDarkMode ? Colors.black : Colors.white;

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: FocusableActionDetector(
              mouseCursor: SystemMouseCursors.click,
              onShowHoverHighlight: (value) {},
              child: GestureDetector(
                onTap: () => onDaySelected(day),
                child: Container(
                  width: 80,
                  height: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? selectedColor : null,
                    gradient: !isSelected
                        ? LinearGradient(
                            colors: [unselectedColor, unselectedColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      hoverColor: isSelected 
                          ? selectedColor.withValues(alpha: 0.8)
                          : (isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200),
                      onTap: () => onDaySelected(day),
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
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class EventListViewDesktopGoogle extends StatelessWidget {
  final PageController pageController;
  final List<String> weekDays;
  final List<Map<String, dynamic>> Function(String?) getFilteredEvents;
  final List<Map<String, dynamic>> subjects;
  final Map<String, List<Map<String, dynamic>>> Function(List<Map<String, dynamic>>) groupEventsByDay;
  final String Function(String) getGroupLabel;
  final Function(int) onPageChanged;
  final double sizeTramo = 65;

  const EventListViewDesktopGoogle({
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

    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? Colors.yellow.shade700 : Colors.blue.shade900,
            width: 3.0,
          ),
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
        padding: const EdgeInsets.only(left: 12, right: 12, top: 0, bottom: 30),
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
                          offset: const Offset(-5, 31),
                          child: Text(
                            DateFormat('HH:mm').format(currentTime),
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                // Área de eventos
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final availableWidth = constraints.maxWidth;
                      return Stack(
                        children: [
                          // Líneas horizontales de la grid
                          Column(
                            children: List.generate(totalHalfHours + 1, (index) {
                              return Container(
                                height: sizeTramo,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color:  isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          // Eventos posicionados
                          ...processedEvents.map((event) {
                            final placement = eventLanesPlacement[event]!;
                            final laneStart = placement['start']!;
                            final laneEnd = placement['end']!;
                            final startOffset = event['start'].difference(startTime).inMinutes;
                            final duration = event['end'].difference(event['start']).inMinutes;

                            // Determinar si el evento está solapado
                            final isOverlapping = lanes.any((lane) => 
                                lane.any((e) => 
                                    e != event && 
                                    event['start'].isBefore(e['end']) && 
                                    event['end'].isAfter(e['start']))
                            );

                            final laneWidth = availableWidth / (isOverlapping ? maxLanes : 1);
                            final leftPosition = isOverlapping ? laneStart * laneWidth : 0;
                            final eventWidth = isOverlapping ? (laneEnd - laneStart) * laneWidth : availableWidth;

                            return Positioned(
                              top: ((startOffset / 30) + 1) * sizeTramo + 2, // <- Añadimos +1 para mover un tramo hacia abajo
                              left: leftPosition + 2,
                              width: eventWidth - 4,
                              height: (duration / 30) * sizeTramo - 6,
                              child: EventCard(
                                eventData: event['data'],
                                getGroupLabel: getGroupLabel,
                                subjectColor: subjectColors.getSubjectColor(event['subject']),
                                isDarkMode: isDarkMode,
                              ),
                            );
                          }),
                        ],
                      );
                    },
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