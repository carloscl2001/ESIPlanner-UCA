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
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    final cardWidth = isDesktop ? 600.0 : double.infinity;
    final padding = isDesktop ? 24.0 : 24.0;
    final titleFontSize = isDesktop ? 28.0 : 24.0;
    final spacing = 24.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
        child: SizedBox(
          width: cardWidth,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [Colors.grey.shade900, Colors.black]
                      : [Colors.indigo.shade50, Colors.white],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Introduzca su nueva contraseña',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.indigo.shade900,
                      ),
                    ),
                    SizedBox(height: spacing),
                    PasswordField(
                      controller: logic.newPasswordController,
                      isDarkMode: isDarkMode,
                      isDesktop: isDesktop,
                    ),
                    SizedBox(height: spacing),
                    UpdatePasswordButton(
                      onPressed: onUpdate,
                      isDesktop: isDesktop,
                    ),
                    if (logic.errorMessage.isNotEmpty)
                      ErrorMessage(
                        message: logic.errorMessage,
                        isDesktop: isDesktop,
                      ),
                    if (logic.successMessage.isNotEmpty)
                      SuccessMessage(
                        message: logic.successMessage,
                        isDesktop: isDesktop,
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

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDarkMode;
  final bool isDesktop;

  const PasswordField({
    super.key,
    required this.controller,
    required this.isDarkMode,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      style: TextStyle(
        fontSize: isDesktop ? 18.0 : 16.0,
      ),
      decoration: InputDecoration(
        labelText: 'Nueva Contraseña',
        labelStyle: TextStyle(
          fontSize: isDesktop ? 16.0 : 16.0,
        ),
        prefixIcon: Icon(
          Icons.lock,
          size: isDesktop ? 28.0 : 24.0,
          color: isDarkMode ? Colors.white : Colors.indigo.shade700,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: isDesktop ? 18.0 : 14.0,
          horizontal: 16.0,
        ),
      ),
    );
  }
}

class UpdatePasswordButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isDesktop;

  const UpdatePasswordButton({
    super.key,
    required this.onPressed,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Actualizar contraseña',
          style: TextStyle(
            fontSize: isDesktop ? 18.0 : 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class ErrorMessage extends StatelessWidget {
  final String message;
  final bool isDesktop;

  const ErrorMessage({
    super.key,
    required this.message,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: isDesktop ? 24.0 : 16.0),
      child: Text(
        message,
        style: TextStyle(
          color: Colors.red,
          fontSize: isDesktop ? 18.0 : 14.0,
        ),
      ),
    );
  }
}

class SuccessMessage extends StatelessWidget {
  final String message;
  final bool isDesktop;

  const SuccessMessage({
    super.key,
    required this.message,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: isDesktop ? 24.0 : 16.0),
      child: Text(
        message,
        style: TextStyle(
          color: Colors.green,
          fontSize: isDesktop ? 18.0 : 14.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}