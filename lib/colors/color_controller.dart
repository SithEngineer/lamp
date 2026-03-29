import 'package:flutter/material.dart';

import '../models/color_palette.dart';

/// Simple color controller using ValueNotifier
/// Manages color index state and navigation logic
class ColorController extends ChangeNotifier {
  int _colorIndex = 0;
  double _brightness = 1.0; // 0.0 to 1.0, where 1.0 is full brightness

  int get colorIndex => _colorIndex;

  /// Get the base color from the palette
  Color get currentColor => ColorPalette.getColor(_colorIndex);

  /// Get the color adjusted by brightness
  Color get adjustedColor {
    // Adjust brightness by interpolating between black and the current color
    return Color.lerp(Colors.black, currentColor, _brightness)!;
  }

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

  /// Increase brightness (up swipe) - bigger step for faster adjustment
  void increaseBrightness() {
    _brightness = (_brightness + 0.25).clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Decrease brightness (down swipe) - bigger step for faster adjustment
  void decreaseBrightness() {
    _brightness = (_brightness - 0.25).clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Reset to first color and full brightness
  void resetToFirstColor() {
    _colorIndex = 0;
    _brightness = 1.0;
    notifyListeners();
  }
}
