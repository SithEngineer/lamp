[![CI/CD Pipeline](https://github.com/SithEngineer/lamp/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/SithEngineer/lamp/actions/workflows/ci.yml)

# Lamp

A Flutter mobile application that transforms your phone screen into a customizable lamp/light. Perfect as a bedside lamp or ambient light source.

## Features

- 🎨 **12 Predefined Colors** - Red, Purple, Teal, Green, Blue, Orange, Amber, Yellow, White, Grey, Indigo, Black
- 👆 **Tap to Select** - Tap color chips at the bottom to jump directly to a color
- 👈👉 **Swipe to Navigate** - Swipe left/right to cycle through colors with smooth animations
- 👆👇 **Vertical Swipe for Brightness** - Swipe up/down to adjust brightness in 0.25 increments
- ✨ **Smooth Transitions** - 300ms animated color transitions for a polished feel
- 📱 **Mobile First** - Optimized for Android and iOS platforms

## Supported Platforms

- **Android** (SDK 21+)
- **iOS** (iOS 11+)

## Architecture

### Project Structure

```
lib/
├── main.dart                          # App entry point
├── screens/
│   └── color_lamp_screen.dart        # Main UI screen
├── models/
│   └── color_palette.dart            # Color definitions
├── theme/
│   ├── app_theme.dart                # Material 3 theming
│   └── spacing.dart                  # Spacing constants
└── colors/
    └── color_controller.dart         # Color navigation logic
```

### Technology Stack

- **State Management**: Simple ValueNotifier + InheritedWidget pattern
- **UI Framework**: Flutter with Material 3
- **Build System**: Gradle (Android) with Kotlin DSL
- **Development Language**: Dart 3.5.3+

### Design Principles

- **Centralized Styling**: All colors and spacing defined in `theme/`
- **Flat Structure**: Keep folder hierarchy simple and navigable
- **No Over-Engineering**: Use built-in Flutter patterns where possible
- **Testability**: Logic separated from UI for easy testing

## Development

### Prerequisites

- Flutter SDK 3.5.3 or higher
- Dart 3.5.3 or higher
- Android SDK 21+ (for Android development)
- Xcode 12+ (for iOS development)

### Setup

```bash
# Install dependencies
make install

# Run linting
make lint

# Run tests
make test

# Run the app
make run
```

### Available Commands

```bash
make help              # Show all available commands
make install           # Install dependencies
make lint              # Run dart analyze
make format            # Format code
make test              # Run tests
make test-watch        # Run tests in watch mode
make run               # Run app in debug mode
make run-release       # Run app in release mode
make build-debug       # Build debug APK
make build-release     # Build release APK
make build-android     # Build release APK (alias)
make build-ios         # Build iOS archive
make tag VERSION=x.y.z BUILD=n  # Create and push release tag
make gen-icons         # Regenerate app icons
make clean             # Clean build artifacts
```

## Code Quality

All pull requests must pass:

- ✅ **Linting**: `dart analyze` (run with `make lint`)
- ✅ **Formatting**: `dart format lib test` (run with `make format`)
- ✅ **Tests**: `flutter test` (run with `make test`)

The linting step runs automatically before builds through the Makefile.

## CI/CD Pipeline

### Overview

```
Branch Commit:  Push → Test & Lint → Build (Debug)
Tag Push:       Push tag → Build (Release) → GitHub Release → Play Store Deploy
```

### CI Workflow (`.github/workflows/ci.yml`)

Runs on every push to `main` or `develop`, and on pull requests.

**Jobs:**
1. `test-and-lint` - Installs deps, runs `make lint`, runs `make test`
2. `build-debug` - Builds debug APK (verification only)

**Success Criteria:** All tests pass, no lint errors, debug APK builds successfully

### Release Workflow (`.github/workflows/release.yml`)

Runs when a tag matching `v*.*.*` is pushed. Also supports manual retry via `workflow_dispatch`.

**Jobs:**
1. `build-android` - Builds release AAB + APKs, uploads artifacts
2. `release-github` - Creates GitHub release with APK artifacts (`allowUpdates: true` for retries)
3. `deploy-play-store` - Uploads AAB to Google Play Store (production track)
4. `build-ios` - Disabled until iOS signing is configured
5. `deploy-app-store` - Disabled until iOS signing is configured

**Success Criteria:** AAB builds, APKs attach to GitHub release, Play Store deployment succeeds

### Creating a Release

```bash
# Update pubspec.yaml, commit, create tag, and push
make tag VERSION=1.0.0 BUILD=5
```

This will:
1. Update `pubspec.yaml` to `version: 1.0.0+5`
2. Commit the change
3. Create tag `v1.0.0+5`
4. Push to origin (triggers Release workflow)

### Retrying a Failed Release

If a tag build fails:

1. **Via GitHub Actions UI:**
   - Go to Actions → Release workflow
   - Click on the failed run
   - Click "Re-run all jobs"

2. **Via workflow_dispatch (if artifacts were uploaded):**
   - Go to Actions → Release workflow
   - Click "Run workflow"
   - Enter the tag name (e.g., `v1.0.0+4`)
   - Click "Run workflow"

The GitHub release will be updated with new artifacts (`allowUpdates: true`).

### GitHub Secrets Required

| Secret | Purpose |
|--------|---------|
| `KEYSTORE_BASE64` | Base64-encoded Android upload keystore |
| `STORE_PASSWORD` | Keystore store password |
| `KEYSTORE_PASS` | Key password |
| `KEYSTORE_ALIAS` | Key alias |
| `GOOGLE_PLAY_JSON_KEY` | Google Play Store API service account JSON |

## Project Standards

### Code Organization

- **One responsibility per file** - Each file has a single, clear purpose
- **Flat structure** - Avoid deep nesting of folders
- **Semantic naming** - File and function names clearly indicate purpose

### Styling & Theming

- **No hard-coded colors** - Use `AppTheme` for all colors
- **No hard-coded dimensions** - Use `AppSpacing` for all spacing/sizing
- **Material 3 exclusively** - Follow Material Design 3 guidelines

### Testing

- **Unit tests** for business logic (e.g., color navigation)
- **Widget tests** for UI components
- All tests must pass before committing

### Git Workflow

1. Create feature branch from `main`
2. Make changes and commit with clear messages
3. Run `make lint test` before pushing
4. Create pull request for review
5. Merge to `main` after approval

## Troubleshooting

### Build Issues

```bash
# Clean everything and reinstall
make clean
make install
make lint
```

### Changes Not Appearing

```bash
# Hot reload might not work for certain changes
# Try a full restart:
make run
# Or run in release mode:
make run-release
```

### Lint Errors

```bash
# Auto-format code
make format

# See detailed lint issues
dart analyze --verbose
```

## Contributing

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for contribution guidelines.

## License

This project is private and not licensed for public use.

## Support

For development questions, refer to the [copilot-instructions](./github/copilot-instructions.md) in this repository.
