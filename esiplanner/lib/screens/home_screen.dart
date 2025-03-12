import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../services/subject_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/class_cards.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ProfileService _profileService;
  late SubjectService _subjectService;

  bool _isLoading = true;
  List<Map<String, dynamic>> _subjects = [];
  String _errorMessage = '';
  String? _selectedDay;

  final List<String> _weekDays = ['L', 'M', 'X', 'J', 'V'];

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService();
    _subjectService = SubjectService();
    _selectedDay = _getCurrentWeekday();
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
          _errorMessage = degree == null ? 'No se encontró el grado en los datos del perfil' : 'El usuario no tiene asignaturas';
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

  String _getCurrentWeekday() {
    final now = DateTime.now();
    final weekdayIndex = now.weekday - 1;
    return (weekdayIndex >= 0 && weekdayIndex < _weekDays.length) ? _weekDays[weekdayIndex] : 'L';
  }

  String _getMonthYearRange(DateTime startOfWeek, DateTime endOfWeek) {
    final startMonth = _getMonthName(startOfWeek.month);
    final startYear = startOfWeek.year;
    final endMonth = _getMonthName(endOfWeek.month);
    final endYear = endOfWeek.year;

    return startMonth == endMonth && startYear == endYear
        ? '$startMonth $startYear'
        : '$startMonth $startYear - $endMonth $endYear';
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return monthNames[month - 1];
  }

  List<Map<String, dynamic>> _getFilteredEvents(List<Map<String, dynamic>> subjects, String? selectedDay) {
    final now = DateTime.now();
    final startOfWeek = _startOfWeek(now);
    final endOfWeek = _endOfWeek(now);

    List<Map<String, dynamic>> allEvents = [];

    for (var subject in subjects) {
      for (var classData in subject['classes']) {
        for (var event in classData['events']) {
          final eventDate = DateTime.parse(event['date']);
          if (eventDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              eventDate.isBefore(endOfWeek.add(const Duration(days: 1)))) {
            allEvents.add({
              'subjectName': subject['name'] ?? 'No Name',
              'classType': classData['type'] ?? 'No disponible',
              'event': event,
            });
          }
        }
      }
    }

    if (selectedDay != null) {
      final selectedDayIndex = _weekDays.indexOf(selectedDay);
      final selectedDate = _startOfWeek(now).add(Duration(days: selectedDayIndex));

      allEvents = allEvents.where((eventData) {
        final eventDate = DateTime.parse(eventData['event']['date']);
        return eventDate.year == selectedDate.year &&
            eventDate.month == selectedDate.month &&
            eventDate.day == selectedDate.day;
      }).toList();
    }

    return allEvents;
  }

  DateTime _startOfWeek(DateTime date) => date.subtract(Duration(days: date.weekday - 1));
  DateTime _endOfWeek(DateTime date) => date.add(Duration(days: 5 - date.weekday)); // Solo lunes a viernes

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final weekDates = _getWeekDates();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tus clases esta semana',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.indigo,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25), // Ajusta el radio para cambiar la curvatura
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_errorMessage.isNotEmpty) ...[
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    _getMonthYearRange(_startOfWeek(DateTime.now()), _endOfWeek(DateTime.now())),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _weekDays.asMap().entries.map((entry) {
                      final index = entry.key;
                      final day = entry.value;
                      final date = weekDates[index];
                      return _buildDayButton(day, date, isDarkMode);
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _buildEventList(_getFilteredEvents(_subjects, _selectedDay)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDayButton(String day, String date, bool isDarkMode) {
    return GestureDetector(
      onTap: () => setState(() => _selectedDay = day),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          color: _selectedDay == day
              ? (isDarkMode ? Colors.yellow.shade700 : Colors.indigo)
              : (isDarkMode ? Colors.grey.shade900 : Colors.indigo.shade50),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              day,
              style: TextStyle(
                color: _selectedDay == day ? (isDarkMode ? Colors.black : Colors.white) : (isDarkMode ? Colors.white : Colors.black),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              date,
              style: TextStyle(
                color: _selectedDay == day ? (isDarkMode ? Colors.black : Colors.white) : (isDarkMode ? Colors.white : Colors.black),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(List<Map<String, dynamic>> events) {
    final groupedByDate = <String, List<Map<String, dynamic>>>{};
    for (var eventData in events) {
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

        // Detectar solapamientos
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
              classType: '$classType - ${_getGroupLabel(classType[0])}',
              event: event,
              isOverlap: isOverlapping[index],
            );
          }).toList(),
        );
      },
    );
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

  List<String> _getWeekDates() {
    final now = DateTime.now();
    final startOfWeek = _startOfWeek(now);
    return List.generate(5, (index) => startOfWeek.add(Duration(days: index)).day.toString()); // Solo lunes a viernes
  }
}