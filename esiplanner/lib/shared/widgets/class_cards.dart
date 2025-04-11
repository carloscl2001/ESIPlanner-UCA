import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ClassCards extends StatelessWidget {
  final String subjectName;
  final String classType;
  final Map<String, dynamic> event;
  final bool isOverlap;
  final bool isDesktop; // Nuevo parámetro para detectar pantallas grandes

  const ClassCards({
    super.key,
    required this.subjectName,
    required this.classType,
    required this.event,
    required this.isOverlap,
    this.isDesktop = false, // Valor por defecto false
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 20.0 : 16.0),
        side: isOverlap
            ? const BorderSide(
                color: Colors.red,
                width: 2.0, // Borde más grueso en desktop
              )
            : BorderSide.none,
      ),
      elevation: isDesktop ? 6 : 4,
      margin: EdgeInsets.symmetric(
        vertical: isDesktop ? 12.0 : 8.0,
        horizontal: isDesktop ? 300 : 0.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
                    Colors.black,
                    const Color.fromARGB(173, 44, 43, 43),
                  ]
                : [
                    Colors.indigo.shade50,
                    Colors.white,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(isDesktop ? 20.0 : 16.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subjectName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 24 : 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: isDesktop ? 16 : 12),
              _buildRow(
                Icons.school,
                classType,
                isDarkMode ? Colors.yellow.shade700 : Colors.blue.shade900,
                isDarkMode ? Colors.white : Colors.black,
              ),
              SizedBox(height: isDesktop ? 12 : 8),
              _buildRow(
                Icons.access_time,
                '${event['start_hour']} - ${event['end_hour']}',
                isDarkMode ? Colors.yellow.shade700 : Colors.blue.shade900,
                isDarkMode ? Colors.white : Colors.black,
              ),
              SizedBox(height: isDesktop ? 12 : 8),
              _buildRow(
                Icons.location_on,
                event['location'].toString(),
                isDarkMode ? Colors.yellow.shade700 : Colors.blue.shade900,
                isDarkMode ? Colors.white : Colors.black,
              ),
              if (isOverlap)
                Padding(
                  padding: EdgeInsets.only(top: isDesktop ? 12.0 : 8.0),
                  child: _buildRow(
                    Icons.warning,
                    'Este evento se solapa con otro',
                    Colors.red,
                    Colors.red,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    IconData icon,
    String text,
    Color colorIcon,
    Color colorTexto,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: isDesktop ? 20 : 16,
          color: colorIcon,
        ),
        SizedBox(width: isDesktop ? 12 : 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: colorTexto,
              fontWeight: FontWeight.normal,
              fontSize: isDesktop ? 18 : null,
            ),
          ),
        ),
      ],
    );
  }
}