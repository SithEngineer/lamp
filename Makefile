.PHONY: help install lint format test test-watch coverage build-debug build-release build-android build-ios run run-release clean analyze

help:
	@echo "Lamp - Flutter Mobile App Development Commands"
	@echo ""
	@echo "Setup & Dependencies:"
	@echo "  make install          - Install Flutter dependencies (flutter pub get)"
	@echo "  make clean            - Clean build artifacts and cache"
	@echo ""
	@echo "Development & Quality:"
	@echo "  make lint             - Run dart analyze (static analysis)"
	@echo "  make format           - Auto-format lib and test directories"
	@echo "  make analyze          - Same as lint (verbose dart analyze)"
	@echo ""
	@echo "Testing:"
	@echo "  make test             - Run all Flutter tests"
	@echo "  make test-watch       - Run tests in watch mode (auto-rerun on changes)"
	@echo "  make coverage         - Run tests with coverage report (local only, not uploaded)"
	@echo ""
	@echo "Running App:"
	@echo "  make run              - Run app in debug mode (default device/emulator)"
	@echo "  make run-release      - Run app in release mode"
	@echo ""
	@echo "Building:"
	@echo "  make build-debug      - Build debug APK (Android)"
	@echo "  make build-release    - Build release APK (Android)"
	@echo "  make build-android    - Alias for build-release (Android APK)"
	@echo "  make build-ios        - Build iOS archive (IPA)"
	@echo ""
	@echo "Icons & Assets:"
	@echo "  make gen-icons        - Regenerate app launcher icons"
	@echo ""

install:
	flutter pub get

clean:
	flutter clean
	rm -rf build/
	rm -rf .dart_tool/

lint:
	dart analyze

format:
	dart format lib test --set-exit-if-changed

analyze:
	dart analyze --verbose

test:
	flutter test

test-watch:
	flutter test --watch

coverage:
	flutter test --coverage
	@echo "\nCoverage report generated at: coverage/lcov.info"
	@echo "To view coverage details, run: lcov --list coverage/lcov.info"
	@echo "Note: Coverage reports are generated locally for development only and are not uploaded to any external services."

run:
	flutter run

run-release:
	flutter run --release

build-debug: lint
	flutter build apk --debug

build-release: lint
	flutter build apk --release

bundle-android: lint
	flutter build appbundle --release

build-android: lint build-release

build-ios: lint
	flutter build ipa --release

gen-icons-config:
	dart run flutter_launcher_icons:generate
	
gen-icons:
	dart run flutter_launcher_icons

# CI/CD targets (for GitHub Actions and local CI runs)
.PHONY: ci-setup ci-lint ci-test ci-build-android ci-build-ios

ci-setup:
	flutter pub get

ci-lint:
	dart analyze

ci-test:
	flutter test --coverage

ci-build-android:
	flutter build apk --release

ci-build-ios:
	flutter build ipa --release
