import 'package:flutter/material.dart';

class ColorPalette {
  static const List<Color> colors = [
    Colors.red,
    Colors.purple,
    Colors.blue,
    Colors.cyan,
    Colors.green,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.pink,
    Colors.indigo,
  ];

  static int get length => colors.length;

  static Color getColor(int index) {
    if (index < 0 || index >= colors.length) {
      return colors[0];
    }
    return colors[index];
  }
}
