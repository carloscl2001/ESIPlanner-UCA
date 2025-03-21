import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/profile_service.dart';
import '../services/subject_service.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'week_classes_screen.dart'; // Importa la nueva pantalla

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


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
                // Días de la semana (Lun, Mar, Mié, Jue, Vie)
                _buildWeekDaysHeader(isDarkMode),
                // Lista de semanas
                Expanded(
                  child: _buildWeekSelector(isDarkMode),
                ),
              ],
            ),
    );
  }

  // Encabezado con los días de la semana
  Widget _buildWeekDaysHeader(bool isDarkMode) {
    return Container(
      margin: EdgeInsets.all(0), // Padding eliminado
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.white, // Fondo blanco
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12.0), // Borde redondeado abajo izquierda
          bottomRight: Radius.circular(12.0), // Borde redondeado abajo derecha
        ),
        border: Border.all(
          color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
          width: 3, // Grosor del borde
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.grey.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.45), // Color de la sombra
            blurRadius: 6.0, // Difuminado de la sombra
            offset: Offset(0, 3), // Desplazamiento de la sombra (x, y)
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['Lun', 'Mar', 'Mie', 'Jue', 'Vie'].map((day) {
            return SizedBox(
              width: 40, // Ancho fijo para alinear con los números
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWeekSelector(bool isDarkMode) {
    final weeks = _getWeeksOfSemester();
    final currentWeekIndex = _getCurrentWeekIndex(weeks); // Obtener el índice de la semana actual

    return ListView.builder(
      key: PageStorageKey('timetable'),
      shrinkWrap: false,
      physics: defaultTargetPlatform == TargetPlatform.iOS
          ? const BouncingScrollPhysics()
          : const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: weeks.length,
      itemBuilder: (context, index) {
        final weekDays = weeks[index];
        final startDate = weekDays.first;
        final isCurrentWeek = index == currentWeekIndex; // Verificar si es la semana actual

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (index == 0 || _isNewMonth(weekDays, weeks[index - 1]))
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Mes en un cuadrado a la izquierda
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey : Colors.grey,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      child: Text(
                        DateFormat('MMMM', 'es_ES').format(startDate),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                    // Año en un cuadrado a la derecha
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey : Colors.grey,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      child: Text(
                        DateFormat('y', 'es_ES').format(startDate),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _buildWeekRow(weekDays, index, isDarkMode, isCurrentWeek), // Pasar isCurrentWeek
          ],
        );
      },
    );
  }

  int _getCurrentWeekIndex(List<List<DateTime>> weeks) {
    final now = DateTime.now();
    for (int i = 0; i < weeks.length; i++) {
      final weekStart = weeks[i].first;
      final weekEnd = weeks[i].last;
      if (now.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          now.isBefore(weekEnd.add(const Duration(days: 1)))) {
        return i; // Devolver el índice de la semana actual
      }
    }
    return -1; // Si no se encuentra la semana actual
  }

  bool _dayHasClass(DateTime day) {
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

  bool _isNewMonth(List<DateTime> currentWeek, List<DateTime> previousWeek) {
    final currentMonth = currentWeek.first.month;
    final previousMonth = previousWeek.first.month;
    return currentMonth != previousMonth;
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

  void _calculateWeekRanges() {
    if (_subjects.isEmpty) return;

    DateTime? firstDate;
    DateTime? lastDate;

    for (var subject in _subjects) {
      for (var classData in subject['classes']) {
        for (var event in classData['events']) {
          final eventDate = DateTime.parse(event['date']);
          if (eventDate.weekday >= DateTime.monday && eventDate.weekday <= DateTime.friday) {
            // Solo procesar eventos de lunes a viernes
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

    DateTime currentStart = _getStartOfWeek(firstDate); // Lunes de la primera semana

    while (currentStart.isBefore(lastDate) || currentStart.isAtSameMomentAs(lastDate)) {
      DateTime currentEnd = currentStart.add(const Duration(days: 4)); // Viernes de la semana
      _weekRanges.add(DateTimeRange(start: currentStart, end: currentEnd));
      _weekLabels.add(_formatDateWithWeekNumber(currentStart, currentEnd));
      currentStart = currentStart.add(const Duration(days: 7)); // Siguiente lunes
    }

    if (_selectedWeekIndex >= _weekRanges.length) {
      _selectedWeekIndex = _weekRanges.length - 1;
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildWeekRow(List<DateTime> weekDays, int weekIndex, bool isDarkMode, bool isCurrentWeek) {

    return GestureDetector(
      onTap: () {
        final weekRange = _weekRanges[weekIndex];
        final allEvents = _getFilteredEvents(weekRange);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeekClassesScreen(
              events: allEvents,
              selectedWeekIndex: weekIndex,
              isDarkMode: isDarkMode,
              weekStartDate: weekDays.first, // Pasar la fecha de inicio de la semana
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0), // Margen reducido
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0), // Padding reducido
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isCurrentWeek // Resaltar la semana actual con un borde
              ? Border.all(
                  color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
                  width: 3,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: !isDarkMode
                  ? Colors.black.withValues(alpha: 0.45)
                  : Colors.grey.withValues(alpha: 0.45),
              blurRadius: 8.0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: weekDays.map((day) {
            final hasClass = _dayHasClass(day);

            return SizedBox(
              width: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    DateFormat('d', 'es_ES').format(day),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 26,
                    ),
                  ),
                  if (hasClass)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.white : Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  DateTime _parseDate(String dateString) {
    final dateTime = DateTime.parse(dateString);
    return DateTime(dateTime.year, dateTime.month, dateTime.day); // Ignorar la hora y usar solo la fecha
  }

  DateTime _getStartOfWeek(DateTime date) {
    // Asegurarnos de que la fecha esté en el huso horario local
    final localDate = DateTime.utc(date.year, date.month, date.day);
    // Restar (localDate.weekday - 1) días para obtener el lunes de la semana
    return localDate.subtract(Duration(days: localDate.weekday - 1));
  }

  List<List<DateTime>> _getWeeksOfSemester() {
  if (_subjects.isEmpty) return [];

  DateTime? firstDate;
  DateTime? lastDate;

  for (var subject in _subjects) {
    for (var classData in subject['classes']) {
      for (var event in classData['events']) {
        final eventDate = _parseDate(event['date']); // Usar _parseDate para evitar problemas de huso horario
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
  DateTime currentStart = _getStartOfWeek(firstDate); // Lunes de la primera semana

  while (currentStart.isBefore(lastDate) || currentStart.isAtSameMomentAs(lastDate)) {
    final week = <DateTime>[];
    for (int i = 0; i < 5; i++) {
      week.add(currentStart.add(Duration(days: i))); // Lunes a viernes
    }
    weeks.add(week);
    currentStart = currentStart.add(const Duration(days: 7)); // Siguiente lunes
  }

  return weeks;
}
}