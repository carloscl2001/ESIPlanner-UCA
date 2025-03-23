import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart'; // Importa el ThemeProvider

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController degreeController = TextEditingController();

  String errorMessage = "";
  List<String> degrees = []; // Lista para almacenar los grados
  String? selectedDegree; // Variable para el grado seleccionado

  @override
  void initState() {
    super.initState();
    _loadDegrees(); // Cargar grados al iniciar la pantalla
  }

  // Método para cargar los grados desde la API
  Future<void> _loadDegrees() async {
    try {
      final authService = AuthService();
      final degreeList = await authService.getDegrees();
      setState(() {
        degrees = degreeList;
        selectedDegree =
            degrees.isNotEmpty
                ? degrees[0]
                : null; // Establece el primer grado como seleccionado si hay alguno
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar los grados';
      });
    }
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authService = AuthService();
    final result = await authService.register(
      email: emailController.text.trim(),
      username: usernameController.text.trim(),
      password: passwordController.text.trim(),
      name: nameController.text.trim(),
      surname: surnameController.text.trim(),
      degree: selectedDegree ?? '', // Usar el grado seleccionado
    );

    if (result['success']) {
      context.read<AuthProvider>().register(usernameController.text, result['token']);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        errorMessage = result['message'];
      });
    }
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');
    return passwordRegex.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(
      context,
    ); // Obtén el ThemeProvider
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 40),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    20.0,
                  ), // Bordes más redondeados
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isDarkMode
                              ? [
                                Colors.grey.shade800,
                                Colors.grey.shade800,
                              ] // Degradado oscuro
                              : [
                                Colors.indigo.shade50,
                                Colors.white,
                              ], // Degradado clarodado claro // Degradado suave
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                      20.0,
                    ), // Coincide con el radio de la tarjeta
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 20),
                          Text(
                            'Registrarse',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode
                                      ? Colors.white
                                      : Colors.indigo.shade900,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Campo email
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(
                                Icons.email, // Icono para el campo de email
                                color:
                                    isDarkMode
                                        ? Colors.white
                                        : Colors.indigo.shade700,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese un email';
                              } else if (!isValidEmail(value)) {
                                return 'Ingrese un email válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Campo nombre de usuario
                          TextFormField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              labelText: 'Nombre de usuario',
                              prefixIcon: Icon(
                                Icons
                                    .person, // Icono para el campo de nombre de usuario
                                color:
                                    isDarkMode
                                        ? Colors.white
                                        : Colors.indigo.shade700,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese un nombre de usuario';
                              } else if (value.length < 4) {
                                return 'Debe tener al menos 4 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Campo contraseña
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icon(
                                Icons.lock, // Icono para el campo de contraseña
                                color:
                                    isDarkMode
                                        ? Colors.white
                                        : Colors.indigo.shade700,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese una contraseña';
                              } //else if (value.length < 8) {
                                //return 'Debe tener al menos 8 caracteres';
                              //} else if (!isValidPassword(value)) {
                                //return 'Debe contener letras y números';
                              //}
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Campo nombre
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Nombre',
                              prefixIcon: Icon(
                                Icons.badge, // Icono para el campo de nombre
                                color:
                                    isDarkMode
                                        ? Colors.white
                                        : Colors.indigo.shade700,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese su nombre';
                              } else if (value.length < 4) {
                                return 'Debe tener al menos 4 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Campo apellido
                          TextFormField(
                            controller: surnameController,
                            decoration: InputDecoration(
                              labelText: 'Apellido',
                              prefixIcon: Icon(
                                Icons
                                    .family_restroom, // Icono para el campo de apellido
                                color:
                                    isDarkMode
                                        ? Colors.white
                                        : Colors.indigo.shade700,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese su apellido';
                              } else if (value.length < 4) {
                                return 'Debe tener al menos 4 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // DropdownButtonFormField para seleccionar el grado
                          if (degrees.isNotEmpty) ...[
                            DropdownButtonFormField<String>(
                              value: selectedDegree,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedDegree = newValue;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Grado',
                                prefixIcon: Icon(
                                  Icons.school, // Icono para el campo de grado
                                  color:
                                      isDarkMode
                                          ? Colors.white
                                          : Colors.indigo.shade700,
                                ),
                              ),
                              items:
                                  degrees.map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          color:
                                              isDarkMode
                                                  ? Colors.white
                                                  : Colors.indigo.shade900,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ] else ...[
                            const CircularProgressIndicator(), // Cargando si los grados están siendo obtenidos
                          ],
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: register,
                            child: const Text(
                              'Registrarse',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: TextButton.styleFrom(
                  foregroundColor:
                      isDarkMode
                          ? Colors.white
                          : Colors.indigo.shade700, // Color del texto
                ),
                child: const Text(
                  "¿Ya tienes una cuenta? Inicia sesión aquí",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
