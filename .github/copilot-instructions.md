# Lamp: Copilot AI Coding Instructions

## Project Overview

**Lamp** is a Flutter mobile application that transforms the phone screen into a customizable lamp/light. Users can:

- Swipe left/right to cycle through 12 predefined colors
- Tap color chips in the bottom bar to jump to a specific color
- See smooth animated transitions between colors

**Target Platforms:** Android (SDK 21+), iOS

**Design System:** Material 3 with centralized `ColorScheme` and `ThemeData`

---

## Architecture & Core Patterns

### Simplified Structure

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

### State Management

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

### Business Logic: Controllers

- **ColorController**: Manages color index state and navigation logic
- Place business logic in controller classes, not in widgets
- Controllers extend `ChangeNotifier` for simplicity
- All color navigation (next, previous, select) in controller methods

### Widget Hierarchy & Code Readability

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

### Theme & Design

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

---

## Development Workflow

### Quick Start

1. **Before coding**: Read the feature requirements
2. **Write tests**: Test business logic (controllers) first
3. **Implement**: Add controller logic, then UI widgets
4. **Lint & Format**: Run `make lint` and `make format` before commits
5. **Test**: Run `make test` to verify

### Adding a New Feature

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

---

## Commands & Makefile

**All commands must be declared in the root `Makefile`** for both local dev and CI/CD:

Run any command via: `make <command>`

**Available commands:**

```bash
make help              # Show all available commands
make install           # Install dependencies
make lint              # Lint check (dart analyze) — RUN BEFORE COMMITS
make format            # Auto-format code
make test              # Run all tests
make test-watch        # Run tests in watch mode
make run               # Run app
make run-release       # Run app in release mode
make build-debug       # Build debug APK (runs lint first)
make build-release     # Build release APK (runs lint first)
make build-android     # Alias for build-release
make build-ios         # Build iOS (runs lint first)
make gen-icons         # Regenerate app icons
make clean             # Clean build artifacts
```

**Important:** Build commands (`build-debug`, `build-release`, `build-ios`) automatically run `make lint` first. Lint must pass or builds will fail.

---

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

---

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

---

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

---

## Key Principles

1. **Simplicity First** — Prefer simple patterns over frameworks
2. **Material 3 Design** — Use Material 3 exclusively
3. **Testable Code** — Business logic in controllers, testable outside widgets
4. **Centralized Styling** — No magic colors/spacing — use theme and constants
5. **Lint Always** — Must pass linting; builds enforce this
6. **Flat Structure** — Keep folder hierarchy simple and navigable
7. **Const Constructors** — Performance and clarity
8. **Named Parameters** — Clear function signatures

---

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

---

## Debugging

- Use `flutter run -v` for verbose logs
- Use `flutter run --release` to test release build locally
- Check `dart analyze` output for code issues
- Use breakpoints in VS Code debugger for stepping through code

---

## Troubleshooting

### Build fails on lint

Run `make format` first to auto-fix formatting, then retry.

### Tests don't pass

Run `flutter test` locally to debug, then check logic in controller.

### App doesn't update on hot reload

For certain changes (esp. model changes), do full restart: `make run`

### Lint errors

Run `dart analyze --verbose` for detailed error messages, then fix and run `make lint` again.
