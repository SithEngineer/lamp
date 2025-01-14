# Lamp Architecture

## High-Level Overview

Lamp is a Flutter mobile application that transforms a phone screen into a customizable lamp. The architecture follows clean architecture principles with clear separation of concerns:

- **Presentation Layer**: Flutter widgets (Material 3)
- **Business Logic Layer**: Riverpod state management + ViewModels
- **Data Layer**: Repositories and data sources

## Feature-Based Structure

The codebase is organized by feature, each feature containing its own models, repositories, providers, viewmodels, and widgets:

```
lib/
  theme/                    # Centralized Material 3 styling
  features/
    color_selection/        # Main feature
      models/              # Domain objects (Color, Palette, etc.)
      repositories/        # Data access layer
      providers/           # Riverpod provider definitions
      view_models/         # StateNotifier classes (business logic)
      widgets/             # UI components
  providers/               # Shared/app-level providers
  main.dart               # Entry point
```

## State Management: Riverpod

Riverpod is the single source of truth for all state management. No `setState()` in widgets.

### Provider Architecture

```dart
// Model: Domain object
class Palette {
  final List<Color> colors;
  final String name;
}

// ViewModel: Business logic
class ColorIndexNotifier extends StateNotifier<int> {
  ColorIndexNotifier() : super(0);

  void nextColor(int maxColors) => state = (state + 1) % maxColors;
  void previousColor(int maxColors) => state = (state - 1 + maxColors) % maxColors;
  void setColor(int index) => state = index;
}

// Provider: Expose ViewModel
final colorIndexProvider = StateNotifierProvider<ColorIndexNotifier, int>((ref) {
  return ColorIndexNotifier();
});

// Computed Provider: Derive current color from palette and index
final currentColorProvider = Provider<Color>((ref) {
  final index = ref.watch(colorIndexProvider);
  final palette = ref.watch(paletteProvider);
  return palette.colors[index];
});
```

### Consumer Widgets

All UI widgets that depend on state use `ConsumerWidget`:

```dart
class ColorScreen extends ConsumerWidget {
  const ColorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch state changes
    final colorIndex = ref.watch(colorIndexProvider);
    final currentColor = ref.watch(currentColorProvider);

    // Access notifier for mutations
    final colorNotifier = ref.read(colorIndexProvider.notifier);

    return Scaffold(
      body: _ColorDisplay(color: currentColor),
      bottomNavigationBar: _ColorBar(
        onNextColor: () => colorNotifier.nextColor(12),
      ),
    );
  }
}
```

## Widget Layer

### Design Principles

1. **Single Responsibility**: Each widget does one thing
2. **Readability**: Extract complex widgets into separate files
3. **Reusability**: Create generic, parameterized components
4. **Const Constructors**: Enable tree optimizations

### Widget Hierarchy Example

```
ColorScreen (ConsumerWidget)
├── Scaffold
│   ├── AppBar
│   ├── _ColorDisplay (stateless, receives color prop)
│   │   └── AnimatedContainer (with color transition)
│   └── _ColorBar (stateless, receives callback props)
│       └── ListView
│           └── _ColorChip (reusable, const constructor)
```

### Private Widgets

Single-use UI components are private to their parent:

```dart
class _ColorChip extends StatelessWidget {
  const _ColorChip({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // ...
      ),
    );
  }
}
```

## Theme & Design System

### Centralized Theming

`lib/theme/app_theme.dart` defines the complete Material 3 design system:

```dart
ThemeData get appTheme {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Color(0xFF0066CC),
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: _buildTextTheme(colorScheme),
    scaffoldBackgroundColor: colorScheme.background,
  );
}

TextTheme _buildTextTheme(ColorScheme colorScheme) {
  return TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: colorScheme.onBackground,
    ),
    // ...
  );
}
```

### Spacing & Layout Constants

`lib/theme/spacing.dart`:

```dart
// Standard spacing scale (8dp base)
const kSpacingXs = 4.0;
const kSpacingSmall = 8.0;
const kSpacingMedium = 16.0;
const kSpacingLarge = 24.0;
const kSpacingXl = 32.0;

// Component sizes
const kColorChipSize = 60.0;
const kColorBarHeight = 60.0;
const kAppBarHeight = 56.0;

// Animation durations
const kAnimationDurationFast = Duration(milliseconds: 200);
const kAnimationDurationStandard = Duration(milliseconds: 300);
const kAnimationDurationSlow = Duration(milliseconds: 500);
```

