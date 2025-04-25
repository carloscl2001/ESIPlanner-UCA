import 'package:flutter/material.dart';

class AppColors {
  static const List<Color> darkPalette = [
    Colors.blueGrey,
    Colors.tealAccent,
    Colors.deepOrangeAccent,
    Colors.purpleAccent,
    Colors.redAccent,
    Colors.cyanAccent,
    Colors.indigoAccent,
    Colors.amberAccent,
  ];

  static const List<Color> lightPalette = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
  ];


  Color getColor(int index, bool isDarkMode) {
    if (isDarkMode) {
      return darkPalette[index % darkPalette.length];
    } else {
      return lightPalette[index % lightPalette.length];
    }
  }

  Color getColorByIndex(int index, bool isDarkMode) {
    return getColor(index, isDarkMode);
  }

  
}