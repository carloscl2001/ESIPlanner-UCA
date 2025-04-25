import 'package:flutter/material.dart';
import '../shared/widgets/profile_cards.dart';

class ProfileMenuScreen extends StatelessWidget {
  const ProfileMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth > 1024;

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: screenHeight, // Toma toda la altura disponible
          child: SizedBox(
            height: screenHeight, // Forza el centrado vertical
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Centrado vertical
                children: [
                  SizedBox(
                    width: isDesktop ? screenWidth * 0.85 : 800,
                    child: GridView.count(
                      crossAxisCount: isDesktop ? 4 : 2,
                      mainAxisSpacing: 25,
                      crossAxisSpacing: 25,
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 40 : 20,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.0,
                      children: const [
                        ProfileCard(
                          text: 'Mi perfil',
                          icon: Icons.person_pin,
                          route: '/viewProfile',
                        ),
                        ProfileCard(
                          text: 'Cambiar mi contraseña',
                          icon: Icons.password_rounded,
                          route: '/editPassWord',
                        ),
                        ProfileCard(
                          text: 'Mis asignaturas',
                          icon: Icons.book_rounded,
                          route: '/viewSubjects',
                        ),
                        ProfileCard(
                          text: 'Seleccionar asignaturas',
                          icon: Icons.edit_note_rounded,
                          route: '/selectionSubjects',
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
    );
  }
}