# CI/CD Pipeline Documentation

## Overview

Lamp uses GitHub Actions for continuous integration and deployment, with support for fastlane/Codemagic for advanced signing and app store distribution.

### Pipeline Stages

```
Commit → Test & Lint → Build Android → Build iOS → Deploy (Manual)
                ↓
           PR/Feature Branch
```

## Stage Details

### 1. Test & Lint (Runs on all branches)

- **Trigger**: Push to any branch or pull request
- **Jobs**:
  - `flutter pub get`: Install dependencies
  - `dart analyze`: Static analysis and linting
  - `flutter test`: Unit and widget tests
- **Artifacts**: None (failures block further stages)
- **Success Criteria**: All tests pass, no lint errors
- **Code Coverage**: Tests generate local coverage reports; no external coverage uploads to third-party services

### 2. Build Android (Runs on main/develop after tests pass)

- **Trigger**: Push to main or develop (only if test stage succeeds)
- **Runner**: Ubuntu (Linux)
- **Jobs**:
  - Setup Java 11 and Flutter
  - Run `make build-android` (Release APK)
- **Artifacts**: `app-release.apk` (30-day retention)
- **Success Criteria**: APK builds without errors

### 3. Build iOS (Runs on main/develop after tests pass)

- **Trigger**: Push to main or develop (only if test stage succeeds)
- **Runner**: macOS
- **Jobs**:
  - Setup Flutter
  - Run `make build-ios` (Release IPA)
  - Requires provisioning profiles and signing certs (not yet configured)
- **Artifacts**: `lamp.ipa` (30-day retention)
- **Success Criteria**: IPA builds without errors

### 4. Deploy to Google Play Store (Manual trigger)

- **Trigger**: Manual workflow dispatch from GitHub UI
- **Requires**: Android build artifact
- **Status**: Placeholder—awaiting fastlane/Codemagic configuration
- **Secrets Needed**:
  - `GOOGLE_PLAY_API_KEY`: Service account JSON for Play Store API
  - `SIGNING_KEY_ALIAS`: Android signing key alias
  - `SIGNING_KEY_PASSWORD`: Android signing key password

### 5. Deploy to Apple App Store (Manual trigger)

- **Trigger**: Manual workflow dispatch from GitHub UI
- **Requires**: iOS build artifact
- **Status**: Placeholder—awaiting fastlane/Codemagic configuration
- **Secrets Needed**:
  - `FASTLANE_USER`: Apple ID email
  - `FASTLANE_PASSWORD`: App-specific password
  - `PROVISIONING_PROFILE`: Provisioning profile file
  - `DEVELOPER_CERT_ISSUER`: Developer certificate

---

## Running Locally

All CI steps are runnable locally via Makefile:

```bash
# Test & Lint stage
make install       # Install dependencies (same as CI)
make lint          # Dart analyze
make test          # Flutter test

# Build stages
make build-android # Build APK (same as CI)
make build-ios     # Build IPA (same as CI)
```

This ensures your local development matches the CI environment.

---

## GitHub Secrets Configuration

### Setup Instructions

1. Go to: **Settings → Secrets and variables → Actions**
2. Add the following secrets:

#### Android Signing (Required for Play Store)

```
SIGNING_KEY_ALIAS=my_key_alias
SIGNING_KEY_PASSWORD=my_very_secure_password
```

#### Google Play Store (Required for deployment)

```
GOOGLE_PLAY_API_KEY=[contents of service account JSON]
```

#### iOS Signing (Required for App Store)

```
FASTLANE_USER=your.apple.id@example.com
FASTLANE_PASSWORD=abcd-efgh-ijkl-mnop  # App-specific password from Apple ID
PROVISIONING_PROFILE=[base64-encoded provisioning profile]
DEVELOPER_CERT_ISSUER=Apple Distribution: Your Company
```

#### Optional: Slack Notifications

```
SLACK_WEBHOOK=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

---

## Signing & Certificate Management

### Android Signing

#### Generate Signing Key (one-time)

```bash
cd android/app
keytool -genkey -v -keystore lamp-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias lamp-key

# Store jks file securely (NOT in repo!)
```

#### Configure Gradle (android/app/build.gradle)

```gradle
signingConfigs {
  release {
    storeFile file("lamp-release-key.jks")
    storePassword System.getenv("SIGNING_KEY_PASSWORD")
    keyAlias System.getenv("SIGNING_KEY_ALIAS")
    keyPassword System.getenv("SIGNING_KEY_PASSWORD")
  }
}

