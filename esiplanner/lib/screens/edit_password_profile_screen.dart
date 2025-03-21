import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart'; // Importa el ThemeProvider

class EditPasswordProfileScreen extends StatefulWidget {
  const EditPasswordProfileScreen({super.key});

  @override
  State<EditPasswordProfileScreen> createState() =>
      _EditPasswordProfileScreenState();
}

class _EditPasswordProfileScreenState extends State<EditPasswordProfileScreen> {
  late ProfileService profileService;
  String errorMessage = '';
  String successMessage = '';
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    profileService = ProfileService();
  }

  Future<void> _updatePassword() async {
    bool isValidPassword(String password) {
      final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');
      return passwordRegex.hasMatch(password);
    }

    final String newPassword = _newPasswordController.text;

    if (newPassword.isEmpty) {
      setState(() {
        errorMessage = 'Por favor, ingrese una nueva contraseña';
        successMessage = '';
      });
      return;
    } else if (newPassword.length < 8) {
      setState(() {
        errorMessage = 'La contraseña debe tener al menos 8 caracteres';
        successMessage = '';
      });
      return;
    } else if (!isValidPassword(newPassword)) {
      setState(() {
        errorMessage = 'La contraseña debe contener letras y números';
        successMessage = '';
      });
      return;
    }

    setState(() {
      errorMessage = '';
      successMessage = '';
    });

    final String? username =
        Provider.of<AuthProvider>(context, listen: false).username;

    if (username != null) {
      final response = await profileService.updatePassword(
        username: username,
        newPassword: newPassword,
        context: context,
      );

      setState(() {
        if (response['success']) {
          successMessage = response['message'];
          // Vaciar el input de la nueva contraseña al recibir el éxito
          _newPasswordController.clear();
        } else {
          errorMessage = response['message'];
        }
      });
    } else {
      setState(() {
        errorMessage = 'El nombre de usuario no está disponible';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Obtén el ThemeProvider
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cambiar tu contraseña',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // Bordes más redondeados
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0), // Coincide con el radio de la tarjeta
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    Text(
                      'Introduzca su nueva contraseña',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                         color: isDarkMode ? Colors.white : Colors.indigo.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Nueva Contraseña',
                        prefixIcon: Icon(
                          Icons.lock, // Icono para el campo de contraseña
                          color: isDarkMode ? Colors.white : Colors.indigo.shade700, // Color del icono
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _updatePassword,
                      child: const Text(
                        'Actualizar contraseña',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Los mensajes de error y éxito aparecerán aquí debajo
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red, fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (successMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          successMessage,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}