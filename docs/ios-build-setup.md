# iOS Build Setup with GitHub Actions

This document explains how to set up GitHub Actions to automatically build your Flutter iOS app.

## Prerequisites

1. **Apple Developer Account** - You need a paid Apple Developer account
2. **Xcode** - Latest version (for local development and testing)
3. **iOS Bundle ID** - Register your app bundle ID in Apple Developer Portal
4. **Code Signing Certificates** - Distribution certificate for App Store
5. **Provisioning Profiles** - App Store provisioning profile

## Required GitHub Repository Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions, and add these secrets:

### Code Signing Secrets

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `IOS_DIST_SIGNING_KEY` | Base64 encoded .p12 distribution certificate | Export from Keychain Access, convert to base64 |
| `IOS_DIST_SIGNING_KEY_PASSWORD` | Password for the .p12 certificate | Password you set when exporting |

### App Store Connect API (Required for auto-provisioning)

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `APPSTORE_ISSUER_ID` | App Store Connect API Issuer ID | App Store Connect → Users and Access → Keys |
| `APPSTORE_KEY_ID` | App Store Connect API Key ID | App Store Connect → Users and Access → Keys |
| `APPSTORE_PRIVATE_KEY` | App Store Connect API Private Key | Download .p8 file, copy content |

### Optional: TestFlight Upload

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `APPLE_ID` | Your Apple ID email | Your Apple Developer account email |
| `APPLE_APP_PASSWORD` | App-specific password | Generate in Apple ID settings |

## Setup Steps

### 1. Configure Bundle ID

Update `mobile/ios/Runner/Info.plist`:
```xml
<key>CFBundleIdentifier</key>
<string>com.petgrooming.app</string>
```

### 2. Generate Code Signing Certificate

1. Open **Keychain Access** on macOS
2. Go to **Keychain Access** → **Certificate Assistant** → **Request a Certificate from a Certificate Authority**
3. Enter your email and name, select "Saved to disk"
4. Upload the `.certSigningRequest` to Apple Developer Portal
5. Download the distribution certificate and install in Keychain
6. Export as `.p12` file with a password
7. Convert to base64: `base64 -i certificate.p12 | pbcopy`
8. Add to GitHub secrets as `IOS_DIST_SIGNING_KEY`

### 3. Create Provisioning Profile

1. Go to **Apple Developer Portal** → **Certificates, Identifiers & Profiles**
2. Create App Store provisioning profile for `com.petgrooming.app`
3. Include your distribution certificate
4. Download and note the profile name for `ExportOptions.plist`

### 4. Update ExportOptions.plist

Edit `mobile/ios/ExportOptions.plist`:
```xml
<key>teamID</key>
<string>YOUR_ACTUAL_TEAM_ID</string>
<key>provisioningProfiles</key>
<dict>
    <key>com.petgrooming.app</key>
    <string>YOUR_ACTUAL_PROVISIONING_PROFILE_NAME</string>
</dict>
```

### 5. App Store Connect API Setup

1. Go to **App Store Connect** → **Users and Access** → **Keys**
2. Create a new API key with **App Manager** role
3. Note the Key ID and Issuer ID
4. Download the `.p8` private key file
5. Add all values to GitHub secrets

## Workflow Triggers

The iOS build workflow triggers on:
- **Push to main/develop** branches (only if mobile/ files changed)
- **Pull requests** to main (debug build only, no code signing)
- **Manual trigger** via GitHub Actions UI

## Build Outputs

- **Pull Requests**: Debug build for testing (no signing)
- **Main Branch**: Release IPA file uploaded as GitHub artifact
- **Optional**: Automatic TestFlight upload for main branch

## Troubleshooting

### Common Issues

1. **Code signing failed**
   - Verify certificate is valid and not expired
   - Check team ID matches in ExportOptions.plist
   - Ensure provisioning profile includes the certificate

2. **Provisioning profile not found**
   - Update profile name in ExportOptions.plist
   - Regenerate profile if bundle ID changed
   - Check profile hasn't expired

3. **Build failed on dependencies**
   - Update Flutter version in workflow if needed
   - Check CocoaPods compatibility

### Debug Steps

1. Enable workflow debug logging in GitHub Actions
2. Check build logs for specific error messages
3. Test locally with same Flutter/Xcode versions
4. Verify all secrets are properly set

## Local Testing

Test the build process locally:

```bash
cd mobile
flutter pub get
flutter test
flutter build ios --release
cd ios
pod install
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -archivePath build/Runner.xcarchive archive
```

## Security Notes

- Never commit certificates or private keys to git
- Use GitHub repository secrets for all sensitive data
- Regularly rotate App Store Connect API keys
- Monitor certificate expiration dates