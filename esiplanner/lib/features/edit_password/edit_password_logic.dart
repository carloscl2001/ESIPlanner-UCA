import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/profile_service.dart';

class EditPasswordLogic {
  final TextEditingController newPasswordController = TextEditingController();
  String errorMessage = '';
  String successMessage = '';
  late ProfileService profileService;

  EditPasswordLogic() {
    profileService = ProfileService();
  }

  Future<void> updatePassword(BuildContext context) async {
    final String newPassword = newPasswordController.text;

    if (newPassword.isEmpty) {
      errorMessage = 'Por favor, ingrese una nueva contraseña';
      return;
    } else if (newPassword.length < 8) {
      errorMessage = 'La contraseña debe tener al menos 8 caracteres';
      return;
    } else if (!_isValidPassword(newPassword)) {
      errorMessage = 'La contraseña debe contener letras y números';
      return;
    }

    errorMessage = '';
    successMessage = '';

    final String? username = Provider.of<AuthProvider>(context, listen: false).username;
    if (username == null) {
      errorMessage = 'El nombre de usuario no está disponible';
      return;
    }

    final response = await profileService.updatePassword(
      username: username,
      newPassword: newPassword,
      context: context,
    );

    if (response['success']) {
      successMessage = response['message'];
      newPasswordController.clear();
    } else {
      errorMessage = response['message'];
    }
  }

  bool _isValidPassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');
    return passwordRegex.hasMatch(password);
  }

  void dispose() {
    newPasswordController.dispose();
  }
}