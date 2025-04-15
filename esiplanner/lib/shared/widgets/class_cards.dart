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
        borderRadius: BorderRadius.circular(16.0),
        side: isOverlap
            ? const BorderSide(
                color: Colors.red,
                width: 2.0, // Borde más grueso en desktop
              )
            : BorderSide.none,
      ),
      elevation: 4,
      margin: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal:  0.0,
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
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subjectName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 12),
              _buildRow(
                Icons.school,
                classType,
                isDarkMode ? Colors.yellow.shade700 : Colors.blue.shade900,
                isDarkMode ? Colors.white : Colors.black,
              ),
              SizedBox(height: 8),
              _buildRow(
                Icons.access_time,
                '${event['start_hour']} - ${event['end_hour']}',
                isDarkMode ? Colors.yellow.shade700 : Colors.blue.shade900,
                isDarkMode ? Colors.white : Colors.black,
              ),
              SizedBox(height: 8),
              _buildRow(
                Icons.location_on,
                event['location'].toString(),
                isDarkMode ? Colors.yellow.shade700 : Colors.blue.shade900,
                isDarkMode ? Colors.white : Colors.black,
              ),
              if (isOverlap)
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
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
          size: 16,
          color: colorIcon,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: colorTexto,
              fontWeight: FontWeight.normal,
              fontSize: null,
            ),
          ),
        ),
      ],
    );
  }
}