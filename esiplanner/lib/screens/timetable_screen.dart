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

      bool hasEvents = false;
      for (var subject in _subjects) {
        for (var classData in subject['classes']) {
          for (var event in classData['events']) {
            final eventDate = DateTime.parse(event['date']);
            if (eventDate.isAfter(currentStart.subtract(const Duration(days: 1))) &&
                eventDate.isBefore(currentEnd.add(const Duration(days: 1)))) {
              hasEvents = true;
              break;
            }
          }
        }
        if (hasEvents) break;
      }

      if (hasEvents) {
        _weekRanges.add(DateTimeRange(start: currentStart, end: currentEnd));
        _weekLabels.add(_formatDateWithWeekNumber(currentStart, currentEnd));
      }

      currentStart = currentStart.add(const Duration(days: 7));
    }

    if (mounted) {
      setState(() {});
    }
  }

  DateTime _getStartOfWeek(DateTime date) => date.subtract(Duration(days: date.weekday - 1));

  String _formatDateWithWeekNumber(DateTime startDate, DateTime endDate) {
    return '${_formatDateShort(startDate)} - ${_formatDateShort(endDate)}';
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
      appBar: AppBar(
        title: const Text(
          'Elige una semana para ver tus clases',
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
                  _buildWeekSelector(isDarkMode),
                  if (_errorMessage.isNotEmpty) ...[
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                  ],
                  const Divider(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _buildEventList(isDarkMode),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildWeekSelector(bool isDarkMode) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
          size: 26.0,
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : null,
              gradient: isDarkMode
                  ? null
                  : LinearGradient(
                      colors: [Colors.indigo.shade50, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButton<int>(
              value: _selectedWeekIndex,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedWeekIndex = newValue!;
                });
              },
              items: _weekLabels.asMap().entries.map<DropdownMenuItem<int>>((entry) {
                final weekRange = _weekRanges[entry.key];
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDateShort(weekRange.start),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Text(
                          _formatDateShort(weekRange.end),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              underline: const SizedBox(),
              icon: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Icon(
                  Icons.arrow_drop_down,
                  color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
                ),
              ),
              isExpanded: true,
              dropdownColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventList(bool isDarkMode) {
    if (_weekRanges.isEmpty) {
      return const Center(child: Text('No hay clases disponibles'));
    }

    final weekRange = _weekRanges[_selectedWeekIndex];
    final allEvents = _getFilteredEvents(weekRange);

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