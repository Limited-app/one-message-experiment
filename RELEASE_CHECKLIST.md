# LIMITED - Release Checklist

## How Close Is It To Release?

**Status: 95% Complete - Ready for Testing**

The app is fully functional and can run today. What remains are configuration steps you must do yourself (AdMob IDs, Play Store setup, etc.)

---

## BEFORE FIRST TEST (Do Now)

### 1. Install Flutter (if not installed)
```bash
# macOS
brew install flutter

# Or download from https://flutter.dev/docs/get-started/install
```

### 2. Run the App Locally
```bash

```

### 3. Test All Flows
- [ ] Splash screen loads with animation
- [ ] Onboarding appears (first time only)
- [ ] Can select a category
- [ ] Can write and submit a message
- [ ] Lock animation plays
- [ ] Reward shows with share button
- [ ] Wall shows sealed messages
- [ ] About screen shows premium option
- [ ] Why screen is shareable
- [ ] Final Truth works (requires premium + 1 sealed message)

---

## BEFORE RELEASE (Required)

### 4. Create AdMob Account & Replace IDs
1. Go to https://admob.google.com
2. Create account and add your app
3. Create ad units:
   - Banner Ad Unit
   - Interstitial Ad Unit
4. Update `lib/services/ads_service.dart`:
```dart
static const String _bannerAdUnitIdAndroid = 'ca-app-pub-XXXX/XXXX';
static const String _interstitialAdUnitIdAndroid = 'ca-app-pub-XXXX/XXXX';
```
5. Update `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXX~XXXX"/>
```

### 5. Add Audio Asset (Optional but Recommended)
1. Find or create a short whisper/lock sound (1-2 seconds)
2. Save as `whisper.mp3`
3. Place in `assets/audio/whisper.mp3`
4. Add to `pubspec.yaml`:
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/audio/
```

### 6. Create App Icon
1. Design a 1024x1024 icon (gold lock on black recommended)
2. Use https://appicon.co or flutter_launcher_icons package
3. Replace default icons in `android/app/src/main/res/mipmap-*`

### 7. Update App Metadata
- `android/app/build.gradle`: Change `applicationId` to your package name
- `pubspec.yaml`: Update version if needed

---

## PLAY STORE RELEASE

### 8. Create Google Play Developer Account
- One-time $25 fee at https://play.google.com/console

### 9. Build Release APK/Bundle
```bash
# For testing
flutter build apk --release

# For Play Store
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### 10. Create Play Store Listing
Required assets:
- [ ] App icon (512x512)
- [ ] Feature graphic (1024x500)
- [ ] Screenshots (min 2, phone size)
- [ ] Short description (80 chars)
- [ ] Full description (4000 chars)
- [ ] Privacy policy URL
- [ ] Category: Lifestyle or Health & Fitness

### 11. Set Up In-App Purchases (Optional)
1. In Play Console → Monetize → Products → In-app products
2. Create product: `premium_remove_ads`
3. Set price ($4.99 - $9.99 recommended)
4. Implement real IAP in `lib/services/premium_service.dart`

---

## POST-LAUNCH

### 12. Marketing (How to Get Downloads)
- [ ] Post on Reddit (r/apps, r/androidapps, r/selfimprovement)
- [ ] Share on Twitter/X with hashtag #LIMITED
- [ ] Submit to Product Hunt
- [ ] Reach out to app review blogs
- [ ] Create TikTok showing the lock animation
- [ ] Ask friends to leave reviews

### 13. Analytics (Optional)
- Add Firebase Analytics for user tracking
- Monitor AdMob revenue
- Track which categories are most popular

---

## QUICK COMMANDS

```bash
# Run app
flutter run

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Build for Play Store
flutter build appbundle --release

# Clean build
flutter clean && flutter pub get

# Check for issues
flutter analyze
```

---

## FILE STRUCTURE (Final)

```
lib/
├── main.dart
├── constants/
│   └── app_constants.dart
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── category_screen.dart
│   ├── write_screen.dart
│   ├── lock_screen.dart
│   ├── reward_screen.dart
│   ├── wall_screen.dart
│   ├── about_screen.dart
│   ├── why_screen.dart
│   └── final_truth_screen.dart    ← NEW
├── widgets/
│   ├── animated_background.dart
│   └── premium_button.dart
└── services/
    ├── storage_service.dart
    ├── ads_service.dart
    ├── premium_service.dart
    ├── audio_service.dart
    └── haptic_service.dart
```

---

## MONETIZATION SUMMARY

| Source | When | Expected Revenue |
|--------|------|------------------|
| Banner Ads | Category + Wall screens | $0.50-2 CPM |
| Interstitial | After each lock | $2-5 CPM |
| Premium | One-time $4.99-9.99 | Keep 70% |

**Realistic expectations:**
- 1,000 DAU = ~$5-15/day from ads
- 1% premium conversion = ~$35-70 per 1000 installs

---

## THINGS YOU DON'T NEED TO DO

- ❌ Set up Firebase (offline-first works fine)
- ❌ Create a backend server
- ❌ Implement real IAP for testing (stub works)
- ❌ Worry about iOS (Android-first is fine)

---

## SUPPORT

If you encounter issues:
1. Run `flutter doctor` to check setup
2. Run `flutter clean && flutter pub get`
3. Check the README.md for details

---

*LIMITED is ready. Your truth awaits.*
