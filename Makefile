.PHONY: help install lint format test test-watch coverage build-debug build-release build-android build-ios run run-release clean analyze screenshot release

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
	@echo "Release:"
	@echo "  make release          - Increment build number (1.0.0+1 -> 1.0.0+2)"
	@echo "  make release TYPE=patch  - Increment patch (1.0.0+1 -> 1.0.1+1)"
	@echo "  make release TYPE=minor  - Increment minor (1.0.0+1 -> 1.1.0+1)"
	@echo "  make release TYPE=major  - Increment major (1.0.0+1 -> 2.0.0+1)"
	@echo ""
	@echo "Icons & Assets:"
	@echo "  make gen-icons        - Regenerate app launcher icons"
	@echo ""
	@echo "Device:"
	@echo "  make screenshot       - Take a device screenshot (timestamped)"
	@echo ""

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
	
install:
	flutter pub get

screenshot:
	@adb exec-out screencap -p > screenshot_$$(date +%Y%m%d_%H%M%S).png
	@echo "Screenshot saved: screenshot_$$(date +%Y%m%d_%H%M%S).png"

# Release command with TYPE support (release, patch, minor, major)
# Default TYPE=release increments build number only
TYPE ?= release

release:
	@./scripts/release.sh $(TYPE)
