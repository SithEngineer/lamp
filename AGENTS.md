# Agent Instructions for Lamp Repository

Flutter mobile app that transforms the phone screen into a customizable lamp.

## Commands (via Makefile)

| Command | What it does |
|---|---|
| `make install` | `flutter pub get` |
| `make lint` | `dart analyze` — **must pass before any build or commit** |
| `make format` | `dart format lib test --set-exit-if-changed` |
| `make test` | `flutter test` |
| `make coverage` | `flutter test --coverage` (local only) |
| `make run` | `flutter run` (debug) |
| `make run-release` | `flutter run --release` |
| `make build-debug` | Debug APK (runs lint first) |
| `make build-release` | Release APK (runs lint first) |
| `make build-android` | Alias for build-release |
| `make bundle-android` | Release AAB for Play Store (runs lint first) |
| `make build-ios` | Release IPA (runs lint first) |
| `make tag VERSION=x.y.z BUILD=n` | Update pubspec, commit, create+push tag |
| `make gen-icons` | Regenerate app launcher icons |
| `make clean` | `flutter clean` + remove build/ and .dart_tool/ |

**Pre-commit checklist:** `make lint && make test && make format`

## Architecture

```
lib/
  main.dart                    # Entry point → LampApp → ColorLampScreen
  screens/color_lamp_screen.dart   # Only screen (StatefulWidget)
  colors/color_controller.dart     # State: color index + brightness
  models/color_palette.dart        # 12 colors, safe access via getColor()
  theme/app_theme.dart             # Material 3 ThemeData
  theme/spacing.dart               # AppSpacing constants
```

**State management:** `ColorController` extends `ChangeNotifier`. Screen creates it in `initState`, listens via `addListener(() => setState(() {}))`, disposes in `dispose()`. No InheritedWidget, no provider package.

**ColorController has:** `colorIndex`, `currentColor`, `adjustedColor` (brightness-applied), `nextColor()`, `previousColor()`, `selectColor(index)`, `increaseBrightness()`, `decreaseBrightness()`, `resetToFirstColor()`.

**Brightness:** Vertical swipes adjust in 0.25 steps (0.0–1.0). `adjustedColor` interpolates between black and `currentColor`.

**ColorPalette:** 12 colors. Access via `ColorPalette.getColor(index)` (bounds-checked, returns first color on invalid index) or `ColorPalette.length`. Direct array access `ColorPalette.colors[index]` is used in chip bar.

## Code Conventions

- **Single quotes** for strings (`prefer_single_quotes: true`)
- **Const everywhere** — constructors, literals, declarations
- **No hard-coded colors/dimensions** — use `Theme.of(context).colorScheme`, `AppSpacing`
- **Extract private widgets** when build() exceeds ~60 lines (`_ColorDisplay`, `_ColorChip`, etc.)
- **Named parameters** for non-trivial constructors
- **Relative imports** for project files
- `avoid_print: false` is set — `print()` is allowed for debugging

## Lint Config (`analysis_options.yaml`)

Based on `package:lints/recommended.yaml` (not flutter_lints). Enabled: `prefer_single_quotes`, `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `prefer_const_constructors_in_immutables`, `prefer_const_declarations`, `prefer_final_fields`, `prefer_final_locals`. `avoid_print` disabled.

## Testing

- Tests mirror `lib/` structure under `test/`
- Controller tests use `setUp`/`tearDown` with `dispose()`
- Wrap count in tests is **12** (current palette size) — update if palette changes
- Run single test: `flutter test test/colors/color_controller_test.dart`

## CI/CD

**CI (`.github/workflows/ci.yml`):** Triggers on push/PR to `main`/`develop`. Jobs: `test-and-lint` → `build-debug` (debug APK only). Java 17 required.

**Release (`.github/workflows/release.yml`):** Triggers on `v*.*.*` tag push or `workflow_dispatch`. Jobs: `build-android` (AAB + split-per-abi APKs) → `release-github` (GitHub release with APKs) → `deploy-play-store` (Fastlane supply, production track). iOS jobs disabled (`if: false`).

**GitHub secrets:** `KEYSTORE_BASE64`, `STORE_PASSWORD`, `KEYSTORE_PASS`, `KEYSTORE_ALIAS`, `GOOGLE_PLAY_JSON_KEY`.

## Dependencies

Only `cupertino_icons` and `flutter_launcher_icons` (dev). No state management packages — uses built-in `ChangeNotifier`.

## Troubleshooting

- **Hot reload not reflecting changes** (esp. model changes): full restart with `make run`
- **Lint fails:** run `make format` first to auto-fix, then `make lint`
- **Stale build artifacts:** `make clean && make install`
