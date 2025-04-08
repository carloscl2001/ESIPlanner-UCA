import 'package:flutter/material.dart';
import '../shared/widgets/profile_cards.dart';

class ProfileMenuScreen extends StatelessWidget {
  const ProfileMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Envolvemos el contenido con un Center
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centra el contenido verticalmente
          children: [
            // GridView con las tarjetas reutilizando CustomCard
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Desactiva el desplazamiento
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
          ],
        ),
      ),
    );
  }
}
