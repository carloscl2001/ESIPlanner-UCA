import 'package:flutter/material.dart';

class SubjectColors {
  final Map<String, Color> _subjectColors = {};
  final bool isDarkMode;
  int _nextColorIndex = 0; // Índice para el próximo color a asignar

  SubjectColors(this.isDarkMode);

  // Paleta ordenada de colores (8 para cada modo)
  static final _lightPalette = [
    Colors.blue.shade700,
    Colors.green.shade700,
    Colors.orange.shade700,
    Colors.purple.shade700,
    Colors.red.shade700,
    Colors.teal.shade700,
    Colors.indigo.shade700,
    Colors.amber.shade700,
    Colors.lime.shade700,
    Colors.cyan.shade700,
    Colors.deepOrange.shade700,
    Colors.deepPurple.shade700,
    Colors.pink.shade700,
    Colors.brown.shade700,
    Colors.lightBlue.shade700,
    Colors.lightGreen.shade700,
  ];

  static final _darkPalette = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.lime.shade400,
    Colors.cyan.shade400,
    Colors.deepOrange.shade400,
    Colors.deepPurple.shade400,
    Colors.pink.shade400,
    Colors.brown.shade400,
    Colors.lightBlue.shade400,
    Colors.lightGreen.shade400,
  ];

  Color getSubjectColor(String subjectName) {
    return _subjectColors.putIfAbsent(subjectName, () {
      final palette = isDarkMode ? _darkPalette : _lightPalette;
      
      // Si ya asignamos todos los colores, reiniciamos el índice
      if (_nextColorIndex >= palette.length) {
        _nextColorIndex = 0;
      }

      // Obtenemos el color actual y avanzamos el índice
      final color = palette[_nextColorIndex];
      _nextColorIndex++;
      
      return color;
    });
  }

  static Color getCardBackgroundColor(Color subjectColor, bool isDarkMode) {
    return subjectColor.withAlpha(isDarkMode ? 77 : 51);
  }

  // Método para debug
  void printAssignments() {
    _subjectColors.forEach((subject, color) {
      debugPrint('$subject → ${color.toString()}');
    });
  }
}