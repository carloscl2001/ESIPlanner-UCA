import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/profile_cards.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.indigo,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25), // Ajusta el radio para cambiar la curvatura
          ),
        ),
      ),
      body: Column(
        children: [
          // GridView con las tarjetas reutilizando CustomCard
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              children: const [
                ProfileCard(
                  text: 'Mi perfil',
                  icon: Icons.person,
                  route: '/viewProfile',
                ),
                ProfileCard(
                  text: 'Cambiar la contraseña',
                  icon: Icons.lock,
                  route: '/editPassWordProfile',
                ),
                ProfileCard(
                  text: 'Mis asignaturas',
                  icon: Icons.school,
                  route: '/viewSubjectsProfile',
                ),
                ProfileCard(
                  text: 'Cambiar mis asignaturas',
                  icon: Icons.edit,
                  route: '/editSubjectsProfile',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}