# TWA Conversion - Quick Reference

## 📁 Files Created

### Documentation
- `TWA_CONVERSION_GUIDE.md` - Overview of PWA→TWA differences
- `TWA_SETUP_STEPS.md` - Detailed step-by-step instructions (START HERE)
- `BACKEND_CORS_FOR_TWA.md` - Java backend configuration
- `TWA_QUICK_REFERENCE.md` - This file

### Android Project Structure
```
android-app/
├── build.gradle.kts                           # Root build config
├── settings.gradle.kts                        # Project settings
├── app/
│   ├── build.gradle.kts                      # App build config
│   ├── proguard-rules.pro                    # Code obfuscation
│   ├── assetlinks.json                       # Digital asset links (UPDATE WITH SHA256)
│   └── src/main/
│       ├── AndroidManifest.xml               # App manifest
│       ├── java/com/skillswap/platform/
│       │   ├── LauncherActivity.java         # Entry point
│       │   └── DelegationService.java        # TWA service
│       └── res/
│           ├── values/
│           │   ├── strings.xml
│           │   ├── colors.xml
│           │   └── themes.xml
│           └── xml/
│               ├── file_paths.xml
│               └── network_security_config.xml
```

---

## ⚡ Quick Start (5 Steps)

### 1. Generate Signing Certificate (5 min)
```powershell
cd c:\Users\HP\skillswapplat\android-app
keytool -genkey -v -keystore upload-key.jks -keyalg RSA -keysize 2048 -validity 10957 -alias upload
```

### 2. Get SHA256 Fingerprint (1 min)
```powershell
keytool -list -v -keystore upload-key.jks -alias upload
# Copy SHA256 fingerprint (remove colons)
```

### 3. Update assetlinks.json (2 min)
Edit: `android-app/assetlinks.json`
Replace: `REPLACE_WITH_YOUR_SHA256_FINGERPRINT`

### 4. Deploy assetlinks.json to Backend (1 min)
Copy to: `backend/SSA/src/main/resources/static/.well-known/assetlinks.json`
Redeploy backend

### 5. Build Android App (10 min)
```powershell
cd android-app
./gradlew bundleRelease
# Output: app/build/outputs/bundle/release/app-release.aab
```

---

## 🔧 Common Commands

### Clean Build
```powershell
./gradlew clean
```

### Build APK (for local testing)
```powershell
./gradlew assembleRelease
```

### Build App Bundle (for Play Store)
```powershell
./gradlew bundleRelease
```

### Install on Device/Emulator
```powershell
adb install app/build/outputs/apk/release/app-release.apk
```

### Verify Digital Asset Links
```powershell
Invoke-WebRequest -Uri "https://skillswapplat-1.onrender.com/.well-known/assetlinks.json"
```

### Check Device Logs
```powershell
adb logcat | findstr SkillSwap
```

---

## 📋 Checklist

- [ ] Android Studio installed
- [ ] Android SDK 34 installed
- [ ] Java 11+ installed
- [ ] Keystore (upload-key.jks) generated
- [ ] SHA256 fingerprint obtained
- [ ] assetlinks.json updated with fingerprint
- [ ] assetlinks.json deployed to backend
- [ ] Backend redeployed
- [ ] APK built and tested locally
- [ ] App Bundle generated (AAB)
- [ ] Google Play Developer account created
- [ ] App uploaded to Play Console
- [ ] App details filled in (screenshots, description)
- [ ] App submitted for review

---

## 🎯 Key Points

| Aspect | VS PWA | TWA |
|--------|--------|-----|
| **Installation** | Add to Home Screen | Download from Play Store |
| **App Icon** | Website favicon | Proper app icon |
| **App Drawer** | Yes | Yes |
| **Appearance** | Full screen | Native app look |
| **Distribution** | Web-based | App Store |
| **Web Access** | Direct browser | WebView (similar) |
| **Offline** | Service Worker | Service Worker |
| **Permissions** | Limited | Full Android permissions |

---

## 🚀 Next Phase: Play Store Upload

Once you have the AAB file:

1. Create Google Play Developer account (one-time $25)
2. Create app in Play Console
3. Upload AAB file
4. Fill in store listing
5. Configure pricing
6. Submit for review (24-48 hours)

---

## 📞 Support Resources

- **Google Trusted Web Activity Docs**: https://developers.google.com/web/android/trusted-web-activity
- **Android Developer Guide**: https://developer.android.com/guide
- **Play Console Help**: https://support.google.com/googleplay/android-developer
- **Android Studio**: https://developer.android.com/studio

---

## ⚠️ Important Notes

1. **Keystore**: Keep `upload-key.jks` safe - you need it for all future app updates
2. **Fingerprint**: Must match for app-to-website verification to work
3. **HTTPS**: TWA requires HTTPS URL (https://skillswapplat-1.onrender.com)
4. **assetlinks.json**: Must be at `/.well-known/assetlinks.json`
5. **Signing**: Every app release must be signed with the same certificate

---

## What Works Out-of-the-Box

✅ Offline support (service worker)
✅ App icons and theme colors
✅ Responsive design (already responsive)
✅ Fast loading (same as PWA)
✅ App permissions framework
✅ Share functionality
✅ Notifications support
✅ Payment APIs

---

**Ready to start? Begin with**: `TWA_SETUP_STEPS.md`
