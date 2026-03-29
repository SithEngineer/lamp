# Agent Instructions for Lamp Repository

This document provides guidelines for agentic coding assistants working in the Lamp Flutter mobile application repository.

## Build/Lint/Test Commands

### Core Commands

- **Install dependencies**: `make install` (or `flutter pub get`)
- **Lint code**: `make lint` (runs `dart analyze`)
- **Format code**: `make format` (runs `dart format lib test`)
- **Run all tests**: `make test` (runs `flutter test`)
- **Run specific test**: `flutter test test/colors/color_controller_test.dart`
- **Run tests in watch mode**: `make test-watch` (or `flutter test --watch`)
- **Analyze with verbose output**: `make analyze` (or `dart analyze --verbose`)

### Build Commands

All build commands automatically run lint first (`make lint`):

- **Debug build (Android)**: `make build-debug`
- **Release build (Android)**: `make build-release` or `make build-android`
- **iOS build**: `make build-ios`
- **Run app in debug mode**: `make run` (or `flutter run`)
- **Run app in release mode**: `make run-release` (or `flutter run --release`)

### CI/CD Commands

- `make ci-setup`: Install dependencies for CI
- `make ci-lint`: Run linting in CI mode
- `make ci-test`: Run tests with coverage in CI mode

## Code Style Guidelines

### Imports

1. **Use relative imports for project files**: `import '../models/color_palette.dart'`
2. **Use const constructors**: Always prefer const constructors (`const MyWidget()`)
3. **Named parameters**: Always use named parameters for non-trivial constructors
4. **Private widgets**: Use underscore prefix for private widgets (`_ColorChip`)
5. **Styling**: Use single quotes for strings (`'string'`) per `prefer_single_quotes` lint rule

### Formatting

1. **Use const constructors everywhere**: Enable tree optimizations
2. **Productive code** must conform to: `const ColorPalette.colors[3]` not `AppTheme`
3. **Private widgets**: Extract widgets into separate classes if build method exceeds ~60 lines
4. **Limit Nesting**: Extract complex logic into private methods or widgets
5. **Use trailing commas** in lists, maps, and function parameters for better diffs
6. **Line length**: Keep lines under 100 characters where practical

### Types

1. **Use Dart type inference** for local variables when type is obvious
2. **Explicit types** for public APIs and method parameters
3. **Use const** for immutable values and collections
4. **Use final** for variables that don't change after initialization

### Naming Conventions

1. **File naming**: `snake_case` for files (`color_palette.dart`)
2. **Class naming**: `PascalCase` for classes (`ColorController`)
3. **Variable naming**: `camelCase` for variables (`colorIndex`)
4. **Constant naming**: `PASCAL_CASE` for constants (`COLOR_CHIP_SIZE`)
5. **Private members**: Use underscore prefix (`_colorIndex`) for private members

### Widget Structure

1. **Simple patterns**: Use built-in Flutter patterns, avoid complex frameworks
2. **Single responsibility**: Each widget should do one thing
3. **Extraction**: Extract complex widgets into separate files
4. **Stateless Widgets**: Use `StatelessWidget` when possible
5. **Stateful Widgets**: Use `StatefulWidget` only when state is needed

### Error Handling

1. **Bounds validation**: Always validate indices and limits
2. **Use field**: Validate method parameters
3. **Use const** to avoid runtime errors from invalid widget parameters
4. **Graceful degradation**: Provide sensible defaults for invalid inputs

### State Management

1. **Use `ChangeNotifier`** with simple inheritance pattern
2. **Lifecycle management**: Properly dispose controllers in `dispose()`
3. **No framework overhead**: Use simple Flutter patterns
4. **Separation of concerns**: Keep business logic in controllers

### Theme & Styling

1. **Centralized theming**: All colors and spacing defined in `theme/`
2. **No hard-coded values**: Use `AppTheme` and `AppSpacing` constants
3. **Material 3 design**: Use Material Design 3 guidelines exclusively
4. **No magic numbers**: Define spacing and sizing constants

### Testing

1. **Unit tests**: Test business logic separately from UI
2. **Widget tests**: Test UI components in isolation
3. **No duplication**: Extract shared test logic into helper functions
4. **Use tearDown**: Always tear down resources after tests

## Project-Specific Conventions

### File Organization

1. **Flat structure**: Avoid deep nesting of folders
2. **Semantic naming**: File and function names clearly indicate purpose
3. **One responsibility**: Each file has a single, clear purpose

### Color Index Management

1. **Collection** references are based on logical size of the `const ColorPalette.colors`
2. **Array positions** are made accessible via `ColorPalette.getColor(index)`
3. **Arrays** are protected by accessing via `ColorPalette.length` property

