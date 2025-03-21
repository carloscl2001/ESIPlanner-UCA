import 'package:flutter/material.dart';
import '../widgets/profile_cards.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Desactiva el desplazamiento
              children: const [
                ProfileCard(
                  text: 'Mi perfil',
                  icon: Icons.person,
                  route: '/viewProfile',
                ),
                ProfileCard(
                  text: 'Cambiar mi contraseña',
                  icon: Icons.lock,
                  route: '/editPassWordProfile',
                ),
                ProfileCard(
                  text: 'Mis asignaturas',
                  icon: Icons.school,
                  route: '/viewSubjectsProfile',
                ),
                ProfileCard(
                  text: 'Elegir mis asignaturas',
                  icon: Icons.edit,
                  route: '/editSubjectsProfile',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
