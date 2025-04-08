import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/profile_service.dart';
import '../../services/subject_service.dart';
import '../../providers/auth_provider.dart';

class HomeLogic {
  final BuildContext context;
  final ProfileService _profileService;
  final SubjectService _subjectService;

  bool _isLoading = true;
  List<Map<String, dynamic>> _subjects = [];
  String _errorMessage = '';
  String? _selectedDay;

  final List<String> _weekDays = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie'];
  final List<String> _weekDaysFullName = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];

  HomeLogic(this.context)
      : _profileService = ProfileService(),
        _subjectService = SubjectService() {
    _selectedDay = _getCurrentWeekday();
  }

  // Getters
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get subjects => _subjects;
  String get errorMessage => _errorMessage;
  String? get selectedDay => _selectedDay;
  List<String> get weekDays => _weekDays;
  List<String> get weekDaysFullName => _weekDaysFullName;

  Future<void> loadSubjects() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      _notifyListeners();

      final username = Provider.of<AuthProvider>(context, listen: false).username;
      
      if (username == null) {
        _errorMessage = 'Usuario no autenticado';
        _isLoading = false;
        _notifyListeners();
        return;
      }

      final profileData = await _profileService.getProfileData(username: username);
      final degree = profileData["degree"];
      final userSubjects = profileData["subjects"] ?? [];

      if (degree == null) {
        _errorMessage = 'No se encontró el grado en los datos del perfil';
        _isLoading = false;
        _notifyListeners();
        return;
      }

      _subjects = await _fetchAndFilterSubjects(userSubjects);
      _isLoading = false;
      _notifyListeners();
    } catch (error) {
      _errorMessage = 'Error al obtener los datos: ${error.toString()}';
      _isLoading = false;
      _notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAndFilterSubjects(List<dynamic> userSubjects) async {
    List<Map<String, dynamic>> updatedSubjects = [];

    for (var subject in userSubjects) {
      try {
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
      } catch (e) {
        debugPrint('Error procesando asignatura ${subject['code']}: $e');
      }
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

  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  String _getCurrentWeekday() {
    final now = DateTime.now().toUtc();
    return _isWeekend(now) ? _weekDays[0] : _weekDays[now.weekday - 1];
  }

  String getMonthName(int month) {
    const monthNames = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return monthNames[month - 1];
  }

  DateTime _startOfWeek(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day - (date.weekday - 1));
  }

  DateTime _endOfWeek(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day + (5 - date.weekday));
  }

  Map<String, List<Map<String, dynamic>>> groupEventsByDay(List<Map<String, dynamic>> events) {
    final groupedEvents = <String, List<Map<String, dynamic>>>{};
    for (var event in events) {
      final eventDate = event['event']['date'].split(' ')[0];
      groupedEvents.putIfAbsent(eventDate, () => []).add(event);
    }
    return groupedEvents;
  }

  List<Map<String, dynamic>> getFilteredEvents(String? selectedDay) {
    final now = DateTime.now();
    final isWeekend = _isWeekend(now);
    final startOfWeek = isWeekend
        ? _startOfWeek(now.add(Duration(days: DateTime.monday - now.weekday + 7)))
        : _startOfWeek(now);
    final endOfWeek = _endOfWeek(startOfWeek);

    List<Map<String, dynamic>> allEvents = [];
    for (var subject in _subjects) {
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

    final groupedEvents = groupEventsByDay(allEvents);

    if (selectedDay != null) {
      final selectedDayIndex = _weekDays.indexOf(selectedDay);
      final selectedDate = startOfWeek.add(Duration(days: selectedDayIndex));
      final selectedDateString = selectedDate.toIso8601String().split('T')[0];

      return groupedEvents[selectedDateString] ?? [];
    }

    return allEvents;
  }

  List<String> getWeekDates() {
    final now = DateTime.now();
    final isWeekend = _isWeekend(now);
    final startOfWeek = isWeekend
        ? _startOfWeek(now.add(Duration(days: DateTime.monday - now.weekday + 7)))
        : _startOfWeek(now);

    return List.generate(5, (index) => startOfWeek.add(Duration(days: index)).day.toString());
  }

  String getGroupLabel(String letter) {
    switch (letter) {
      case 'A': return 'Clase de teoría';
      case 'B': return 'Clase de problemas';
      case 'C': return 'Clase de prácticas informáticas';
      case 'D': return 'Clase de laboratorio';
      case 'E': return 'Salida de campo';
      case 'X': return 'Clase de teória-práctica';
      default: return 'Clase de teória-práctica';
    }
  }

  void updateSelectedDay(String day) {
    _selectedDay = day;
    _notifyListeners();
  }

  void _notifyListeners() {
    if (mounted) {
      // Notificar a los listeners si es necesario
      // (Podrías convertir esto en un ChangeNotifier si necesitas más control)
      setState(() {});
    }
  }

  bool get mounted {
    try {
      context.widget;
      return true;
    } catch (e) {
      return false;
    }
  }

  void setState(VoidCallback fn) {
    if (mounted) {
      fn();
    }
  }
}