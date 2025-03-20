import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart'; // Importa el ThemeProvider

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  late ProfileService profileService;

  Map<String, dynamic> userProfile = {};
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    profileService = ProfileService();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final String? username =
        Provider.of<AuthProvider>(context, listen: false).username;

    if (username != null) {
      final profileData = await profileService.getProfileData(
        username: username,
      );

      setState(() {
        if (profileData.isEmpty) {
          errorMessage = 'No se pudo obtener la información del perfil';
        } else {
          userProfile = profileData;
        }
      });
    } else {
      setState(() {
        errorMessage = "El nombre de usuario no está disponible";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(
      context,
    ); // Obtén el ThemeProvider
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tu perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  20.0,
                ), // Bordes más redondeados
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        isDarkMode
                            ? [
                              Colors.grey.shade800,
                              Colors.grey.shade800,
                            ] // Degradado oscuro
                            : [
                              Colors.indigo.shade50,
                              Colors.white,
                            ], // Degradado clarodado claro
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(
                    20.0,
                  ), // Coincide con el radio de la tarjeta
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
                          // Campos de perfil con iconos
                          ProfileField(
                            icon: Icons.person,
                            label: userProfile['username'] ?? 'Cargando...',
                          ),
                          ProfileField(
                            icon: Icons.email,
                            label: userProfile['email'] ?? 'Cargando...',
                          ),
                          ProfileField(
                            icon: Icons.badge,
                            label: userProfile['name'] ?? 'Cargando...',
                          ),
                          ProfileField(
                            icon: Icons.family_restroom,
                            label: userProfile['surname'] ?? 'Cargando...',
                          ),
                          ProfileField(
                            icon: Icons.school,
                            label: userProfile['degree'] ?? 'Cargando...',
                          ),
                        ],
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

class ProfileField extends StatelessWidget {
  final IconData icon;
  final String label;

  const ProfileField({required this.icon, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(
      context,
    ); // Obtén el ThemeProvider
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

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
            color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo.shade700,
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
