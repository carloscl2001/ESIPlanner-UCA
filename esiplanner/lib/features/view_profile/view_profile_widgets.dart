import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final bool isDarkMode;
  final String errorMessage;
  final Map<String, dynamic> userProfile;

  const ProfileCard({
    super.key,
    required this.isDarkMode,
    required this.errorMessage,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.black, Colors.black]
                : [Colors.indigo.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (errorMessage.isNotEmpty) ...[
                    Text(
                      errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],
                  ProfileField(
                    icon: Icons.person,
                    label: userProfile['username'] ?? 'Cargando...',
                    isDarkMode: isDarkMode,
                  ),
                  ProfileField(
                    icon: Icons.email,
                    label: userProfile['email'] ?? 'Cargando...',
                    isDarkMode: isDarkMode,
                  ),
                  ProfileField(
                    icon: Icons.badge,
                    label: userProfile['name'] ?? 'Cargando...',
                    isDarkMode: isDarkMode,
                  ),
                  ProfileField(
                    icon: Icons.family_restroom,
                    label: userProfile['surname'] ?? 'Cargando...',
                    isDarkMode: isDarkMode,
                  ),
                  ProfileField(
                    icon: Icons.school,
                    label: userProfile['degree'] ?? 'Cargando...',
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDarkMode;

  const ProfileField({
    super.key,
    required this.icon,
    required this.label,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: isDarkMode ? Colors.yellow.shade700 : Colors.blue.shade900,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}