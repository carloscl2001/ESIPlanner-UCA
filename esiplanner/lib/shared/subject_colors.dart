import 'package:flutter/material.dart';

class SubjectColors {
  final Map<String, Color> _subjectColors = {};
  final bool isDarkMode;

  SubjectColors(this.isDarkMode);

  Color getSubjectColor(String subjectName) {
    if (_subjectColors.containsKey(subjectName)) {
      return _subjectColors[subjectName]!;
    }
    
    final colors = isDarkMode 
      ? [
          Colors.blue.shade700,
          Colors.green.shade700,
          Colors.orange.shade700,
          Colors.purple.shade700,
          Colors.red.shade700,
          Colors.teal.shade700,
          Colors.indigo.shade700,
          Colors.amber.shade700,
        ]
      : [
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.red,
          Colors.teal,
          Colors.indigo,
          Colors.amber,
        ];
    
    final color = colors[_subjectColors.length % colors.length];
    _subjectColors[subjectName] = color;
    return color;
  }

  static Color getCardBackgroundColor(Color subjectColor, bool isDarkMode) {
    return subjectColor.withAlpha(isDarkMode ? 77 : 51); // 0.3 and 0.2 opacity equivalents
  }
}