### Validation

1. **Type contracts** follow Dart idioms and Flutter conventions
2. **Range checking** logic enclosed within method bodies ensures programmability and testability

## Special Notes

1. **Lint must pass**: All builds run `make lint` first and fail if linting doesn't pass
2. **Tests must pass**: All commits must pass all tests
3. **Formatting enforced**: Run `make format` before committing
4. **CI/CD blocks on violations**: Lint and test failures block CI/CD pipeline

## Copilot Instructions Integration

Key points from `.github/copilot-instructions.md`:

### Project Overview

**Lamp** is a Flutter mobile application that transforms the phone screen into a customizable lamp/light. Users can:
- Swipe left/right to cycle through 12 predefined colors
- Tap color chips in the bottom bar to jump to a specific color
- See smooth animated transitions between colors

**Target Platforms:** Android (SDK 21+), iOS
**Design System:** Material 3 with centralized `ColorScheme` and `ThemeData`

### Architecture & Core Patterns

#### Simplified Structure

The project uses a simple, flat folder structure focused on direct business logic and UI separation:
```
lib/
  main.dart                    # Entry point
  screens/                     # UI screens
    color_lamp_screen.dart
  colors/                      # Color logic
    color_controller.dart
  models/                      # Domain models
    color_palette.dart
  theme/                       # Centralized styling
    app_theme.dart
    spacing.dart
  widgets/                     # Reusable components (if any)
```

#### State Management

Use **ChangeNotifier** with simple inheritance pattern, no complex frameworks:
```dart
class ColorController extends ChangeNotifier {
  int _colorIndex = 0;

  int get colorIndex => _colorIndex;

  void nextColor() {
    _colorIndex = (_colorIndex + 1) % ColorPalette.length;
    notifyListeners();
  }
}
```

Use in StatefulWidget:
```dart
class ColorLampScreen extends StatefulWidget {
  @override
  State<ColorLampScreen> createState() => _ColorLampScreenState();
}

class _ColorLampScreenState extends State<ColorLampScreen> {
  late ColorController colorController;

  @override
  void initState() {
    super.initState();
    colorController = ColorController();
    colorController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    colorController.dispose();
    super.dispose();
  }
}
```

#### Business Logic: Controllers

- **ColorController**: Manages color index state and navigation logic
- Place business logic in controller classes, not in widgets
- Controllers extend `ChangeNotifier` for simplicity
- All color navigation (next, previous, select) in controller methods

#### Widget Hierarchy & Code Readability

- **Avoid deep nesting**: Extract widgets into separate classes if build method exceeds ~60 lines
- **Prefer private widgets** for single-use components (e.g., `_ColorChip`, `_ColorBar`)
- **Use const constructors everywhere** for performance and clarity
- **Named parameters** for all non-trivial constructors

Example good pattern:
```dart
class ColorLampScreen extends StatefulWidget {
  const ColorLampScreen({super.key});

  @override
  State<ColorLampScreen> createState() => _ColorLampScreenState();
}

class _ColorLampScreenState extends State<ColorLampScreen> {
  late ColorController colorController;

  // ... manage controller lifecycle

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _ColorDisplay(color: colorController.currentColor),
          _ColorChipBar(
            currentIndex: colorController.colorIndex,
            onColorSelected: colorController.selectColor,
          ),
        ],
      ),
    );
  }
}
```

#### Theme & Design

- **Centralize all theming** in `lib/theme/app_theme.dart`:
```dart
ThemeData get appTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  // Use ColorScheme instead of hard-coded colors
);
```

- **Avoid hard-coded colors/spacing/text styles** — use `Theme.of(context).colorScheme`, `TextTheme`, predefined `AppSpacing` constants
- **Use Material 3 components** exclusively
- **Store spacing/sizing constants in `lib/theme/spacing.dart`** — no magic numbers in code

### Development Workflow

#### Quick Start

1. **Before coding**: Read the feature requirements
2. **Write tests**: Test business logic (controllers) first
3. **Implement**: Add controller logic, then UI widgets
4. **Lint & Format**: Run `make lint` and `make format` before commits
5. **Test**: Run `make test` to verify

#### Adding a New Feature

1. Create new screen file in `lib/screens/`
2. If needed, create a controller in `lib/colors/` or `lib/models/`
3. Write unit tests for controller logic
4. Write the UI using StatefulWidget + controller
5. Run `make lint test` before committing
6. All build commands automatically run `make lint` first

### Code Quality Standards

**All commits must pass:**
- ✅ **`make lint`** — `dart analyze` with zero issues
- ✅ **`make test`** — All tests passing
- ✅ **`make format`** — Code properly formatted

