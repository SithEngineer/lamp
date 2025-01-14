import 'package:flutter/material.dart';

/// Centralized theme configuration for Lamp app
/// Uses Material 3 design system with consistent styling
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Provides the main ThemeData for the application
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.black,
    );
  }
}
