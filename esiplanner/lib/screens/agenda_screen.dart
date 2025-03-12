import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../services/subject_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/class_cards.dart';
import '../providers/theme_provider.dart';
import 'package:intl/intl.dart';


class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => AgendaScreenState();
}

class AgendaScreenState extends State<AgendaScreen> {
  late ProfileService profileService;
  late SubjectService subjectService;

  bool isLoading = true;
  List<Map<String, dynamic>> subjects = [];
  String errorMessage = '';

  // Variables para el selector de semanas
  int selectedWeekIndex = 0; // Índice de la semana seleccionada
  List<DateTimeRange> weekRanges = []; // Lista de rangos de semanas del curso
  List<String> weekLabels = []; // Etiquetas para mostrar en el selector

  @override
  void initState() {
    super.initState();
    profileService = ProfileService();
    subjectService = SubjectService();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final String? username = Provider.of<AuthProvider>(context, listen: false).username;

    if (username == null) {
      if (mounted) {
        setState(() {
          errorMessage = 'Usuario no autenticado';
          isLoading = false;
        });
      }
      return;
    }

    try {
      final profileData = await profileService.getProfileData(username: username);

      final degree = profileData["degree"];
      final List<dynamic> userSubjects = profileData["subjects"] ?? [];

      if (degree != null && userSubjects.isNotEmpty) {
        List<Map<String, dynamic>> updatedSubjects = [];

        for (var subject in userSubjects) {
          final subjectData = await subjectService.getSubjectData(codeSubject: subject['code']);

          // Filtrar las clases según los tipos del usuario
          final List<dynamic> filteredClasses = subjectData['classes']
              .where((classData) {
                // Verificar si 'type' está presente en classData
                if (classData.containsKey('type')) {
                  // Convertir classData['type'] a String
                  final classType = classData['type'].toString();

                  // Convertir subject['types'] a List<String>
                  final List<String> userTypes = (subject['types'] as List<dynamic>).cast<String>();

                  // Verificar si el tipo de clase está en la lista de tipos del usuario
                  return userTypes.contains(classType);
                }
                return false; // Si no tiene 'type', no se incluye en los resultados
              })
              .toList();

          // Ordenar los eventos de cada clase por fecha
          for (var classData in filteredClasses) {
            classData['events'].sort((a, b) {
              DateTime dateA = DateTime.parse(a['date']);
              DateTime dateB = DateTime.parse(b['date']);
              return dateA.compareTo(dateB);
            });
          }

          // Ordenar las clases dentro de la asignatura por el primer evento de cada clase
          filteredClasses.sort((a, b) {
            DateTime dateA = DateTime.parse(a['events'][0]['date']);
            DateTime dateB = DateTime.parse(b['events'][0]['date']);
            return dateA.compareTo(dateB);
          });

          updatedSubjects.add({
            'name': subjectData['name'] ?? subject['name'],
            'code': subject['code'],
            'classes': filteredClasses, // Usar solo las clases filtradas
          });
        }

        if (mounted) {
          setState(() {
            subjects = updatedSubjects;
            isLoading = false;
          });
          _calculateWeekRanges(); // Calcular las semanas del curso
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = degree == null
                ? 'No se encontró el grado en los datos del perfil'
                : 'El usuario no tiene asignaturas';
            isLoading = false;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error al obtener los datos: $error';
          isLoading = false;
        });
      }
    }
  }

  String formatDateToFullDate(DateTime date) {
    return DateFormat('EEEE d MMMM y', 'es_ES').format(date);
  }

  // Calcular las semanas del curso
  void _calculateWeekRanges() {
    if (subjects.isEmpty) return;

    // Obtener la fecha de la primera y última clase
    DateTime? firstDate;
    DateTime? lastDate;

    for (var subject in subjects) {
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

    // Generar las semanas desde la primera hasta la última
    weekRanges = [];
    weekLabels = [];

    DateTime currentStart = _getStartOfWeek(firstDate);
    while (currentStart.isBefore(lastDate) || currentStart.isAtSameMomentAs(lastDate)) {
      DateTime currentEnd = currentStart.add(const Duration(days: 6));

      // Verificar si hay algún evento en esta semana
      bool hasEvents = false;
      for (var subject in subjects) {
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
        weekRanges.add(DateTimeRange(start: currentStart, end: currentEnd));
        weekLabels.add('${_formatDate(currentStart)} - ${_formatDate(currentEnd)}');
      }

      currentStart = currentStart.add(const Duration(days: 7));
    }

    if (mounted) {
      setState(() {});
    }
  }

  // Obtener el inicio de la semana (lunes)
  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // Formatear una fecha como "dd/MM/yyyy"
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String getGroupLabel(String letter) {
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
        return 'Clase de teoríco-práctica';
      default:
        return 'Clase de teoríco-práctica';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Obtén el ThemeProvider
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Elige una semana para ver tus clases',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.indigo, // Color de la barra de navegación
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  // Selector de semanas mejorado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButton<int>(
                      value: selectedWeekIndex,
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedWeekIndex = newValue!;
                        });
                      },
                      items: weekLabels.asMap().entries.map<DropdownMenuItem<int>>((entry) {
                        return DropdownMenuItem<int>(
                          value: entry.key,
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: isDarkMode ? Colors.white : Colors.indigo,
                                size: 18.0,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                entry.value,
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      underline: const SizedBox(), // Elimina la línea inferior por defecto
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: isDarkMode ? Colors.white : Colors.indigo,
                      ),
                      isExpanded: true,
                      dropdownColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (errorMessage.isNotEmpty) ...[
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],
                  Expanded(
                    child: _buildEventList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEventList() {
    if (weekRanges.isEmpty) {
      return const Center(child: Text('No hay clases disponibles'));
    }

    // Obtener el rango de fechas de la semana seleccionada
    final weekRange = weekRanges[selectedWeekIndex];

    // Recopilar todos los eventos de la semana seleccionada
    List<Map<String, dynamic>> allEvents = [];
    for (var subject in subjects) {
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

    // Agrupar los eventos por fecha
    Map<String, List<Map<String, dynamic>>> groupedByDate = {};
    for (var eventData in allEvents) {
      final eventDate = eventData['event']['date'];

      if (!groupedByDate.containsKey(eventDate)) {
        groupedByDate[eventDate] = [];
      }

      groupedByDate[eventDate]!.add(eventData);
    }

    // Ordenar los eventos por hora dentro de cada fecha
    groupedByDate.forEach((date, events) {
      events.sort((a, b) {
        DateTime timeA = DateTime.parse('${a['event']['date']} ${a['event']['start_hour']}');
        DateTime timeB = DateTime.parse('${b['event']['date']} ${b['event']['start_hour']}');
        return timeA.compareTo(timeB);
      });
    });

    // Ordenar las fechas
    var sortedDates = groupedByDate.keys.toList()..sort();

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final events = groupedByDate[date]!;

        // Verificar solapamientos
        List<bool> isOverlapping = List.filled(events.length, false);
        for (int i = 0; i < events.length - 1; i++) {
          DateTime endTimeCurrent = DateTime.parse('${events[i]['event']['date']} ${events[i]['event']['end_hour']}');
          DateTime startTimeNext = DateTime.parse('${events[i + 1]['event']['date']} ${events[i + 1]['event']['start_hour']}');

          if (endTimeCurrent.isAfter(startTimeNext)) {
            isOverlapping[i] = true;
            isOverlapping[i + 1] = true;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Título con la fecha
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                // Formatea la fecha usando DateFormat
              DateFormat('EEEE d MMMM y', 'es_ES').format(DateTime.parse(date)),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
            // Cards para cada evento utilizando CustomEventCard
            ...events.asMap().entries.map<Widget>((entry) {
              final index = entry.key;
              final eventData = entry.value;
              final event = eventData['event'];
              final classType = eventData['classType'];
              final subjectName = eventData['subjectName'];
              final bool isOverlap = isOverlapping[index];

              return ClassCards(
                subjectName: subjectName,
                classType: '$classType - ${getGroupLabel(classType[0])}',
                event: event,
                isOverlap: isOverlap,
              );
            }),
          ],
        );
      },
    );
  }
}