buildTypes {
  release {
    signingConfig signingConfigs.release
  }
}
```

### iOS Signing

#### Generate Provisioning Profile

1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Create/download provisioning profile for App ID
3. Encode as base64:
   ```bash
   base64 -i lamp.mobileprovision -o lamp.mobileprovision.b64
   ```
4. Add to GitHub Secrets as `PROVISIONING_PROFILE`

#### Configure Xcode (ios/Runner.pbxproj)

- Set provisioning profile in build settings
- Ensure `DEVELOPMENT_TEAM` is set

---

## Fastlane Setup (Optional but Recommended)

Fastlane simplifies signing, building, and distributing to app stores.

### Install Fastlane

```bash
# macOS only (for iOS)
brew install fastlane

# All platforms:
sudo gem install fastlane -NV

# Initialize in Android/iOS directories:
cd android
fastlane init
cd ../ios
fastlane init
```

### Fastlane Configuration

#### `android/fastlane/Fastfile`

```ruby
default_platform(:android)

platform :android do
  desc "Build and upload to Play Store (internal testing)"
  lane :internal do
    build_android_app(
      task: "bundle",
      project_dir: "android/",
    )

    upload_to_play_store(
      track: "internal",
      json_key: ENV["GOOGLE_PLAY_API_KEY"],
    )
  end
end
```

#### `ios/fastlane/Fastfile`

```ruby
default_platform(:ios)

platform :ios do
  desc "Build and upload to TestFlight"
  lane :beta do
    build_app(
      workspace: "Runner.xcworkspace",
      configuration: "Release",
      scheme: "Runner",
      export_method: "app-store",
    )

    upload_to_testflight(
      api_key_path: ENV["IOS_API_KEY_PATH"],
    )
  end
end
```

### Integrate with GitHub Actions

Update `.github/workflows/ci.yml`:

```yaml
deploy-play-store:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: ruby/setup-ruby@v1
    - run: fastlane android internal
```

---

## Codemagic Alternative

[Codemagic](https://codemagic.io/) is a managed CI/CD service built for Flutter/iOS.

### Advantages

- Native iOS building (no local cert management needed)
- Automated signing via Apple account
- One-click app store distribution
- Free tier available

### Configuration

Create `codemagic.yaml`:

```yaml
workflows:
  release:
    name: Release Build
    triggering:
      events:
        - push
      branch:
        includes:
          - main
    scripts:
      - name: Build Android
        script: make build-android
      - name: Build iOS
        script: make build-ios
    publishing:
      google_play:
        credentials: $PLAY_STORE_API_KEY
      app_store_connect:
        api_key: $IOS_API_KEY
```

---

## Testing the Pipeline Locally

### Run Test Stage

```bash
make install
make lint
make test
```

### Simulate GitHub Actions Locally

Use [act](https://github.com/nektos/act) to run GitHub Actions locally:

```bash
# Install
brew install act

# Run workflows
act push -j test-and-lint
act push -j build-android
```

---

## Deployment Checklist

### Before First Release

- [ ] Generate Android signing key
- [ ] Configure Google Play Store developer account
- [ ] Create Apple Developer account and team
- [ ] Upload all GitHub Secrets
- [ ] Test `make build-android` and `make build-ios` locally
- [ ] Run full CI pipeline in GitHub Actions
- [ ] Verify artifacts are generated

### Before Each Release

- [ ] Bump version in `pubspec.yaml`
- [ ] Run `make test` locally
- [ ] Ensure all GitHub Secrets are valid
- [ ] Review build logs in GitHub Actions
- [ ] Test app on real device before deploying

### Release Process

1. Merge PR to main
2. Wait for GitHub Actions to complete all stages
3. Manually trigger `deploy-play-store` or `deploy-app-store`
4. Monitor app store for approval/publication
5. Announce release

---

## Troubleshooting

### APK Build Fails

```bash
# Check for Gradle errors:
make clean
make build-android

# If cache issues:
rm -rf ~/.gradle/caches
make build-android
```

### IPA Build Fails

```bash
# Check Xcode settings:
cd ios
pod install
cd ..
make build-ios
```

### Secrets Not Available in GitHub Actions

- Verify secret names match env var names in workflow
- Check that workflow file uses `${{ secrets.VARIABLE_NAME }}`
- Ensure secret is not empty

### "Cannot decode provisioning profile" Error

```bash
# Regenerate base64 encoding:
base64 -i lamp.mobileprovision | pbcopy
# Paste into GitHub Secrets
```

---

## Future Improvements

1. **Code signing automation**: Use [match](https://docs.fastlane.tools/actions/match/) for certificate management
2. **Automated versioning**: Use git tags to auto-increment build numbers
3. **Screenshot capture**: Automated testing on real devices (Firebase Test Lab)
4. **Auto-release**: Graduated promotion (internal → closed beta → production)

See decision logs for architectural changes.
