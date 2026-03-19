# Build Android TWA with Android Studio

## Quick Steps in Android Studio

### 1. Open Android Project
- Launch Android Studio
- Click **File** → **Open**
- Select: `C:\Users\HP\skillswapplat\android-app`
- Click OK and wait for Gradle to sync (2-3 minutes)

### 2. Build Signed App Bundle (for Play Store)
- Go to **Build** → **Generate Signed Bundle / APK**
- Select **Android App Bundle** → Next
- **Key store path**: Browse to `C:\Users\HP\skillswapplat\android-app\upload-key.jks`
- **Key store password**: `skillswap2024`
- **Key alias**: `upload`
- **Key password**: `skillswap2024`
- Click Next
- Select **release** → Finish
- Wait 2-3 minutes for build to complete

### 3. Locate Output
APK Bundle will be at:
```
C:\Users\HP\skillswapplat\android-app\app\release\app-release.aab
```

### 4. Build Debug APK (for local testing)
- **Build** → **Build Bundle(s) / APK(s)** → **Build APK(s)**
- Output: `app/build/outputs/apk/debug/app-debug.apk`
- Install with: `adb install app-debug.apk`

---

## Status Summary

✅ **Completed:**
- Keystore certificate generated
- SHA256 fingerprint: `B4086F403D2EBCF4A54E4C17F973C088C9E865342DB69BA20B2CB897B08DBB8C`
- assetlinks.json updated and deployed to backend
- Backend CORS updated for TWA app
- Android project configured
- Gradle wrapper setup
- Signing config configured

⏳ **Next in Android Studio:**
1. Open android-app project
2. Wait for sync
3. Build → Generate Signed Bundle
4. Use your keystore details
5. Get app-release.aab

---

## Files Location Reference

- **Keystore**: `C:\Users\HP\skillswapplat\android-app\upload-key.jks`
- **Project**: `C:\Users\HP\skillswapplat\android-app`
- **Backend .well-known**: `C:\Users\HP\skillswapplat\backend\SSA\src\main\resources\static\.well-known\assetlinks.json`

