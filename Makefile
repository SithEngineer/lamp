.PHONY: help install lint format test test-watch coverage build-debug build-release build-android build-ios run run-release clean analyze screenshot

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

# Get the latest tag (fallback to v0.0.0 if no tags exist)
CURRENT_VERSION := $(shell git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

# Strip 'v' prefix for calculation
CURRENT_VERSION_NUM := $(subst v,,$(CURRENT_VERSION))

# Auto-calculate patch increment
MAJOR := $(shell echo $(CURRENT_VERSION_NUM) | cut -d. -f1)
MINOR := $(shell echo $(CURRENT_VERSION_NUM) | cut -d. -f2)
PATCH := $(shell echo $(CURRENT_VERSION_NUM) | cut -d. -f3)
NEXT_PATCH := $(shell echo $$(($(PATCH) + 1)))
SUGGESTED_VERSION := v$(MAJOR).$(MINOR).$(NEXT_PATCH)

release:
ifndef VERSION
	@echo "Current version: $(CURRENT_VERSION)"
	@echo "Suggested version: $(SUGGESTED_VERSION)"
	@read -p "Enter new version (or press Enter for $(SUGGESTED_VERSION)): " input && \
	if [ -z "$$input" ]; then \
		$(MAKE) do-release VERSION=$(SUGGESTED_VERSION); \
	else \
		$(MAKE) do-release VERSION=$$input; \
	fi
else
	@$(MAKE) do-release VERSION=$(VERSION)
endif

do-release:
	@echo "Validating version $(VERSION)..."
	$(eval NEW_VERSION := $(shell echo $(VERSION) | sed 's/^v//'))
	$(eval NEW_TAG := v$(NEW_VERSION))
	@if [ "$(CURRENT_VERSION)" = "$(NEW_TAG)" ]; then \
		echo "Error: Version $(NEW_TAG) already exists!"; \
		exit 1; \
	fi
	@if [ "$(NEW_TAG)" \< "$(CURRENT_VERSION)" ]; then \
		echo "Error: $(NEW_TAG) is older than current $(CURRENT_VERSION)!"; \
		exit 1; \
	fi
	@echo "Creating tag $(NEW_TAG)..."
	git tag $(NEW_TAG)
	git push origin $(NEW_TAG)
	@echo "Released $(NEW_TAG)! CI/CD will deploy automatically."
