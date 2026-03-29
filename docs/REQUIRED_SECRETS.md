# Required GitHub Repository Secrets

For the CI/CD pipeline to function properly with Android signing and Google Play Store deployment, the following repository secrets must be configured:

## Android Signing Secrets
- `KEYSTORE_BASE64`: Base64-encoded contents of your upload keystore file (upload-keystore.jks)
- `STORE_PASSWORD`: Password for the keystore
- `KEY_PASSWORD`: Password for the key alias
- `KEY_ALIAS`: Alias for the key (e.g., "upload")

## Google Play Store Deployment Secrets
- `GOOGLE_PLAY_API_KEY`: JSON service account key for Google Play Developer API access

## Optional: Apple App Store Deployment Secrets (for future iOS deployment)
- `FASTLANE_USER`: Apple ID used for App Store Connect
- `FASTLANE_PASSWORD`: App-specific password for Apple ID (when 2FA is enabled)

## How to Create the Keystore Base64 Secret

1. Ensure you have your upload-keystore.jks file
2. Run the following command to generate the base64 encoding:
   ```bash
   base64 -i upload-keystore.jks
   ```
3. Copy the entire output and add it as the value for the `KEYSTORE_BASE64` secret