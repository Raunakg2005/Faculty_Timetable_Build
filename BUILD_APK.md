# Building the APK

After deploying the backend to your VPS, you can build the production APK.

## Build Release APK

```bash
# Navigate to the Flutter client directory
cd "d:\flutter projects\sukala\Faculty_Timetable\client"

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release
```

The APK will be created at:
```
build/app/outputs/flutter-apk/app-release.apk
```

## Build App Bundle (for Play Store)

If you want to publish to Google Play Store:

```bash
flutter build appbundle --release
```

The AAB file will be at:
```
build/app/outputs/bundle/release/app-release.aab
```

## Testing the APK

1. **Transfer to Android device:**
   - Connect phone via USB
   - Enable USB debugging in Developer Options
   - Run: `adb install build/app/outputs/flutter-apk/app-release.apk`
   
   OR
   
   - Copy `app-release.apk` to your phone
   - Open the file and install

2. **Test functionality:**
   - Open the app
   - Try registering/logging in
   - Verify it connects to `https://faculty-api.quantyxio.cloud/api`

## Sharing the APK

### Option 1: Direct Share
- Upload `app-release.apk` to Google Drive, Dropbox, etc.
- Share the link
- Recipients install by opening the APK file

### Option 2: GitHub Release
```bash
# Create a release on GitHub
# Upload app-release.apk as an asset
```

### Option 3: VPS Download
```bash
# Upload to your VPS
scp app-release.apk user@quantyxio.cloud:/var/www/html/downloads/

# Share link: https://quantyxio.cloud/downloads/app-release.apk
```

## Important Notes

⚠️ **Backend Must Be Running:**
- The APK will ONLY work if the backend is deployed and running on your VPS
- Make sure Docker containers are running: `docker ps`
- Test API: `curl https://faculty-api.quantyxio.cloud/`

⚠️ **SSL Certificate:**
- Your VPS needs a valid SSL certificate for HTTPS
- Use certbot to get a free Let's Encrypt certificate (see DEPLOYMENT.md)

⚠️ **Android Security:**
- Users need to enable "Install from Unknown Sources" to install the APK
- For wider distribution, consider publishing to Google Play Store

## Switching Back to Development

To switch back to localhost for development:

```dart
// In client/lib/services/api_service.dart
static const String baseUrl = 'http://localhost:5000/api'; // For development
// static const String baseUrl = 'https://faculty-api.quantyxio.cloud/api'; // For production
```

Or use environment variables for better flexibility.
