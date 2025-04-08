import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../services/profile_service.dart';
import '../../../services/subject_service.dart';
import '../../../providers/auth_provider.dart';

class TimetableLogic with ChangeNotifier {
  final BuildContext context;
  final ProfileService _profileService;
  final SubjectService _subjectService;

  bool _isLoading = true;
  List<Map<String, dynamic>> _subjects = [];
  String _errorMessage = '';
  int _selectedWeekIndex = 0;
  
  final List<String> _weekDays = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie'];
  List<DateTimeRange> _weekRanges = [];
  List<String> _weekLabels = [];

  TimetableLogic(this.context)
      : _profileService = ProfileService(),
        _subjectService = SubjectService();

  // Getters
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get subjects => _subjects;
  String get errorMessage => _errorMessage;
  int get selectedWeekIndex => _selectedWeekIndex;
  List<String> get weekDays => _weekDays;
  List<DateTimeRange> get weekRanges => _weekRanges;
  List<String> get weekLabels => _weekLabels;
  List <Map<String, dynamic>> get userSubjects => _subjects;

  Future<void> loadSubjects() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final username = Provider.of<AuthProvider>(context, listen: false).username;
      
      if (username == null) {
        _errorMessage = 'Usuario no autenticado';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final profileData = await _profileService.getProfileData(username: username);
      final degree = profileData["degree"];
      final userSubjects = profileData["subjects"] ?? [];

      if (degree == null) {
        _errorMessage = 'No se encontró el grado en los datos del perfil';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _subjects = await _fetchAndFilterSubjects(userSubjects);
      _isLoading = false;
      _calculateWeekRanges();
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Error al obtener los datos: ${error.toString()}';
      _isLoading = false;
      notifyListeners();
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

  void _calculateWeekRanges() {
    if (_subjects.isEmpty) return;

    DateTime? firstDate;
    DateTime? lastDate;

    for (var subject in _subjects) {
      for (var classData in subject['classes']) {
        for (var event in classData['events']) {
          final eventDate = DateTime.parse(event['date']);
          if (eventDate.weekday >= DateTime.monday && eventDate.weekday <= DateTime.friday) {
            if (firstDate == null || eventDate.isBefore(firstDate)) {
              firstDate = eventDate;
            }
            if (lastDate == null || eventDate.isAfter(lastDate)) {
              lastDate = eventDate;
            }
          }
        }
      }
    }

    if (firstDate == null || lastDate == null) return;

    _weekRanges = [];
    _weekLabels = [];

    DateTime currentStart = _getStartOfWeek(firstDate);

    while (currentStart.isBefore(lastDate) || currentStart.isAtSameMomentAs(lastDate)) {
      DateTime currentEnd = currentStart.add(const Duration(days: 4));
      _weekRanges.add(DateTimeRange(start: currentStart, end: currentEnd));
      _weekLabels.add(_formatDateWithWeekNumber(currentStart, currentEnd));
      currentStart = currentStart.add(const Duration(days: 7));
    }

    if (_selectedWeekIndex >= _weekRanges.length) {
      _selectedWeekIndex = _weekRanges.length - 1;
    }
  }

  String _formatDateWithWeekNumber(DateTime startDate, DateTime endDate) {
    final startMonth = DateFormat('MMMM', 'es_ES').format(startDate);
    final endMonth = DateFormat('MMMM', 'es_ES').format(endDate);

    if (startMonth != endMonth) {
      return '${_formatDateShort(startDate)} - ${_formatDateShort(endDate)} ($startMonth - $endMonth)';
    } else {
      return '${_formatDateShort(startDate)} - ${_formatDateShort(endDate)} ($startMonth)';
    }
  }

  String _formatDateShort(DateTime date) {
    return DateFormat('dd MMMM', 'es_ES').format(date);
  }

  DateTime _getStartOfWeek(DateTime date) {
    final localDate = DateTime.utc(date.year, date.month, date.day);
    return localDate.subtract(Duration(days: localDate.weekday - 1));
  }

  bool dayHasClass(DateTime day) {
    for (var subject in _subjects) {
      for (var classData in subject['classes']) {
        for (var event in classData['events']) {
          final eventDate = DateTime.parse(event['date']);
          if (eventDate.year == day.year &&
              eventDate.month == day.month &&
              eventDate.day == day.day) {
            return true;
          }
        }
      }
    }
    return false;
  }

  List<Map<String, dynamic>> getFilteredEvents(DateTimeRange weekRange) {
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

  List<List<DateTime>> getWeeksOfSemester() {
    if (_subjects.isEmpty) return [];

    DateTime? firstDate;
    DateTime? lastDate;

    for (var subject in _subjects) {
      for (var classData in subject['classes']) {
        for (var event in classData['events']) {
          final eventDate = _parseDate(event['date']);
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

  DateTime _parseDate(String dateString) {
    final dateTime = DateTime.parse(dateString);
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  int getCurrentWeekIndex(List<List<DateTime>> weeks) {
    final now = DateTime.now();
    for (int i = 0; i < weeks.length; i++) {
      final weekStart = weeks[i].first;
      final weekEnd = weeks[i].last;
      if (now.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          now.isBefore(weekEnd.add(const Duration(days: 1)))) {
        return i;
      }
    }
    return -1;
  }

  bool isNewMonth(List<DateTime> currentWeek, List<DateTime> previousWeek) {
    final currentMonth = currentWeek.first.month;
    final previousMonth = previousWeek.first.month;
    return currentMonth != previousMonth;
  }

  void updateSelectedWeek(int index) {
    _selectedWeekIndex = index;
    notifyListeners();
  }
}