**Linting is enforced:**
- Manual builds require `make lint` to pass
- CI/CD pipeline blocks on lint failures
- All builds require passing lint check

### Refactoring Complex Components

1. Extract into separate private widget class if build() exceeds 60 lines
2. Use const constructors and named parameters
3. Test affected components
4. Verify no linting issues: `make lint`

## CI/CD Pipeline (GitHub Actions)

### Overview

```
Commit → Lint & Test → Build Android → Build iOS → Deploy (Manual)
```

### Stages

1. **Lint & Test** (all branches)
   - `dart analyze` — Static analysis
   - `flutter test` — Unit and widget tests
   - Blocks further stages on failure

2. **Build Android** (main branch only, after tests pass)
   - Generates release APK
   - Runs `make build-android` (which runs lint first)

3. **Build iOS** (main branch only, after tests pass)
   - Generates IPA
   - Runs `make build-ios` (which runs lint first)

4. **Deploy** (manual trigger)
   - Deploy to Google Play Store or App Store
   - Requires signing certificates and credentials

### GitHub Secrets Required

- `SIGNING_KEY_ALIAS` — Android signing key alias
- `SIGNING_KEY_PASSWORD` — Android signing key password
- `GOOGLE_PLAY_API_KEY` — Google Play Store API service account
- `FASTLANE_USER` — Apple App Store user (if using fastlane)
- `FASTLANE_PASSWORD` — Apple App Store app-specific password

## Project Standards

### Code Organization

- **One responsibility per file** — Each file has a single, clear purpose
- **Flat structure** — Avoid excessive nesting; use clear folders (screens, colors, models, theme)
- **Semantic naming** — File and function names clearly indicate purpose
- **No framework overhead** — Use simple Flutter patterns; avoid complex abstractions

### No Hard-Coded Values

- **No magic colors** — Use `AppTheme` and `ColorScheme`
- **No magic dimensions** — Use `AppSpacing` constants
- **No magic strings** — Define as string constants if reused

### Dependencies

- **Minimal dependencies** — Prefer Flutter built-ins over pub packages
- **Currently used**:
  - `cupertino_icons` — Icon set
  - `flutter_launcher_icons` — App icon generation

### Linting & Code Quality

**Setup (`analysis_options.yaml`)**
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - avoid_empty_else
    - avoid_print
    - prefer_const_constructors
    - prefer_single_quotes
```

**CI/CD Integration**
- `make lint` runs `dart analyze` (part of all builds)
- `make format` runs `dart format` (run before commits)
- All PRs must pass linting

## Testing Strategy

### Unit Tests

Test business logic (controllers) in isolation:
```dart
test('nextColor wraps around', () {
  final controller = ColorController();
  for (int i = 0; i < 12; i++) {
    controller.nextColor();
  }
  expect(controller.colorIndex, 0); // Wraps to start
});
```

### Widget Tests

Test UI components with mock controllers.

### Test Files Location

```
test/
├── colors/
│   └── color_controller_test.dart
└── screens/
    └── color_lamp_screen_test.dart
```

## Key Principles

1. **Simplicity First** — Prefer simple patterns over frameworks
2. **Material 3 Design** — Use Material 3 exclusively
3. **Testable Code** — Business logic in controllers, testable outside widgets
4. **Centralized Styling** — No magic colors/spacing — use theme and constants
5. **Lint Always** — Must pass linting; builds enforce this
6. **Flat Structure** — Keep folder hierarchy simple and navigable
7. **Const Constructors** — Performance and clarity
8. **Named Parameters** — Clear function signatures

## Common Workflows

### Adding a New Color Feature

1. Add to `lib/models/color_palette.dart`:
```dart
class ColorPalette {
  static const List<Color> colors = [
    // ... existing colors
    Colors.cyan, // New
  ];
}
```

2. Tests automatically account for new color (12-color palette logic)

### Changing a Dimension

1. Update `lib/theme/spacing.dart`
2. All widgets using that constant automatically update
3. No code chasing needed

### Running Before Commits

```bash
make lint      # Must pass
make test      # All must pass
make format    # Run to auto-fix formatting
git commit     # Now safe to commit
```

## Debugging

- Use `flutter run -v` for verbose logs
- Use `flutter run --release` to test release build locally
- Check `dart analyze` output for code issues
- Use breakpoints in VS Code debugger for stepping through code

## Troubleshooting

### Build fails on lint

Run `make format` first to auto-fix formatting, then retry.

### Tests don't pass

Run `flutter test` locally to debug, then check logic in controller.

### App doesn't update on hot reload

For certain changes (esp. model changes), do full restart: `make run`

### Lint errors

Run `dart analyze --verbose` for detailed error messages, then fix and run `make lint` again.