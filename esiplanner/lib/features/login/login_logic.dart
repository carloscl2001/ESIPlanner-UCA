import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class LoginLogic {
  final BuildContext context;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = "";

  LoginLogic(this.context);

  Future<void> login() async {
    final String username = usernameController.text.trim();
    final String password = passwordController.text.trim();

    final authService = AuthService();
    final result = await authService.login(
      username: username, 
      password: password
    );

    if (!context.mounted) return;

    if (result['success']) {
      final String? token = result['data']['access_token'];
      if (token != null) {
        Provider.of<AuthProvider>(context, listen: false).login(username, token);
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        errorMessage = 'No se recibió un token válido.';
      }
    } else {
      errorMessage = result['message'];
    }
    return;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese su usuario';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese su contraseña';
    }
    return null;
  }

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }
}