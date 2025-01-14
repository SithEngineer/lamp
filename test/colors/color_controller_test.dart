import 'package:flutter_test/flutter_test.dart';
import 'package:lamp/colors/color_controller.dart';
import 'package:lamp/models/color_palette.dart';

void main() {
  group('ColorController', () {
    late ColorController controller;

    setUp(() {
      controller = ColorController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('initializes with index 0', () {
      expect(controller.colorIndex, 0);
    });

    group('nextColor', () {
      test('increments color index', () {
        controller.nextColor();
        expect(controller.colorIndex, 1);
      });

      test('increments multiple times', () {
        controller.nextColor();
        controller.nextColor();
        controller.nextColor();
        expect(controller.colorIndex, 3);
      });

      test('wraps around from end to start', () {
        for (int i = 0; i < 12; i++) {
          controller.nextColor();
        }
        expect(controller.colorIndex, 0);
      });
    });

    group('previousColor', () {
      test('decrements color index', () {
        controller.selectColor(3);
        controller.previousColor();
        expect(controller.colorIndex, 2);
      });

      test('decrements multiple times', () {
        controller.selectColor(5);
        controller.previousColor();
        controller.previousColor();
        controller.previousColor();
        expect(controller.colorIndex, 2);
      });

      test('wraps around from start to end', () {
        controller.previousColor();
        expect(controller.colorIndex, 11);
      });

      test('wraps around multiple times', () {
        controller.previousColor();
        controller.previousColor();
        expect(controller.colorIndex, 10);
      });
    });

    group('selectColor', () {
      test('jumps to specific color index', () {
        controller.selectColor(5);
        expect(controller.colorIndex, 5);
      });

      test('jumps to index 0', () {
        controller.selectColor(10);
        controller.selectColor(0);
        expect(controller.colorIndex, 0);
      });

      test('jumps to last valid index', () {
        controller.selectColor(11);
        expect(controller.colorIndex, 11);
      });

      test('ignores invalid negative index', () {
        controller.selectColor(5);
        controller.selectColor(-1);
        expect(controller.colorIndex, 5);
      });

      test('ignores out of bounds positive index', () {
        controller.selectColor(5);
        controller.selectColor(12);
        expect(controller.colorIndex, 5);
      });

      test('ignores out of bounds large index', () {
        controller.selectColor(5);
        controller.selectColor(100);
        expect(controller.colorIndex, 5);
      });
    });

    group('resetToFirstColor', () {
      test('resets to index 0', () {
        controller.selectColor(7);
        controller.resetToFirstColor();
        expect(controller.colorIndex, 0);
      });

      test('resets when already at first color', () {
        expect(controller.colorIndex, 0);
        controller.resetToFirstColor();
        expect(controller.colorIndex, 0);
      });
    });

    group('currentColor property', () {
      test('returns correct color for index', () {
        expect(controller.currentColor, ColorPalette.colors[0]);

        controller.nextColor();
        expect(controller.currentColor, ColorPalette.colors[1]);

        controller.selectColor(5);
        expect(controller.currentColor, ColorPalette.colors[5]);
      });
    });

    group('color cycling patterns', () {
      test('next then previous returns to start', () {
        controller.nextColor();
        controller.nextColor();
        controller.previousColor();
        controller.previousColor();
        expect(controller.colorIndex, 0);
      });

      test('select then next works correctly', () {
        controller.selectColor(5);
        controller.nextColor();
        expect(controller.colorIndex, 6);
      });

      test('select then previous works correctly', () {
        controller.selectColor(5);
        controller.previousColor();
        expect(controller.colorIndex, 4);
      });

      test('cycling through all colors returns to start', () {
        for (int i = 0; i < 12; i++) {
          controller.nextColor();
        }
        expect(controller.colorIndex, 0);
      });
    });
  });
}
