import 'package:flutter/material.dart';

import '../models/color_palette.dart';

/// Simple color controller using ValueNotifier
/// Manages color index state and navigation logic
class ColorController extends ChangeNotifier {
  int _colorIndex = 0;

  int get colorIndex => _colorIndex;

  Color get currentColor => ColorPalette.getColor(_colorIndex);

  /// Navigate to next color (right swipe)
  /// Wraps around from last color to first
  void nextColor() {
    _colorIndex = (_colorIndex + 1) % ColorPalette.length;
    notifyListeners();
  }

  /// Navigate to previous color (left swipe)
  /// Wraps around from first color to last
  void previousColor() {
    _colorIndex = (_colorIndex - 1 + ColorPalette.length) % ColorPalette.length;
    notifyListeners();
  }

  /// Jump directly to a specific color by index
  /// Validates index is within bounds
  void selectColor(int index) {
    if (index >= 0 && index < ColorPalette.length) {
      _colorIndex = index;
      notifyListeners();
    }
  }

  /// Reset to first color
  void resetToFirstColor() {
    _colorIndex = 0;
    notifyListeners();
  }
}
