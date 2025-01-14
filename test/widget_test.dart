// This is a basic Flutter widget test for the Lamp app.
//
// The Lamp app displays a full-screen color that can be changed by swiping
// or tapping color chips at the bottom of the screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lamp/main.dart';
import 'package:lamp/models/color_palette.dart';

void main() {
  testWidgets('ColorLampScreen renders without errors',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LampApp());

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('ColorPalette has 12 colors', (WidgetTester tester) async {
    // Verify that the color palette contains exactly 12 colors
    expect(ColorPalette.length, 12);
    expect(ColorPalette.colors.length, 12);
  });

  testWidgets('Initial color is red (first in palette)',
      (WidgetTester tester) async {
    // The initial color should be the first color in the palette (red)
    expect(ColorPalette.getColor(0), Colors.red);
  });

  testWidgets('ColorPalette getColor handles boundary conditions',
      (WidgetTester tester) async {
    // Negative indices should return first color
    expect(ColorPalette.getColor(-1), Colors.red);

    // Out of bounds should return first color
    expect(ColorPalette.getColor(100), Colors.red);

    // Valid index should return correct color
    expect(ColorPalette.getColor(1), Colors.purple);
  });
}
