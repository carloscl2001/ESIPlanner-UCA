import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart'; // Importa el ThemeProvider

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = "";
 
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }



    final String username = usernameController.text;
    final String password = passwordController.text;

    final authService = AuthService();
    final result = await authService.login(username: username, password: password);

   

    if (result['success']) {
      final String? token = result['data']['access_token']; // Accediendo al token correctamente
      if (token != null) {
        context.read<AuthProvider>().login(username, token);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          errorMessage = 'No se recibió un token válido.';
        });
      }
    } else {
      setState(() {
        errorMessage = result['message']; // Mostrar el mensaje de error si el login falla
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Obtén el ThemeProvider
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 40),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Bordes más redondeados
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkMode
                        ? [Colors.grey.shade800, Colors.grey.shade800] // Degradado oscuro
                        : [Colors.indigo.shade50, Colors.white], // Degradado clarodado claro
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.0), // Coincide con el radio de la tarjeta
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 20),
                          Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.indigo.shade900,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Campo de usuario
                          TextFormField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              labelText: 'Usuario',
                              prefixIcon: Icon(
                                Icons.person, // Icono para el campo de usuario
                                color: isDarkMode ? Colors.white : Colors.indigo.shade700,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingrese su usuario';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Campo de contraseña
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icon(
                                Icons.lock, // Icono para el campo de contraseña
                                color: isDarkMode ? Colors.white : Colors.indigo.shade700,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingrese su contraseña';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          // Botón de inicio de sesión
                          ElevatedButton(
                            onPressed: login, // Deshabilita el botón si está cargando
                            child: 
                              const Text(
                                'Iniciar sesión',
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
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
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
                  Navigator.pushReplacementNamed(context, '/register');
                },
                style: TextButton.styleFrom(
                  foregroundColor: isDarkMode ? Colors.white : Colors.indigo.shade700, // Color del texto
                ),
                child: const Text(
                  "¿No tienes una cuenta? Regístrate aquí",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}