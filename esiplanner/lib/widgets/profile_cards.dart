import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart'; // Asegúrate de importar correctamente el provider

class ProfileCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final String route;

  const ProfileCard({
    super.key,
    required this.text,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Bordes más redondeados
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        borderRadius: BorderRadius.circular(
          20.0,
        ), // Bordes redondeados para el InkWell
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isDarkMode
                      ? [
                        Colors.grey.shade900,
                        Colors.grey.shade900,
                      ] // Degradado oscuro
                      : [
                        Colors.indigo.shade50,
                        Colors.white,
                      ], // Degradado claro
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(
              20.0,
            ), // Coincide con el radio de la tarjeta
          ),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color:
                      isDarkMode
                          ? Colors.yellow.shade700
                          : Colors.indigo.shade700, // Color del icono
                ),
                const SizedBox(
                  height: 12,
                ), // Espaciado entre el icono y el texto
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color:
                        isDarkMode
                            ? Colors.white
                            : Colors.black, // Color del texto
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
