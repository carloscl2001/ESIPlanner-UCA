import 'package:intl/intl.dart';

class TimetableWeekLogic {
  final List<Map<String, dynamic>> events;
  final DateTime weekStartDate;
  List<String> get weekDays => _weekDays;
  final List<String> _weekDays = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie'];

  TimetableWeekLogic({
    required this.events,
    required this.weekStartDate,
  });

  // Métodos de agrupación y ordenamiento
  Map<String, List<Map<String, dynamic>>> groupEventsByDate() {
    final groupedByDate = <String, List<Map<String, dynamic>>>{};
    for (var eventData in events) {
      final eventDate = eventData['event']['date'];
      groupedByDate.putIfAbsent(eventDate, () => []).add(eventData);
    }
    return groupedByDate;
  }

  int sortEventsByTime(Map<String, dynamic> a, Map<String, dynamic> b) {
    final timeA = DateTime.parse('${a['event']['date']} ${a['event']['start_hour']}');
    final timeB = DateTime.parse('${b['event']['date']} ${b['event']['start_hour']}');
    return timeA.compareTo(timeB);
  }

  // Métodos de formato
  String formatDateToFullDate(DateTime date) {
    final formattedDate = DateFormat('EEEE', 'es_ES').format(date);
    return _capitalize(formattedDate);
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Métodos de cálculo
  List<bool> calculateOverlappingEvents(List<Map<String, dynamic>> events) {
    final isOverlapping = List<bool>.filled(events.length, false);
    for (int i = 0; i < events.length - 1; i++) {
      final endTimeCurrent = DateTime.parse('${events[i]['event']['date']} ${events[i]['event']['end_hour']}');
      final startTimeNext = DateTime.parse('${events[i + 1]['event']['date']} ${events[i + 1]['event']['start_hour']}');

      if (endTimeCurrent.isAfter(startTimeNext)) {
        isOverlapping[i] = true;
        isOverlapping[i + 1] = true;
      }
    }
    return isOverlapping;
  }

  // Métodos para el header
  Map<String, String> getWeekHeaderInfo() {
    final startOfWeek = _getStartOfWeek(weekStartDate);
    final endOfWeek = startOfWeek.add(const Duration(days: 4));

    return {
      'startMonth': DateFormat('MMMM', 'es_ES').format(startOfWeek),
      'endMonth': DateFormat('MMMM', 'es_ES').format(endOfWeek),
      'startYear': DateFormat('y', 'es_ES').format(startOfWeek),
      'endYear': DateFormat('y', 'es_ES').format(endOfWeek),
    };
  }

  List<DateTime> getWeekDays() {
    final startOfWeek = _getStartOfWeek(weekStartDate);
    return List.generate(5, (index) => startOfWeek.add(Duration(days: index)));
  }

  DateTime _getStartOfWeek(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day).subtract(Duration(days: date.weekday - 1));
  }

  String getGroupLabel(String letter) {
    switch (letter) {
      case 'A': return 'Clase de teoría';
      case 'B': return 'Clase de problemas';
      case 'C': return 'Clase de prácticas informáticas';
      case 'D': return 'Clase de laboratorio';
      case 'E': return 'Salida de campo';
      case 'X': return 'Clase de teoría-práctica';
      default: return 'Clase de teoría-práctica';
    }
  }
}