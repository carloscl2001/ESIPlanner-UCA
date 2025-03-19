import 'package:flutter/material.dart';
import '../widgets/class_cards.dart';
import 'package:intl/intl.dart';

class WeekClassesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final int selectedWeekIndex;
  final bool isDarkMode;

  const WeekClassesScreen({
    super.key,
    required this.events,
    required this.selectedWeekIndex,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clases de la semana ${selectedWeekIndex + 1}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildEventList(isDarkMode),
    );
  }

  Widget _buildEventList(bool isDarkMode) {
    if (events.isEmpty) {
      return Center(
        child: Text(
          'No hay clases esta semana',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      );
    }

    final groupedByDate = <String, List<Map<String, dynamic>>>{};
    for (var eventData in events) {
      final eventDate = eventData['event']['date'];
      groupedByDate.putIfAbsent(eventDate, () => []).add(eventData);
    }

    final sortedDates = groupedByDate.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final events = groupedByDate[date]!..sort((a, b) {
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
            Text(
              _formatDateToFullDate(DateTime.parse(date)),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
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
                classType: '$classType - ${_getGroupLabel(classType[0])}',
                event: event,
                isOverlap: isOverlapping[index],
              );
            }),
          ],
        );
      },
    );
  }

  String _formatDateToFullDate(DateTime date) {
    return DateFormat('EEEE d MMMM y', 'es_ES').format(date);
  }

  String _getGroupLabel(String letter) {
    switch (letter) {
      case 'A':
        return 'Clase de teoría';
      case 'B':
        return 'Clase de problemas';
      case 'C':
        return 'Clase de prácticas informáticas';
      case 'D':
        return 'Clase de laboratorio';
      case 'X':
        return 'Clase de teórico-práctica';
      default:
        return 'Clase de teórico-práctica';
    }
  }
}