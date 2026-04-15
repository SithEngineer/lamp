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
	@echo "Checking prerequisites..."
	@# Check if on main branch
	@CURRENT_BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
	if [ "$$CURRENT_BRANCH" != "main" ]; then \
		echo "Error: Must be on main branch. Current branch: $$CURRENT_BRANCH"; \
		exit 1; \
	fi
	@# Check if working directory is dirty (excluding pubspec.yaml which we'll modify)
	@git diff --quiet -- . ':(exclude)pubspec.yaml'; \
	if [ $$? -ne 0 ]; then \
		echo "Error: Working directory has uncommitted changes (excluding pubspec.yaml)."; \
		echo "Please commit or stash changes before releasing."; \
		git status --short; \
		exit 1; \
	fi
	@# Read current version from pubspec.yaml
	@CURRENT_VERSION=$$(grep "^version: " pubspec.yaml | sed 's/version: //'); \
	echo "Current version: $$CURRENT_VERSION"; \
	\
	# Parse version components (format: major.minor.patch+build)\n	MAJOR=$$(echo $$CURRENT_VERSION | cut -d. -f1); \
	MINOR=$$(echo $$CURRENT_VERSION | cut -d. -f2); \
	PATCH_BUILD=$$(echo $$CURRENT_VERSION | cut -d. -f3); \
	PATCH=$$(echo $$PATCH_BUILD | cut -d+ -f1); \
	BUILD=$$(echo $$PATCH_BUILD | cut -d+ -f2); \
	\
	# Calculate new version based on TYPE\n	if [ "$(TYPE)" = "release" ]; then \
		NEW_BUILD=$$((BUILD + 1)); \
		NEW_VERSION="$$MAJOR.$$MINOR.$$PATCH+$$NEW_BUILD"; \
		echo "Incrementing build number: $$CURRENT_VERSION -> $$NEW_VERSION"; \
	elif [ "$(TYPE)" = "patch" ]; then \
		NEW_PATCH=$$((PATCH + 1)); \
		NEW_VERSION="$$MAJOR.$$MINOR.$$NEW_PATCH+1"; \
		echo "Incrementing patch version: $$CURRENT_VERSION -> $$NEW_VERSION"; \
	elif [ "$(TYPE)" = "minor" ]; then \
		NEW_MINOR=$$((MINOR + 1)); \
		NEW_VERSION="$$MAJOR.$$NEW_MINOR.0+1"; \
		echo "Incrementing minor version: $$CURRENT_VERSION -> $$NEW_VERSION"; \
	elif [ "$(TYPE)" = "major" ]; then \
		NEW_MAJOR=$$((MAJOR + 1)); \
		NEW_VERSION="$$NEW_MAJOR.0.0+1"; \
		echo "Incrementing major version: $$CURRENT_VERSION -> $$NEW_VERSION"; \
	else \
		echo "Error: Unknown TYPE '$(TYPE)'. Use: release, patch, minor, or major"; \
		exit 1; \
	fi; \
	\
	# Update pubspec.yaml\n	sed -i.bak "s/^version: .*/version: $$NEW_VERSION/" pubspec.yaml; \
	rm -f pubspec.yaml.bak; \
	\
	# Show confirmation prompt\n	echo ""; \
	read -p "Proceed with release v$$NEW_VERSION? (y/N): " CONFIRM; \
	if [ "$$CONFIRM" != "y" ] && [ "$$CONFIRM" != "Y" ]; then \
		echo "Aborted. Reverting pubspec.yaml..."; \
		git checkout pubspec.yaml; \
		exit 1; \
	fi; \
	\
	# Commit changes\n	git add pubspec.yaml; \
	git commit -m "Release v$$NEW_VERSION"; \
	\
	# Create annotated tag\n	git tag -a "v$$NEW_VERSION" -m "Release v$$NEW_VERSION"; \
	\
	# Push to origin\n	git push origin main; \
	git push origin "v$$NEW_VERSION"; \
	\
	echo ""; \
	echo "✓ Released v$$NEW_VERSION"; \
	echo "✓ CI/CD will deploy automatically"
