# SkillSwap TWA Setup - Step-by-Step Guide

## Phase 1: Generate Signing Certificate & Get SHA256 Fingerprint

### Step 1: Generate Keystore File
```powershell
# Run this in your project root directory
keytool -genkey -v -keystore upload-key.jks -keyalg RSA -keysize 2048 -validity 10957 -alias upload

# When prompted, enter:
# Keystore password: (create a strong password)
# Key password: (can be same as keystore password)
# First and last name: Your Name / Company Name
# Organizational unit: Engineering
# Organization: SkillSwap
# City: Your City
# State/Province: Your State
# Country code: US (or your country)
```

### Step 2: Get SHA256 Certificate Fingerprint
```powershell
keytool -list -v -keystore upload-key.jks -alias upload

# Copy the SHA256 fingerprint from output (it looks like):
# SHA256: AA:BB:CC:DD:EE:FF:... (usually 64 characters, remove colons)
# Format for assetlinks.json: AABBCCDDEEFF...
```

### Step 3: Update assetlinks.json
Replace `REPLACE_WITH_YOUR_SHA256_FINGERPRINT` in:
```
android-app/assetlinks.json
```

With your actual SHA256 fingerprint (remove colons from keytool output).

---

## Phase 2: Deploy Digital Asset Links File

### Step 1: Copy assetlinks.json to Backend

Copy [android-app/assetlinks.json](android-app/assetlinks.json) to your backend's static resources:

```
backend/SSA/src/main/resources/static/.well-known/assetlinks.json
```

### Step 2: Ensure Backend Serves .well-known Directory

The file must be served over HTTPS at:
```
https://skillswapplat-1.onrender.com/.well-known/assetlinks.json
```

Verify it's accessible:
```powershell
Invoke-WebRequest -Uri "https://skillswapplat-1.onrender.com/.well-known/assetlinks.json"
```

Should return valid JSON.

---

## Phase 3: Build Android Project

### Step 1: Install Android Studio
- Download from: https://developer.android.com/studio
- Install and launch Android Studio

### Step 2: Open Android Project
- File → Open → Select `android-app` folder

### Step 3: Install SDK Components
- SDK Manager → SDK Platforms → Android 14 (API 34)
- SDK Tools → Android SDK Build-Tools 34.0.0

### Step 4: Create Release APK
```powershell
# From android-app directory
# Ensure upload-key.jks is in android-app/ directory

./gradlew.bat assembleRelease
# Or on first run:
gradlew assembleRelease
```

This creates:
```
android-app/app/build/outputs/apk/release/app-release.apk
```

### Step 5: Sign Release APK (if not auto-signed)
```powershell
jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 `
  -keystore upload-key.jks `
  app/build/outputs/apk/release/app-release.apk `
  upload
```

---

## Phase 4: Test TWA Locally

### Step 1: Connect Android Device/Emulator
- USB debugging enabled on device, OR
- Use Android Studio emulator

### Step 2: Install APK
```powershell
adb install app/build/outputs/apk/release/app-release.apk
```

### Step 3: Test App
- App should launch and display skillswapplat-1.onrender.com
- Verify offline functionality with service worker
- Test camera/location permissions if needed

---

## Phase 5: Create Google Play App Bundle (AAB)

### Step 1: Generate AAB
```powershell
./gradlew bundleRelease
```

Creates:
```
android-app/app/build/outputs/bundle/release/app-release.aab
```

### Step 2: Sign AAB (if needed)
```powershell
jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 `
  -keystore upload-key.jks `
  app/build/outputs/bundle/release/app-release.aab `
  upload
```

---

## Phase 6: Upload to Google Play Console

### Step 1: Create Google Play Developer Account
- Go to: https://play.google.com/console
- Pay $25 registration fee
- Complete merchant account setup

### Step 2: Create New App
- Play Console → Create app
- Name: SkillSwap
- Category: Education
- Content rating: Fill out questionnaire

### Step 3: Upload AAB
- Release → Production
- Upload app-release.aab

### Step 4: Fill App Details
- Screenshots (minimum 2)
- Short description (max 80 chars)
- Full description
- Privacy policy URL
- Contact information

### Step 5: Set Up Pricing
- Free app (if desired)
- Regional availability

### Step 6: Submit for Review
- Review all details
- Submit for review
- Google reviews in 24-48 hours

---

## Phase 7: Backend CORS Configuration

### Update SkillSwapApp Java Config

Ensure your backend CORS allows the TWA app package:

```java
// In SkillSwapApp.java
@Bean
public WebMvcConfigurer corsConfigurer() {
    return new WebMvcConfigurer() {
        @Override
        public void addCorsMappings(CorsRegistry registry) {
            registry.addMapping("/api/**")
                .allowedOrigins(
                    "https://skillswapplat-1.onrender.com",
                    "https://*.vercel.app",
                    "app://com.skillswap.platform"  // For TWA
                )
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true);
        }
    };
}
```

Redeploy backend after changes.

---

## Troubleshooting

### APK Won't Install
- Check device storage
- Ensure device API level ≥ 24
- Check certificate matches domain

### App Shows Blank Screen
- Check internet connection
- Verify assetlinks.json is deployed
- Test URL manually in browser
- Check backend CORS configuration

### Digital Asset Links Not Verifying
- Ensure JSON file is at: `/.well-known/assetlinks.json`
- Check SHA256 fingerprint is exactly correct (no colons)
- Verify JSON syntax is valid (no typos)
- Wait 24-48 hours for Google to cache

### Build Fails
- Run `./gradlew clean` first
- Update Android SDK to latest
- Ensure Java 11+ is installed
- Check build.gradle.kts syntax

---

## Testing Digital Asset Links

```powershell
# Verify the Digital Asset Links JSON is accessible
Invoke-WebRequest -Uri "https://skillswapplat-1.onrender.com/.well-known/assetlinks.json" -Method Get | Select-Object Content

# Should return valid JSON without errors
```

---

## Important Security Notes

1. **Keep upload-key.jks safe** - Never commit to git
2. **Store password securely** - You'll need it for future app updates
3. **SHA256 fingerprint** - Must match for signature verification
4. **assetlinks.json** - Proves app-to-website ownership
5. **HTTPS required** - Always use HTTPS for TWA

---

## Useful Links

- [Google Trusted Web Activity Developer Guide](https://developers.google.com/web/android/trusted-web-activity)
- [Android Build Documentation](https://developer.android.com/studio)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [Digital Asset Links Protocol](https://developers.google.com/digital-asset-links)
- [Chrome Custom Tabs Documentation](https://developer.chrome.com/docs/android/custom-tabs/)

---

## Next Actions

1. ✅ Android project structure created
2. ⏳ Generate keystore certificate (Step 1)
3. ⏳ Deploy assetlinks.json to backend
4. ⏳ Build APK with Android Studio
5. ⏳ Test on Android device
6. ⏳ Upload to Google Play Console
