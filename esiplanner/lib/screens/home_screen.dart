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
  final List<String> _weekDaysFullName = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];

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

  String _getCurrentWeekday() {
    final now = DateTime.now();
    final weekdayIndex = now.weekday - 1;
    return (weekdayIndex >= 0 && weekdayIndex < _weekDays.length)
        ? _weekDays[weekdayIndex]
        : 'L';
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

  List<Map<String, dynamic>> _getFilteredEvents(
    List<Map<String, dynamic>> subjects,
    String? selectedDay,
  ) {
    final now = DateTime.now();
    final startOfWeek = _startOfWeek(now);
    final endOfWeek = _endOfWeek(now);

    List<Map<String, dynamic>> allEvents = [];

    for (var subject in subjects) {
      for (var classData in subject['classes']) {
        for (var event in classData['events']) {
          final eventDate = DateTime.parse(event['date']);
          if (eventDate.isAfter(
                startOfWeek.subtract(const Duration(days: 1)),
              ) &&
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
      final selectedDate = _startOfWeek(
        now,
      ).add(Duration(days: selectedDayIndex));

      allEvents =
          allEvents.where((eventData) {
            final eventDate = DateTime.parse(eventData['event']['date']);
            return eventDate.year == selectedDate.year &&
                eventDate.month == selectedDate.month &&
                eventDate.day == selectedDate.day;
          }).toList();
    }

    return allEvents;
  }

  DateTime _startOfWeek(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));
  DateTime _endOfWeek(DateTime date) =>
      date.add(Duration(days: 5 - date.weekday)); // Solo lunes a viernes

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final weekDates = _getWeekDates();

    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
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
                    actualDayRow(isDarkMode, DateTime.now().day.toString(),), 
                    // const Divider(height: 10),
                    const SizedBox(height: 10),
                    dayButtonRow(weekDates, isDarkMode),
                    const SizedBox(height: 20),
                    // const Divider(),
                    Text( 
                      'Mis clases del día seleccionado',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.left,
                    ),
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

  Row dayButtonRow(List<String> weekDates, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children:
          _weekDays.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            final date = weekDates[index];
            return _buildDayButton(day, date, isDarkMode);
          }).toList(),
    );
  }

  Padding actualDayRow(bool isDarkMode, day) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16), // Padding horizontal de 16
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuye el espacio entre los hijos
        children: [
          Row(
            children: [
              Text(
                DateTime.now().day.toString(),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 55,
                ),
              ),
              const SizedBox(width: 16), // Espacio entre el día y la columna (opcional)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Alinea el texto del Column a la izquierda
                children: [
                  Text(
                    (DateTime.now().weekday >= 1 && DateTime.now().weekday <= 5)
                        ? _weekDaysFullName[DateTime.now().weekday - 1]
                        : "Fin de semana", // Mensaje alternativo para sábado y domingo
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    '${_getMonthName(DateTime.now().month)} ${DateTime.now().year}',
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
          Container(
            margin: const EdgeInsets.only(right: 8), // Margen derecho
            alignment: Alignment.center, // Centra el texto dentro del Container
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Espacio interno
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo, // Color de fondo
              borderRadius: BorderRadius.circular(16), // Bordes redondeados
            ),
            child: Text(
              'Hoy', // Condición para mostrar "Hoy" o "No hoy"
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
    // Verificar si hay eventos para el día seleccionado
    final hasEvents = _getFilteredEvents(_subjects, day).isNotEmpty;

    return GestureDetector(
      onTap: () => setState(() => _selectedDay = day),
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
                  : Colors.white.withValues( alpha: 0.45),
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
            if (hasEvents) // Mostrar círculo si hay eventos
              Positioned(
                bottom: 0, // Ajusta la posición vertical del círculo
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
    if (events.isEmpty) {
      // Si no hay eventos, devolver un Text en grande
      return Center(
        child: Text(
          'No hay clases',
          style: TextStyle(
            fontSize: 24, // Tamaño grande
            fontWeight: FontWeight.bold, // Negrita
            color: Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
                ? Colors.white // Color para modo oscuro
                : Colors.black, // Color para modo claro
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
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final events =
            groupedByDate[date]!..sort((a, b) {
              final timeA = DateTime.parse(
                '${a['event']['date']} ${a['event']['start_hour']}',
              );
              final timeB = DateTime.parse(
                '${b['event']['date']} ${b['event']['start_hour']}',
              );
              return timeA.compareTo(timeB);
            });

        // Detectar solapamientos
        final isOverlapping = List<bool>.filled(events.length, false);
        for (int i = 0; i < events.length - 1; i++) {
          final endTimeCurrent = DateTime.parse(
            '${events[i]['event']['date']} ${events[i]['event']['end_hour']}',
          );
          final startTimeNext = DateTime.parse(
            '${events[i + 1]['event']['date']} ${events[i + 1]['event']['start_hour']}',
          );

          if (endTimeCurrent.isAfter(startTimeNext)) {
            isOverlapping[i] = true;
            isOverlapping[i + 1] = true;
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
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
          ),
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
        return 'Clase de teória-práctica';
      default:
        return 'Clase de teória-práctica';
    }
  }

  List<String> _getWeekDates() {
    final now = DateTime.now();
    final startOfWeek = _startOfWeek(now);
    return List.generate(
      5,
      (index) => startOfWeek.add(Duration(days: index)).day.toString(),
    ); // Solo lunes a viernes
  }
}
