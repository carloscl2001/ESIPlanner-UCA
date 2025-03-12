import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _username;
  String? _token; // Agregar el campo para almacenar el token

  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;
  String? get token => _token; // Agregar un getter para acceder al token

  // Función para realizar login y almacenar el token
  void login(String username, String token) {
    _isAuthenticated = true;
    _username = username;
    _token = token; // Almacenar el token al iniciar sesión
    notifyListeners();
  }
  
    // Función para registro (sin token)
  void register(String username) {
    _isAuthenticated = false; // No está autenticado hasta que se loguee
    _username = username;
    _token = null; // No hay token en este caso
    notifyListeners();
  }

  // Función para cerrar sesión y limpiar los datos
  void logout() {
    _isAuthenticated = false;
    _username = null;
    _token = null; // Limpiar el token al cerrar sesión
    notifyListeners();
  }
}