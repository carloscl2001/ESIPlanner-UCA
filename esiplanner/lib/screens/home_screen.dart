import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../services/subject_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/class_cards.dart';
import '../providers/theme_provider.dart';
import 'dart:ui';

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

  final List<String> _weekDays = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie'];
  final List<String> _weekDaysFullName = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];

  // Controlador para el PageView
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService();
    _subjectService = SubjectService();
    _selectedDay = _getCurrentWeekday();
    _pageController = PageController(initialPage: _weekDays.indexOf(_selectedDay!));
    _loadSubjects();
  }

  @override
  void dispose() {
    _pageController.dispose(); // Liberar el controlador
    super.dispose();
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
      final profileData = await _profileService.getProfileData(
        username: username,
      );
      final degree = profileData["degree"];
      final userSubjects = profileData["subjects"] ?? [];

      if (degree == null || userSubjects.isEmpty) {
        setState(() {
          _errorMessage =
              degree == null
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

  Future<List<Map<String, dynamic>>> _fetchAndFilterSubjects(
    List<dynamic> userSubjects,
  ) async {
    List<Map<String, dynamic>> updatedSubjects = [];

    for (var subject in userSubjects) {
      final subjectData = await _subjectService.getSubjectData(
        codeSubject: subject['code'],
      );
      final filteredClasses = _filterClasses(
        subjectData['classes'],
        subject['types'],
      );

      for (var classData in filteredClasses) {
        classData['events'].sort(
          (a, b) =>
              DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])),
        );
      }

      filteredClasses.sort(
        (a, b) => DateTime.parse(
          a['events'][0]['date'],
        ).compareTo(DateTime.parse(b['events'][0]['date'])),
      );

      updatedSubjects.add({
        'name': subjectData['name'] ?? subject['name'],
        'code': subject['code'],
        'classes': filteredClasses,
      });
    }

    return updatedSubjects;
  }

  List<dynamic> _filterClasses(
    List<dynamic>? classes,
    List<dynamic>? userTypes,
  ) {
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
    final isWeekend = _isWeekend(now);

    // Si es fin de semana, seleccionar el próximo lunes
    if (isWeekend) {
      return _weekDays[0]; // Lunes
    }

    // De lo contrario, devolver el día actual
    return _weekDays[now.weekday - 1];
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return monthNames[month - 1];
  }

  DateTime _startOfWeek(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day - (date.weekday - 1));
  }


  DateTime _endOfWeek(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day + (5 - date.weekday)); // Solo lunes a viernes
  }

  Map<String, List<Map<String, dynamic>>> _groupEventsByDay(List<Map<String, dynamic>> events) {
    final groupedEvents = <String, List<Map<String, dynamic>>>{};
    for (var event in events) {
      final eventDate = event['event']['date'].split(' ')[0]; // Extraer solo la fecha (sin la hora)
      groupedEvents.putIfAbsent(eventDate, () => []).add(event);
    }
    return groupedEvents;
  }

  List<Map<String, dynamic>> _getFilteredEvents(
    List<Map<String, dynamic>> subjects,
    String? selectedDay,
  ) {
    final now = DateTime.now();
    final isWeekend = _isWeekend(now);
    final startOfWeek = isWeekend
        ? _startOfWeek(now.add(Duration(days: DateTime.monday - now.weekday + 7)))
        : _startOfWeek(now);
    final endOfWeek = _endOfWeek(startOfWeek);

    // Obtener todos los eventos de la semana
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

    // Agrupar eventos por día
    final groupedEvents = _groupEventsByDay(allEvents);

    // Filtrar eventos para el día seleccionado
    if (selectedDay != null) {
      final selectedDayIndex = _weekDays.indexOf(selectedDay);
      final selectedDate = startOfWeek.add(Duration(days: selectedDayIndex));
      final selectedDateString = selectedDate.toIso8601String().split('T')[0];

      return groupedEvents[selectedDateString] ?? [];
    }

    return allEvents;
  }

  List<String> _getWeekDates() {
    final now = DateTime.now();
    final isWeekend = _isWeekend(now);
    final startOfWeek = isWeekend
        ? _startOfWeek(now.add(Duration(days: DateTime.monday - now.weekday + 7)))
        : _startOfWeek(now);

    return List.generate(
      5,
      (index) => startOfWeek.add(Duration(days: index)).day.toString(),
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
        return 'Clase de teória-práctica';
      default:
        return 'Clase de teória-práctica';
    }
  }
  
  
  Row dayButtonRow(List<String> weekDates, bool isDarkMode) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _weekDays.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        final date = weekDates[index];
        return _buildDayButton(day, date, isDarkMode);
      }).toList(),
    );
  }

  Padding selectedDayRow(bool isDarkMode, String selectedDay) {
    // Obtener la fecha actual
    final now = DateTime.now();
    final isWeekend = _isWeekend(now);
    final startOfWeek = isWeekend
        ? _startOfWeek(now.add(Duration(days: DateTime.monday - now.weekday + 7)))
        : _startOfWeek(now);

    // Obtener el índice del día seleccionado
    final selectedDayIndex = _weekDays.indexOf(selectedDay);
    final selectedDate = startOfWeek.add(Duration(days: selectedDayIndex));

    // Verificar si el día seleccionado es hoy
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                selectedDate.day.toString(), // Mostrar el día seleccionado
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 55,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (selectedDate.weekday >= 1 && selectedDate.weekday <= 5)
                        ? _weekDaysFullName[selectedDate.weekday - 1]
                        : "Fin de semana",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    '${_getMonthName(selectedDate.month)} ${selectedDate.year}',
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
          if (isToday) // Mostrar el cuadro de "Hoy" solo si el día seleccionado es hoy
            Container(
              margin: const EdgeInsets.only(right: 8),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Hoy',
                style: TextStyle(
                  color: isDarkMode ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayButton(String day, String date, bool isDarkMode) {
    final hasEvents = _getFilteredEvents(_subjects, day).isNotEmpty;

    return GestureDetector(
      onTap: () {
        final index = _weekDays.indexOf(day);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 1),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: _selectedDay == day
              ? (isDarkMode ? Colors.yellow.shade700 : Colors.indigo)
              : null,
          gradient: _selectedDay != day
              ? (isDarkMode
                  ? LinearGradient(
                      colors: [Colors.black, Colors.black],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [Colors.white, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ))
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: !isDarkMode
                  ? Colors.black.withValues( alpha: 0.45)
                  : Colors.grey.withValues( alpha: 0.45),
              blurRadius: 8.0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                Text(
                  day,
                  style: TextStyle(
                    color: _selectedDay == day
                        ? (isDarkMode ? Colors.black : Colors.white)
                        : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  date,
                  style: TextStyle(
                    color: _selectedDay == day
                        ? (isDarkMode ? Colors.black : Colors.white)
                        : (isDarkMode ? Colors.white : Colors.black),
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
            if (hasEvents)
              Positioned(
                bottom: 0,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _selectedDay == day
                        ? (isDarkMode ? Colors.black : Colors.white)
                        : (isDarkMode ? Colors.white : Colors.black),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(List<Map<String, dynamic>> events) {
    final groupedEvents = _groupEventsByDay(events);

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedDay = _weekDays[index];
          });
        },
        physics: const PageScrollPhysics().applyTo(
          const BouncingScrollPhysics(),
        ),
        itemCount: _weekDays.length,
        itemBuilder: (context, index) {
          final day = _weekDays[index];
          final dayEvents = _getFilteredEvents(_subjects, day);

          if (dayEvents.isEmpty) {
            return Center(
              child: Text(
                'No hay clases',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            );
          }

          final sortedDates = groupedEvents.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final events = groupedEvents[date]!..sort((a, b) {
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
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final weekDates = _getWeekDates();

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                  ],
                  selectedDayRow(isDarkMode, _selectedDay!),
                  // const SizedBox(height: 10),
                  dayButtonRow(weekDates, isDarkMode),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _buildEventList(
                      _getFilteredEvents(_subjects, _selectedDay),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}