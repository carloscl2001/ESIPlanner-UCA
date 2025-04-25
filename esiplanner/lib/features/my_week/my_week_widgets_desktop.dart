import 'dart:ui';
import 'package:esiplanner/providers/theme_provider.dart';
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
        padding: const EdgeInsets.only(left: 70, top: 24, bottom: 24),
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 80,
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 8), // Más espacio entre botones
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

  EventListViewDesktop({
    super.key,
    required this.pageController,
    required this.weekDays,
    required this.getFilteredEvents,
    required this.subjects,
    required this.groupEventsByDay,
    required this.getGroupLabel,
    required this.onPageChanged,
  });

  // Mapa para mantener colores consistentes por asignatura
  final Map<String, Color> _subjectColors = {};

  Color _getSubjectColor(String subjectName, bool isDarkMode) {
    if (_subjectColors.containsKey(subjectName)) {
      return _subjectColors[subjectName]!;
    }
    
    final colors = isDarkMode 
      ? [
          Colors.blue.shade700,
          Colors.green.shade700,
          Colors.orange.shade700,
          Colors.purple.shade700,
          Colors.red.shade700,
          Colors.teal.shade700,
          Colors.indigo.shade700,
          Colors.amber.shade700,
        ]
      : [
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.red,
          Colors.teal,
          Colors.indigo,
          Colors.amber,
        ];
    
    final color = colors[_subjectColors.length % colors.length];
    _subjectColors[subjectName] = color;
    return color;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 2),
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
                  return _buildEmptyState(isDarkMode);
                }

                return _buildDayViewVertical(dayEvents, isDarkMode);
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

  Widget _buildDayViewVertical(List<Map<String, dynamic>> events, bool isDarkMode) {
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
      (firstEventStart.minute ~/ 30) * 30 // Redondea a la media hora anterior
    ).subtract(const Duration(minutes: 30)); // Resta media hora adicional

    DateTime endTime = DateTime(
      lastEventEnd.year, 
      lastEventEnd.month, 
      lastEventEnd.day, 
      lastEventEnd.hour,
      ((lastEventEnd.minute + 29) ~/ 30) * 30 // Redondea a la media hora siguiente
    ).add(const Duration(minutes: 30)); // Suma media hora adicional

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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna de horas - MODIFICADO para mostrar cada 30 minutos
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
                            offset: const Offset(-35, -35),
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
                // Línea vertical
                Container(
                  width: 1,
                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
                // Contenedor principal de eventos
                Expanded(
                  child: Stack(
                    children: [
                      // Líneas horizontales - MODIFICADO para incluir el primer tramo
                      Column(
                        children: [
                          // Primera línea (borde superior)
                          Container(
                            height: sizeTramo,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                                bottom: BorderSide(
                                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          // Resto de líneas
                          ...List.generate(totalHalfHours - 1, (index) {
                            final isFullHour = (index + 1) % 2 == 0;
                            return Container(
                              height: sizeTramo,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                                    width: isFullHour ? 1.5 : 0.5,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      // Eventos
                      ..._buildEventWidgetsVertical(eventGroups, startTime, isDarkMode),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEventWidgetsVertical(
    List<List<Map<String, dynamic>>> eventGroups,
    DateTime startTime,
    bool isDarkMode,
  ) {
    return eventGroups.map((group) {
      final firstEvent = group.first;
      final lastEvent = group.last;
      
      final groupStart = DateTime.parse('${firstEvent['event']['date']} ${firstEvent['event']['start_hour']}');
      final groupEnd = DateTime.parse('${lastEvent['event']['date']} ${lastEvent['event']['end_hour']}');
      
      // Ajustamos el cálculo para que no haya solapamiento visual
      final startOffset = groupStart.difference(startTime).inMinutes;
      final duration = groupEnd.difference(groupStart).inMinutes;
      
      // Añadimos 1 minuto de margen visual entre eventos
      final topPosition = (startOffset / 30) * sizeTramo + 2; // +1 pixel de margen superior
      final height = (duration / 30) * sizeTramo - 6; // -2 pixels para margen (1 arriba y 1 abajo)
      
      return Positioned(
        top: topPosition,
        height: height,
        left: 0,
        right: 16,
        child: Row(
          children: group.asMap().entries.map((entry) {
            final eventData = entry.value;
            final event = eventData['event'];
            final classType = eventData['classType'];
            final subjectName = eventData['subjectName'];
            final location = event['location'] ?? 'No especificado';
            final subjectColor = _getSubjectColor(subjectName, isDarkMode);
            
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 2, right: 2, top: 1, bottom: 1), // Margen ajustado
                decoration: BoxDecoration(
                  color: subjectColor.withOpacity(isDarkMode ? 0.3 : 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: subjectColor,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 8, top: 8, bottom: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subjectName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$classType - ${getGroupLabel(classType[0])}',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${event['start_hour']} - ${event['end_hour']}',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
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