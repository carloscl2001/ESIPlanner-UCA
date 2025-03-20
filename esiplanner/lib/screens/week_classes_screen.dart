import 'package:flutter/material.dart';
import '../widgets/class_cards.dart';
import 'package:intl/intl.dart';

class WeekClassesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final int selectedWeekIndex;
  final bool isDarkMode;
  final DateTime weekStartDate; // Fecha de inicio de la semana
  final List<String> _weekDays = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie'];

  WeekClassesScreen({
    super.key,
    required this.events,
    required this.selectedWeekIndex,
    required this.isDarkMode,
    required this.weekStartDate, // Recibir la fecha de inicio de la semana
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis clases de la semana'), // Título de la pantalla
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildWeekHeader(context), // Encabezado con el mes y el año
          _buildWeekDaysHeader(context), // Días de la semana con números
          Expanded(
            child: _buildEventList(context), // Lista de eventos
          ),
        ],
      ),
    );
  }

  // Encabezado con el mes y el año
  Widget _buildWeekHeader(BuildContext context) {
    final startOfWeek = _getStartOfWeek(weekStartDate); // Usar la fecha de inicio de la semana
    final endOfWeek = startOfWeek.add(const Duration(days: 4)); // Viernes de la semana

    final startMonth = DateFormat('MMMM', 'es_ES').format(startOfWeek);
    final endMonth = DateFormat('MMMM', 'es_ES').format(endOfWeek);
    final startYear = DateFormat('y', 'es_ES').format(startOfWeek);
    final endYear = DateFormat('y', 'es_ES').format(endOfWeek);

    final showTwoMonths = startMonth != endMonth;
    final showTwoYears = startYear != endYear;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Mes(es)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Text(
              showTwoMonths ? '$startMonth - $endMonth' : startMonth, // Mostrar dos meses si es necesario
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.black : Colors.white,
              ),
            ),
          ),
          // Año(s)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Text(
              showTwoYears ? '$startYear - $endYear' : startYear, // Mostrar dos años si es necesario
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

  // Encabezado con los días de la semana y los números
  Widget _buildWeekDaysHeader(BuildContext context) {
    final startOfWeek = _getStartOfWeek(weekStartDate); // Usar la fecha de inicio de la semana

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.grey.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.45),
            blurRadius: 6.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final day = startOfWeek.add(Duration(days: index));
          return Column(
            children: [
              Text(
                _weekDays[index], // Usar el vector _weekDays para mostrar los días abreviados
                style: TextStyle(
                  color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4), // Espacio entre el nombre del día y el número
              Text(
                DateFormat('d', 'es_ES').format(day), // Número del día (25, 26, etc.)
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

  // Resto del código de WeekClassesScreen (sin cambios)
  Widget _buildEventList(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: 
          Text(
            'No hay clases',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? Colors.white
                  : Colors.black,
            ),
          )
      );
    }

    final groupedByDate = _groupEventsByDate(events);
    final sortedDates = groupedByDate.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final events = groupedByDate[date]!..sort(_sortEventsByTime);
        final isOverlapping = _calculateOverlappingEvents(events);

        return Padding(
          padding: const EdgeInsets.only(top: 10.0), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  _formatDateToFullDate(DateTime.parse(date)),
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
                  classType: '$classType - ${_getGroupLabel(classType[0])}',
                  event: event,
                  isOverlap: isOverlapping[index],
                );
              }),
              const SizedBox(height: 20), // Espacio entre las fechas
            ],
          ),
        );
      },
    );
  }

  // Métodos auxiliares (sin cambios)
  Map<String, List<Map<String, dynamic>>> _groupEventsByDate(List<Map<String, dynamic>> events) {
    final groupedByDate = <String, List<Map<String, dynamic>>>{};
    for (var eventData in events) {
      final eventDate = eventData['event']['date'];
      groupedByDate.putIfAbsent(eventDate, () => []).add(eventData);
    }
    return groupedByDate;
  }

  int _sortEventsByTime(Map<String, dynamic> a, Map<String, dynamic> b) {
    final timeA = DateTime.parse('${a['event']['date']} ${a['event']['start_hour']}');
    final timeB = DateTime.parse('${b['event']['date']} ${b['event']['start_hour']}');
    return timeA.compareTo(timeB);
  }

  List<bool> _calculateOverlappingEvents(List<Map<String, dynamic>> events) {
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

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatDateToFullDate(DateTime date) {
    final formattedDate = DateFormat('EEEE', 'es_ES').format(date);
    return _capitalize(formattedDate);
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
        return 'Clase de teoría-práctica';
      default:
        return 'Clase de teoría-práctica';
    }
  }

  DateTime _getStartOfWeek(DateTime date) {
    // Asegurarnos de que la fecha esté en el huso horario local
    final localDate = DateTime.utc(date.year, date.month, date.day);
    // Restar (localDate.weekday - 1) días para obtener el lunes de la semana
    return localDate.subtract(Duration(days: localDate.weekday - 1));
  }
}