### Usage in Widgets

```dart
// DON'T: Hard-coded values
Padding(
  padding: const EdgeInsets.all(16),
  child: Text('Hello', style: TextStyle(fontSize: 20)),
)

// DO: Use centralized theme
Padding(
  padding: const EdgeInsets.all(kSpacingMedium),
  child: Text(
    'Hello',
    style: Theme.of(context).textTheme.bodyLarge,
  ),
)
```

## Data Layer (Repositories)

Repositories abstract data sources and are consumed by ViewModels:

```dart
abstract class ColorPaletteRepository {
  Future<Palette> getPalette(String paletteId);
  Future<void> savePalette(Palette palette);
}

class ColorPaletteRepositoryImpl extends ColorPaletteRepository {
  final LocalDataSource local;

  @override
  Future<Palette> getPalette(String paletteId) async {
    // Try local cache first
    final cached = local.getPalette(paletteId);
    if (cached != null) return cached;

    // Fallback to default
    return _defaultPalette();
  }
}
```

Then expose via Riverpod:

```dart
final colorPaletteRepositoryProvider = Provider<ColorPaletteRepository>((ref) {
  return ColorPaletteRepositoryImpl(local: LocalDataSource());
});
```

## Testing Architecture

### Test Pyramid

1. **Unit Tests** (70%): ViewModels, repositories, use-cases
2. **Widget Tests** (20%): UI components in isolation
3. **Integration Tests** (10%): End-to-end flows

### Test File Structure

```
test/
  features/
    color_selection/
      view_models/
        color_index_notifier_test.dart
      repositories/
        color_palette_repository_test.dart
      widgets/
        color_screen_test.dart
        color_chip_test.dart
```

### Example Unit Test

```dart
void main() {
  group('ColorIndexNotifier', () {
    test('nextColor increments index and wraps around', () {
      final notifier = ColorIndexNotifier();
      expect(notifier.state, 0);

      notifier.nextColor(3);
      expect(notifier.state, 1);

      notifier.nextColor(3);
      notifier.nextColor(3);
      notifier.nextColor(3); // Should wrap to 0
      expect(notifier.state, 0);
    });

    test('previousColor decrements and wraps around', () {
      final notifier = ColorIndexNotifier();
      notifier.previousColor(3);
      expect(notifier.state, 2); // Wrapped from 0 to 2
    });
  });
}
```

### Example Widget Test

```dart
testWidgets('ColorBar shows all color chips', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        bottomNavigationBar: _ColorBar(
          colors: [Colors.red, Colors.blue, Colors.green],
          onColorSelected: (_) {},
        ),
      ),
    ),
  );

  expect(find.byType(_ColorChip), findsWidgets);
  expect(find.byIcon(Icons.check), findsOneWidget); // Selected indicator
});
```

## Dependencies & External Libraries

### Core Dependencies

- **`flutter`**: UI framework
- **`flutter_riverpod`**: State management
- **`flutter_lints`**: Linting and best practices

### Optional/Future Dependencies

- **`flutter_secure_storage`**: For sensitive data at runtime
- **`go_router`**: For navigation (if multi-screen)
- **`mockito`** / **`mocktail`**: For test mocking

### Evaluation Process

Before adding a pub.dev package:

1. Check if Flutter/Dart built-ins solve the problem
2. Evaluate popularity, maintenance, and community support
3. Consider bundle size impact
4. Prefer packages maintained by official Flutter team

## Deployment & CI/CD

### GitHub Actions Pipeline

- **Test Stage**: `dart analyze` + `flutter test`
- **Build Stage**: Android APK, iOS IPA
- **Release Stage**: Google Play Store, Apple App Store (manual approval)

See `.github/workflows/` for implementation details and `docs/CI_CD.md` for full documentation.

### Local Build Commands

All build commands go through `Makefile`:

```bash
make install          # Install deps
make lint             # Static analysis
make test             # Unit + widget tests
make build-android    # Release APK
make build-ios        # Release IPA
```

## Evolution & Future Refactoring

### Current Limitations

- Single-screen monolith
- Hard-coded color palette
- No persistence layer

### Planned Improvements

1. **Multi-screen navigation** (go_router)
2. **Persistent palettes** (local storage, SQLite)
3. **Custom color creation** (color picker widget)
4. **Sync to cloud** (Firebase or custom backend)

Architectural decisions will be logged in `docs/decision-logs/` before implementation.
