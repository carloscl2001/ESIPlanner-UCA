import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/profile_service.dart';
import '../services/subject_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/class_cards.dart';
import '../providers/theme_provider.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  late ProfileService _profileService;
  late SubjectService _subjectService;

  bool _isLoading = true;
  List<Map<String, dynamic>> _subjects = [];
  String _errorMessage = '';

  int _selectedWeekIndex = 0;
  List<DateTimeRange> _weekRanges = [];
  List<String> _weekLabels = [];

  bool _showWeeks = true; // Controla si se muestran todas las semanas o solo la actual

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService();
    _subjectService = SubjectService();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final username = Provider.of<AuthProvider>(context, listen: false).username;

    if (username == null) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Usuario no autenticado';
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final profileData = await _profileService.getProfileData(username: username);
      final degree = profileData["degree"];
      final userSubjects = profileData["subjects"] ?? [];

      if (degree == null || userSubjects.isEmpty) {
        setState(() {
          _errorMessage = degree == null
              ? 'No se encontró el grado en los datos del perfil'
              : 'El usuario no tiene asignaturas';
          _isLoading = false;
        });
        return;
      }

      final updatedSubjects = await _fetchAndFilterSubjects(userSubjects);

      if (mounted) {
        setState(() {
          _subjects = updatedSubjects;
          _isLoading = false;
        });
        _calculateWeekRanges();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al obtener los datos: $error';
          _isLoading = false;
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAndFilterSubjects(List<dynamic> userSubjects) async {
    List<Map<String, dynamic>> updatedSubjects = [];

    for (var subject in userSubjects) {
      final subjectData = await _subjectService.getSubjectData(codeSubject: subject['code']);
      final filteredClasses = _filterClasses(subjectData['classes'], subject['types']);

      for (var classData in filteredClasses) {
        classData['events'].sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
      }

      filteredClasses.sort((a, b) => DateTime.parse(a['events'][0]['date']).compareTo(DateTime.parse(b['events'][0]['date'])));

      updatedSubjects.add({
        'name': subjectData['name'] ?? subject['name'],
        'code': subject['code'],
        'classes': filteredClasses,
      });
    }

    return updatedSubjects;
  }

  List<dynamic> _filterClasses(List<dynamic>? classes, List<dynamic>? userTypes) {
    if (classes == null) return [];
    return classes.where((classData) {
      final classType = classData['type']?.toString();
      final types = (userTypes)?.cast<String>() ?? [];
      return classType != null && types.contains(classType);
    }).toList();
  }

  void _calculateWeekRanges() {
    if (_subjects.isEmpty) return;

    DateTime? firstDate;
    DateTime? lastDate;

    for (var subject in _subjects) {
      for (var classData in subject['classes']) {
        for (var event in classData['events']) {
          final eventDate = DateTime.parse(event['date']);
          if (firstDate == null || eventDate.isBefore(firstDate)) {
            firstDate = eventDate;
          }
          if (lastDate == null || eventDate.isAfter(lastDate)) {
            lastDate = eventDate;
          }
        }
      }
    }

    if (firstDate == null || lastDate == null) return;

    _weekRanges = [];
    _weekLabels = [];

    DateTime currentStart = _getStartOfWeek(firstDate);
    while (currentStart.isBefore(lastDate) || currentStart.isAtSameMomentAs(lastDate)) {
      DateTime currentEnd = currentStart.add(const Duration(days: 6));
      _weekRanges.add(DateTimeRange(start: currentStart, end: currentEnd));
      _weekLabels.add(_formatDateWithWeekNumber(currentStart, currentEnd));
      currentStart = currentStart.add(const Duration(days: 7));
    }

    if (_selectedWeekIndex >= _weekRanges.length) {
      _selectedWeekIndex = _weekRanges.length - 1;
    }

    if (mounted) {
      setState(() {});
    }
  }

  DateTime _getStartOfWeek(DateTime date) => date.subtract(Duration(days: date.weekday - 1));

  String _formatDateWithWeekNumber(DateTime startDate, DateTime endDate) {
    final startMonth = DateFormat('MMMM', 'es_ES').format(startDate);
    final endMonth = DateFormat('MMMM', 'es_ES').format(endDate);

    // Si la semana abarca dos meses, mostramos ambos meses
    if (startMonth != endMonth) {
      return '${_formatDateShort(startDate)} - ${_formatDateShort(endDate)} ($startMonth - $endMonth)';
    } else {
      return '${_formatDateShort(startDate)} - ${_formatDateShort(endDate)} ($startMonth)';
    }
  }

  String _formatDateShort(DateTime date) {
    return DateFormat('dd MMMM', 'es_ES').format(date);
  }

  String _formatDateToFullDate(DateTime date) {
    return DateFormat('EEEE d MMMM y', 'es_ES').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              child: Column(
                children: [
                  if (_showWeeks)
                    _buildWeekSelector(isDarkMode), // Mostrar todas las semanas
                  if (!_showWeeks)
                    _buildCurrentWeek(isDarkMode), // Mostrar solo la semana actual

                  // Botón para alternar la visibilidad de las semanas
                  // IconButton(
                  //   onPressed: () {
                  //     setState(() {
                  //       _showWeeks = !_showWeeks; // Cambiar el estado
                  //     });
                  //   },
                  //   icon: Icon(
                  //     _showWeeks ? Icons.expand_less : Icons.expand_more,
                  //     color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
                  //     size: 25, // Ajusta este valor para cambiar el tamaño del ícono
                  //   ),
                  // ),
                  if (_errorMessage.isNotEmpty) ...[
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 10),
                  Expanded(
                    child: _buildEventList(isDarkMode),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentWeek(bool isDarkMode) {
    final weeks = _getWeeksOfSemester();

    if (_selectedWeekIndex < 0 || _selectedWeekIndex >= weeks.length) {
      return const Center(child: Text('Semana no válida'));
    }

    final weekDays = weeks[_selectedWeekIndex];
    final startDate = weekDays.first;
    final monthLabel = DateFormat('MMMM y', 'es_ES').format(startDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8.0),
          child: Text(
            monthLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['Lun', 'Mar', 'Mié', 'Jue', 'Vie'].map((day) {
            return Text(
              day,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        _buildWeekRow(weekDays, _selectedWeekIndex, isDarkMode),
      ],
    );
  }


  List<List<DateTime>> _getWeeksOfSemester() {
    if (_subjects.isEmpty) return [];

    DateTime? firstDate;
    DateTime? lastDate;

    for (var subject in _subjects) {
      for (var classData in subject['classes']) {
        for (var event in classData['events']) {
          final eventDate = DateTime.parse(event['date']);
          if (firstDate == null || eventDate.isBefore(firstDate)) {
            firstDate = eventDate;
          }
          if (lastDate == null || eventDate.isAfter(lastDate)) {
            lastDate = eventDate;
          }
        }
      }
    }

    if (firstDate == null || lastDate == null) return [];

    final weeks = <List<DateTime>>[];
    DateTime currentStart = _getStartOfWeek(firstDate);

    while (currentStart.isBefore(lastDate) || currentStart.isAtSameMomentAs(lastDate)) {
      final week = <DateTime>[];
      for (int i = 0; i < 5; i++) {
        week.add(currentStart.add(Duration(days: i)));
      }
      weeks.add(week);
      currentStart = currentStart.add(const Duration(days: 7));
    }

    return weeks;
  }

  Widget _buildWeekSelector(bool isDarkMode) {
    final weeks = _getWeeksOfSemester();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['Lun', 'Mar', 'Mié', 'Jue', 'Vie'].map((day) {
            return Text(
              day,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            physics: _showWeeks
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: weeks.length,
            itemBuilder: (context, index) {
              final weekDays = weeks[index];
              final startDate = weekDays.first;
  

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index == 0 || _isNewMonth(weekDays, weeks[index - 1]))
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                      child: Text(
                        DateFormat('MMMM y', 'es_ES').format(startDate),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
                        ),
                      ),
                    ),
                  _buildWeekRow(weekDays, index, isDarkMode),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  bool _dayHasClass(DateTime day) {
    for (var subject in _subjects) {
      for (var classData in subject['classes']) {
        for (var event in classData['events']) {
          final eventDate = DateTime.parse(event['date']);
          if (eventDate.year == day.year &&
              eventDate.month == day.month &&
              eventDate.day == day.day) {
            return true; // El día tiene al menos una clase
          }
        }
      }
    }
    return false; // El día no tiene clases
  }

  // Método para verificar si una semana pertenece a un nuevo mes
  bool _isNewMonth(List<DateTime> currentWeek, List<DateTime> previousWeek) {
    final currentMonth = currentWeek.first.month;
    final previousMonth = previousWeek.first.month;
    return currentMonth != previousMonth;
  }



  Widget _buildWeekRow(List<DateTime> weekDays, int weekIndex, bool isDarkMode) {
    final isSelected = _selectedWeekIndex == weekIndex;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            // Si la semana ya está seleccionada, alternar la visibilidad del ListView
            _showWeeks = !_showWeeks;
          } else {
            // Si es una semana diferente, seleccionarla y colapsar el ListView
            _selectedWeekIndex = weekIndex;
            _showWeeks = false;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.yellow.shade700 : Colors.indigo)
              : (isDarkMode ? Colors.black : Colors.white),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: !isDarkMode
                  ? Colors.black.withOpacity(0.45)
                  : Colors.white.withOpacity(0.45),
              blurRadius: 8.0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: weekDays.map((day) {
            final hasClass = _dayHasClass(day); // Verificar si el día tiene clase

            return Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  DateFormat('d', 'es_ES').format(day), // Mostrar el número del día
                  style: TextStyle(
                    color: isSelected
                        ? (isDarkMode ? Colors.black : Colors.white)
                        : (isDarkMode ? Colors.white : Colors.black),
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 20),
                if (hasClass) // Mostrar círculo si el día tiene clase
                  Positioned(
                    bottom: 0, // Ajustar la posición vertical del círculo
                    child: Container(
                      width: 6, // Tamaño del círculo
                      height: 6, // Tamaño del círculo
                      decoration: BoxDecoration(
                        color: isSelected
                            ? isDarkMode ? Colors.black : Colors.white
                            : isDarkMode ? Colors.white : Colors.black,
                        shape: BoxShape.circle, // Forma del círculo
                      ),
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEventList(bool isDarkMode) {
    if (_weekRanges.isEmpty) {
      return const Center(child: Text('No hay clases disponibles'));
    }

    if (_selectedWeekIndex < 0 || _selectedWeekIndex >= _weekRanges.length) {
      return const Center(child: Text('Semana no válida'));
    }

    final weekRange = _weekRanges[_selectedWeekIndex];
    final allEvents = _getFilteredEvents(weekRange);

    if (allEvents.isEmpty) {
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
    for (var eventData in allEvents) {
      final eventDate = eventData['event']['date'];
      groupedByDate.putIfAbsent(eventDate, () => []).add(eventData);
    }

    final sortedDates = groupedByDate.keys.toList()..sort();

    return ListView.builder(
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _formatDateToFullDate(DateTime.parse(date)),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
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
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredEvents(DateTimeRange weekRange) {
    List<Map<String, dynamic>> allEvents = [];

    for (var subject in _subjects) {
      for (var classData in subject['classes']) {
        for (var event in classData['events']) {
          final eventDate = DateTime.parse(event['date']);
          if (eventDate.isAfter(weekRange.start.subtract(const Duration(days: 1))) &&
              eventDate.isBefore(weekRange.end.add(const Duration(days: 1)))) {
            allEvents.add({
              'subjectName': subject['name'] ?? 'No Name',
              'classType': classData['type'] ?? 'No disponible',
              'event': event,
            });
          }
        }
      }
    }

    return allEvents;
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