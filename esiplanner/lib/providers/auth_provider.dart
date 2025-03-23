import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _username;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;
  String? get token => _token;

  // Cargar el estado de autenticación y el nombre de usuario desde SharedPreferences
  Future<void> loadAuthState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _username = prefs.getString('username');
    _token = prefs.getString('token');
    notifyListeners();
  }

  // Función para realizar login y almacenar el token
  Future<void> login(String username, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isAuthenticated = true;
    _username = username;
    _token = token;

    // Guardar el estado de autenticación y el nombre de usuario en SharedPreferences
    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('username', username);
    await prefs.setString('token', token);
    notifyListeners();
  }

  Future<void> register(String username, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isAuthenticated = true; // El usuario está autenticado después del registro
    _username = username;
    _token = token;

    // Guardar el estado de autenticación, el nombre de usuario y el token en SharedPreferences
    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('username', username);
    await prefs.setString('token', token);

    notifyListeners();
  }

  // Función para cerrar sesión y limpiar los datos
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isAuthenticated = false;
    _username = null;
    _token = null;

    // Limpiar los datos de SharedPreferences
    await prefs.setBool('isAuthenticated', false);
    await prefs.remove('username');
    await prefs.remove('token');

    notifyListeners();
  }
}