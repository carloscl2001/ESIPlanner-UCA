import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../services/subject_service.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart'; // Importa el ThemeProvider

class EditSubjectsProfileScreen extends StatefulWidget {
  const EditSubjectsProfileScreen({super.key});

  @override
  State<EditSubjectsProfileScreen> createState() =>
      _EditSubjectsProfileScreenState();
}

class _EditSubjectsProfileScreenState extends State<EditSubjectsProfileScreen> {
  late ProfileService profileService;
  late SubjectService subjectService;
  late AuthService authService;

  bool isLoading = true;
  List<Map<String, dynamic>> subjects = [];
  String errorMessage = '';
  Map<String, Set<String>> selectedGroupTypes = {}; // Almacenar grupos seleccionados por asignatura

  @override
  void initState() {
    super.initState();
    profileService = ProfileService();
    subjectService = SubjectService();
    authService = AuthService();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final String? username =
        Provider.of<AuthProvider>(context, listen: false).username;

    if (username != null) {
      try {
        final profileData = await profileService.getProfileData(username: username);
        final degree = profileData["degree"];

        if (degree != null) {
          final degreeData = await subjectService.getDegreeData(degreeName: degree);

          if (degreeData['subjects'] != null) {
            List<Map<String, dynamic>> updatedSubjects = [];

            for (var subject in degreeData['subjects']) {
              final subjectData = await subjectService.getSubjectData(codeSubject: subject['code']);
              updatedSubjects.add({
                'name': subjectData['name'] ?? subject['name'],
                'code': subject['code'],
                'classes': subjectData['classes'] ?? [],
              });
            }

            // Verifica si el widget está montado antes de llamar a setState
            if (mounted) {
              setState(() {
                subjects = updatedSubjects;
                isLoading = false;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                errorMessage = 'No se encontraron asignaturas para este grado';
                isLoading = false;
              });
            }
          }
        } else {
          if (mounted) {
            setState(() {
              errorMessage = 'No se encontró el grado en los datos del perfil';
              isLoading = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            errorMessage = 'Error al cargar los datos: $e';
            isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          errorMessage = 'Usuario no autenticado';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSelections() async {
    final String? username = Provider.of<AuthProvider>(context, listen: false).username;
    if (username == null) return;

    try {
      List<Map<String, dynamic>> selectedSubjects = selectedGroupTypes.entries.map((entry) {
        return {
          'code': entry.key,
          'types': entry.value.toList(),
        };
      }).toList();

      await subjectService.updateSubjects(username: username, subjects: selectedSubjects);

      // Muestra una notificación de éxito con un SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Align(
              alignment: Alignment.center, // Centra el texto dentro del SnackBar
              child: const Text(
                'Selecciones guardadas exitosamente',
                textAlign: TextAlign.center, // Asegura que el texto esté centrado
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      // Muestra una notificación de error con un SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
             content: Align(
              alignment: Alignment.center, // Centra el texto dentro del SnackBar
              child: const Text(
                'Error al guardar las selecciones',
                textAlign: TextAlign.center, // Asegura que el texto esté centrado
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String getGroupLabel(String letter) {
    switch (letter) {
      case 'A':
        return 'Grupo de teoría';
      case 'B':
        return 'Grupo de problemas';
      case 'C':
        return 'Grupo de prácticas informáticas';
      case 'D':
        return 'Prácticas de laboratorio';
      case 'X':
        return 'Grupo de teoría-prácticas';
      default:
        return 'Grupo $letter';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Obtén el ThemeProvider
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elige asignaturas y grupos', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSelections,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  if (errorMessage.isNotEmpty) ...[
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],
                  Expanded(
                    child: ListView.builder(
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjects[index];
                        Map<String, List<String>> groupedTypes = {};

                        for (var group in subject['classes']) {
                          final type = group['type'];
                          final letter = type[0];
                          if (!groupedTypes.containsKey(letter)) {
                            groupedTypes[letter] = [];
                          }
                          groupedTypes[letter]?.add(type);
                        }

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0), // Bordes más redondeados
                          ),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDarkMode
                                    ? [Colors.grey.shade900, Colors.grey.shade900] // Degradado oscuro
                                    : [Colors.indigo.shade50, Colors.white],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20.0), // Coincide con el radio de la tarjeta
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // Nombre de la asignatura con icono
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.book, // Icono para el nombre de la asignatura
                                        size: 24,
                                        color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo.shade700,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible( // Permite que el texto fluya a la siguiente línea
                                        child: Text(
                                          subject['name'] ?? 'No Name',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Código de la asignatura con icono
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.code, // Icono para el código
                                        size: 20,
                                        color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo.shade700,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible( // Permite que el texto fluya a la siguiente línea
                                        child: Text(
                                          subject['code'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: isDarkMode ? Colors.white : Colors.black,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Switch para seleccionar la asignatura
                                  SwitchListTile(
                                    title: Text(
                                      'Seleccionar asignatura',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isDarkMode ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    value: selectedGroupTypes.containsKey(subject['code']),
                                    onChanged: (bool selected) {
                                      setState(() {
                                        if (selected) {
                                          selectedGroupTypes[subject['code']] = {};
                                        } else {
                                          selectedGroupTypes.remove(subject['code']);
                                        }
                                      });
                                    },
                                    activeColor: isDarkMode ? Colors.yellow.shade700 : Colors.indigo // Color del interruptor cuando está activado
                                  ),
                                  // Grupos seleccionables
                                  if (selectedGroupTypes.containsKey(subject['code'])) ...[ 
                                    const SizedBox(height: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: groupedTypes.keys.map<Widget>((letter) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            // Etiqueta del grupo
                                            Text(
                                              getGroupLabel(letter),
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16,
                                                color: isDarkMode ? Colors.white : Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            // Chips para seleccionar los grupos
                                            Wrap(
                                              spacing: 8, // Espaciado horizontal entre chips
                                              runSpacing: 8, // Espaciado vertical entre chips
                                              children: groupedTypes[letter]!.map<Widget>((type) {
                                                return ChoiceChip(
                                                  label: Text(
                                                    type,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  selected: selectedGroupTypes[subject['code']]?.contains(type) ?? false,
                                                  onSelected: (bool selected) {
                                                    setState(() {
                                                      if (selected) {
                                                        selectedGroupTypes[subject['code']]!.removeWhere((t) => t.startsWith(letter));
                                                        selectedGroupTypes[subject['code']]!.add(type);
                                                      }
                                                    });
                                                  },
                                                  selectedColor:  isDarkMode ? Colors.black: Colors.indigo.shade100,
                                                  backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white, // Color de fondo cuando no está seleccionado
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12), // Bordes redondeados
                                                    side: BorderSide(color:  isDarkMode ? Colors.grey.shade200 : Colors.indigo.shade300), // Borde con color
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
