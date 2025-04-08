import 'package:flutter/material.dart';
import 'register_logic.dart';

// Define all field widgets first
class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDarkMode;

  const EmailField({
    super.key,
    required this.controller,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(
          Icons.email,
          color: isDarkMode ? Colors.white : Colors.indigo.shade700,
        ),
      ),
      validator: (value) => RegisterLogic(context).validateEmail(value),
    );
  }
}

class UsernameField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDarkMode;

  const UsernameField({
    super.key,
    required this.controller,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Nombre de usuario',
        prefixIcon: Icon(
          Icons.person,
          color: isDarkMode ? Colors.white : Colors.indigo.shade700,
        ),
      ),
      validator: (value) => RegisterLogic(context).validateUsername(value),
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
        labelText: 'Contraseña',
        prefixIcon: Icon(
          Icons.lock,
          color: isDarkMode ? Colors.white : Colors.indigo.shade700,
        ),
      ),
      validator: (value) => RegisterLogic(context).validatePassword(value),
    );
  }
}

class NameField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDarkMode;
  final String label;

  const NameField({
    super.key,
    required this.controller,
    required this.isDarkMode,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          label == 'Nombre' ? Icons.badge : Icons.family_restroom,
          color: isDarkMode ? Colors.white : Colors.indigo.shade700,
        ),
      ),
      validator: (value) => 
          RegisterLogic(context).validateName(value, label.toLowerCase()),
    );
  }
}

class DegreeDropdown extends StatelessWidget {
  final List<String> degrees;
  final String? selectedDegree;
  final bool isDarkMode;
  final ValueChanged<String?> onChanged;

  const DegreeDropdown({
    super.key,
    required this.degrees,
    required this.selectedDegree,
    required this.isDarkMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return degrees.isNotEmpty
        ? DropdownButtonFormField<String>(
            value: selectedDegree,
            onChanged: onChanged,
            decoration: InputDecoration(
              labelText: 'Grado',
              prefixIcon: Icon(
                Icons.school,
                color: isDarkMode ? Colors.white : Colors.indigo.shade700,
              ),
            ),
            isExpanded: true,
            items: degrees.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            selectedItemBuilder: (BuildContext context) {
              return degrees.map<Widget>((String value) {
                return Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                );
              }).toList();
            },
          )
        : const Center(child: CircularProgressIndicator());
  }
}

class RegisterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDarkMode;

  const RegisterButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          :  Text(
              'Registrarse',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ?Colors.black : Colors.white,
              ),
            ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final bool isDarkMode;

  const LoginButton({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
      style: TextButton.styleFrom(
        foregroundColor: isDarkMode ? Colors.white : Colors.indigo.shade700,
      ),
      child: const Text(
        "¿Ya tienes una cuenta? Inicia sesión aquí",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    return Text(
      message,
      style: const TextStyle(color: Colors.red, fontSize: 14),
      textAlign: TextAlign.center,
      softWrap: true,
    );
  }
}

// Main form widgets
class RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final RegisterLogic logic;
  final bool isDarkMode;
  final VoidCallback onRegisterPressed;
  final bool isLoading;

  const RegisterForm({
    super.key,
    required this.formKey,
    required this.logic,
    required this.isDarkMode,
    required this.onRegisterPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          RegisterCard(
            formKey: formKey,
            logic: logic,
            isDarkMode: isDarkMode,
            onRegisterPressed: onRegisterPressed,
            isLoading: isLoading,
          ),
          const SizedBox(height: 20),
          LoginButton(isDarkMode: isDarkMode),
        ],
      ),
    );
  }
}

class RegisterCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final RegisterLogic logic;
  final bool isDarkMode;
  final VoidCallback onRegisterPressed;
  final bool isLoading;

  const RegisterCard({
    super.key,
    required this.formKey,
    required this.logic,
    required this.isDarkMode,
    required this.onRegisterPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [const Color.fromARGB(255, 24, 24, 24), const Color.fromARGB(255, 24, 24, 24)]
                : [Colors.indigo.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Registrarse',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.indigo.shade900,
                  ),
                ),
                const SizedBox(height: 24),
                EmailField(controller: logic.emailController, isDarkMode: isDarkMode),
                const SizedBox(height: 20),
                UsernameField(controller: logic.usernameController, isDarkMode: isDarkMode),
                const SizedBox(height: 20),
                PasswordField(controller: logic.passwordController, isDarkMode: isDarkMode),
                const SizedBox(height: 20),
                NameField(
                  controller: logic.nameController,
                  isDarkMode: isDarkMode,
                  label: 'Nombre',
                ),
                const SizedBox(height: 20),
                NameField(
                  controller: logic.surnameController,
                  isDarkMode: isDarkMode,
                  label: 'Apellido',
                ),
                const SizedBox(height: 20),
                DegreeDropdown(
                  degrees: logic.degrees,
                  selectedDegree: logic.selectedDegree,
                  isDarkMode: isDarkMode,
                  onChanged: (value) => logic.selectedDegree = value,
                ),
                const SizedBox(height: 24),
                RegisterButton(
                  onPressed: onRegisterPressed,
                  isLoading: isLoading,
                  isDarkMode: isDarkMode,
                ),
                if (logic.errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ErrorMessage(message: logic.errorMessage),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}