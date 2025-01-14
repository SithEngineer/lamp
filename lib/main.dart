import 'package:flutter/material.dart';

import 'screens/color_lamp_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const LampApp());
}

class LampApp extends StatelessWidget {
  const LampApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lamp',
      theme: AppTheme.theme,
      home: const ColorLampScreen(),
    );
  }
}
