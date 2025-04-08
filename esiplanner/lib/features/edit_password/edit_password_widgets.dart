import 'package:flutter/material.dart';
import 'edit_password_logic.dart';

class EditPasswordForm extends StatelessWidget {
  final EditPasswordLogic logic;
  final bool isDarkMode;
  final VoidCallback onUpdate;

  const EditPasswordForm({
    super.key,
    required this.logic,
    required this.isDarkMode,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Introduzca su nueva contraseña',
                  textAlign: TextAlign.center, // Esta es la clave
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.indigo.shade900,
                  ),
                ),
                const SizedBox(height: 24),
                PasswordField(
                  controller: logic.newPasswordController,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 24),
                UpdatePasswordButton(onPressed: onUpdate),
                if (logic.errorMessage.isNotEmpty)
                  ErrorMessage(message: logic.errorMessage),
                if (logic.successMessage.isNotEmpty)
                  SuccessMessage(message: logic.successMessage),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDarkMode;

  const PasswordField({
    super.key,
    required this.controller,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Nueva Contraseña',
        prefixIcon: Icon(
          Icons.lock,
          color: isDarkMode ? Colors.white : Colors.indigo.shade700,
        ),
      ),
    );
  }
}

class UpdatePasswordButton extends StatelessWidget {
  final VoidCallback onPressed;

  const UpdatePasswordButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text(
        'Actualizar contraseña',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ErrorMessage extends StatelessWidget {
  final String message;

  const ErrorMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red, fontSize: 20),
      ),
    );
  }
}

class SuccessMessage extends StatelessWidget {
  final String message;

  const SuccessMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(
        message,
        style: const TextStyle(color: Colors.green, fontSize: 14),
      ),
    );
  }
}