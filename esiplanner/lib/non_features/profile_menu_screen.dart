import 'package:flutter/material.dart';
import '../shared/widgets/profile_cards.dart';

class ProfileMenuScreen extends StatelessWidget {
  const ProfileMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // <-- Esto hace que toda la pantalla sea scrollable
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true, // Importante para usar dentro de Column
                  physics: const NeverScrollableScrollPhysics(), // Desactiva el scroll interno
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
                    // Puedes añadir más tarjetas aquí
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}