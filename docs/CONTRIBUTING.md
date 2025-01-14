# Contributing to Lamp

This guide describes our development workflow, code standards, and best practices.

## Development Workflow (XP/Agile Style)

### 1. Feature Planning Phase

**Always pair with other developers before writing code.**

1. Create a **decision log** in `docs/decision-logs/` using `DECISION_LOG_TEMPLATE.md`
2. Document:
   - What the feature does
   - Why it's needed
   - How users interact with it
   - Acceptance criteria
3. Get team feedback before proceeding to implementation

### 2. Break Work Into Testable Items

- Each work item should be completable in 1-2 hours
- Each item must be independently testable
- Update decision log with task checklist

### 3. Test-Driven Development (TDD)

For each work item:

1. **Write tests first**

   ```bash
   # Create test file that doesn't exist yet
   vim test/features/[feature]/view_models/[feature]_notifier_test.dart
   ```

2. **Write failing tests** that define the expected behavior

   ```dart
   test('color index increments on nextColor()', () {
     final notifier = ColorIndexNotifier();
     expect(notifier.state, 0);
     notifier.nextColor();
     expect(notifier.state, 1);
   });
   ```

3. **Implement code** to make tests pass
   - Start simple, refactor once tests pass
   - No shortcuts—only implement what tests require

4. **Run tests to verify**
   ```bash
   make test
   ```

### 4. Code Review & Merge

- Create PR with reference to decision log and tests
- Ensure all tests pass: `make lint && make test`
- Get team approval before merging to main

---

## Code Standards

### Project Structure

```
lib/
  theme/                     # Centralized theming
    app_theme.dart
    spacing.dart
    text_styles.dart
  features/
    color_selection/
      models/                # Domain models
      repositories/          # Data layer
      providers/             # Riverpod providers
      view_models/           # Business logic (StateNotifier)
      widgets/               # UI only
  providers/                 # App-level shared providers
  main.dart

test/
  features/
    color_selection/
      models/
      repositories/
      view_models/
      widgets/
```

### State Management: Riverpod (Required)

- **No `setState()`** in production code
- **No context-based state** (Provider.of, Consumer patterns from old packages)
- Use `ConsumerWidget` or `ConsumerStatefulWidget` for UI
- All state goes in Riverpod providers in `lib/providers/` or `lib/features/*/providers/`

Example:

```dart
final colorIndexProvider = StateNotifierProvider<ColorIndexNotifier, int>((ref) {
  return ColorIndexNotifier();
});

class ColorIndexNotifier extends StateNotifier<int> {
  ColorIndexNotifier() : super(0);

  void nextColor() => state = (state + 1) % 12;
}

// In widget:
class ColorScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorIndex = ref.watch(colorIndexProvider);
    return ...;
  }
}
```

### Business Logic Location

- **ViewModel/StateNotifier**: Color navigation logic, color list management
- **Repository**: Data fetching, persistence
- **Widget**: Only UI layout and event binding
- **Never** put business logic directly in build() methods

### Widget Code Readability

```dart
// Good: Extracted widget, clear structure
class ColorScreen extends ConsumerWidget {
  const ColorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorIndex = ref.watch(colorIndexProvider);
    return Scaffold(
      body: _ColorDisplay(colorIndex: colorIndex),
      bottomNavigationBar: _ColorBar(onSelectColor: ...),
    );
  }
}

// Bad: Deep nesting, mixed concerns
class ColorScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Stack(
          children: [
            // ... 50+ lines of nested widgets
          ],
        ),
      ),
    );
  }
}
```

**Rules:**

- Extract widgets if build() exceeds ~60 lines
- Use private widget classes for single-use components: `_ColorChip`, `_ColorBar`
- Always use `const` constructors
- Always use named parameters

### Theme & Design (Material 3)

- **Centralize styling** in `lib/theme/app_theme.dart`
- **No hard-coded colors** — use `Theme.of(context).colorScheme`
- **No magic numbers** — store spacing in `lib/theme/spacing.dart`:
  ```dart
  const kPaddingSmall = 8.0;
  const kPaddingMedium = 16.0;
  const kPaddingLarge = 24.0;
  ```
- **Use Material 3 components**: `FilledButton`, `NavigationBar`, `NavigationRail`, `OutlinedButton`, etc.
- **Avoid deprecated components**: No `RaisedButton`, `OutlineButton`, etc.

### Testing Requirements

1. **Unit tests** for all ViewModels and business logic
2. **Widget tests** for UI components
3. **Test coverage**: Aim for 60-70% overall project coverage (with focus on business logic)
4. **Test naming**: `test('should [expected outcome] when [condition]', ...)`

Example:

```dart
test('should return next color index when nextColor() called', () {
  final notifier = ColorIndexNotifier();
  notifier.nextColor();
  expect(notifier.state, 1);
});

testWidgets('should show border on selected color chip', (tester) async {
  await tester.pumpWidget(MaterialApp(home: _ColorChip(isSelected: true)));
  expect(find.byIcon(Icons.check), findsOneWidget);
});
```

### Linting

- Run before commit: `make lint`
- Auto-format: `make format`
- All linting failures block merge to main
- Use `// ignore: rule_name` sparingly with explanation

---

## Git Workflow

### Branch Naming

- Feature: `feature/color-animation-v2`
- Bugfix: `bugfix/swipe-gesture-not-working`
- Docs: `docs/update-contributing-guide`

### Commit Messages

```
<type>: <short summary> (#<issue-number>)

<optional body explaining why/how>

Fixes: #<issue-number>
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

Example:

```
feat: implement color index state with Riverpod (#42)

Replace setState() with StateNotifierProvider for color navigation.
Adds ColorIndexNotifier and colorIndexProvider.

Fixes: #42
```

### Pull Requests

1. Reference decision log in PR description
2. Link to any related issues
3. Ensure all tests pass
4. Get at least one approval
5. Merge to main

---

## Secrets & Configuration

### DO NOT Commit

- `.env`, `.env.local`, `.env.prod`
- API keys, signing certificates
- Private credentials

### Use GitHub Secrets For CI/CD

```yaml
# In .github/workflows/build.yml
env:
  SIGNING_KEY_PASSWORD: ${{ secrets.SIGNING_KEY_PASSWORD }}
```

### Use Secure Storage For Runtime Secrets

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();
await storage.write(key: 'api_key', value: secret);
```

---

## Running Locally

```bash
# Install dependencies
make install

# Run tests
make test

# Run linting
make lint

# Format code
make format

# Run app
make run

# Build for release
make build-android
make build-ios
```

---

## Common Issues & Troubleshooting

### Flutter/Dart Version Mismatch

```bash
flutter --version        # Check current versions
flutter upgrade          # Update to latest stable
```

### Dependency Issues

```bash
flutter pub cache repair
flutter pub get
```

### Build Cache Issues

```bash
make clean
make install
make build-android
```

---

## Questions?

- Check decision logs in `docs/decision-logs/`
- Review ARCHITECTURE.md for design patterns
- Ask in team discussions or pair programming sessions
