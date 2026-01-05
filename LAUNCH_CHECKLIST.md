# LIMITED - Launch Checklist

## Pre-Launch (Do Now)

### Code ✅
- [x] Firebase backend connected
- [x] Real global counter
- [x] Global wall showing all sealed truths
- [x] Viral share text with download link
- [x] FOMO UI (pulse red, sacred gold, urgency warnings)
- [x] Splash screen with ENTER button
- [x] Category screen with compact cards
- [x] All screens polished

### Firebase ✅
- [x] Project created: `limited-47d6e`
- [x] Firestore enabled
- [x] Web app configured

### Pending Before Launch
- [ ] Register domain (limited-app.com or alternative)
- [ ] Update download link in code (currently placeholder)
- [ ] Create app icon (1024x1024)
- [ ] Take 5 screenshots for App Store
- [ ] Build release APK/IPA

---

## To Update Download Link

Edit `lib/constants/app_constants.dart`:
```dart
// Change this:
Download: https://limited-app.com

// To your actual App Store link:
Download: https://apps.apple.com/app/limited/id123456789
```

---

## Build Commands

### Android Release
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS Release
```bash
flutter build ios --release
```
Then archive in Xcode.

### Web (for testing)
```bash
flutter build web
```

---

## App Store Submission

### iOS (App Store Connect)
1. Create app in App Store Connect
2. Upload screenshots (6.5" and 5.5")
3. Fill in description from MARKETING.md
4. Set pricing: Free
5. Submit for review

### Android (Google Play Console)
1. Create app in Play Console
2. Upload AAB: `flutter build appbundle`
3. Fill in listing from MARKETING.md
4. Set up content rating
5. Submit for review

---

## Post-Launch

### Day 1
- [ ] Post on Reddit (see MARKETING.md for post template)
- [ ] Tweet launch announcement
- [ ] Share in relevant Discord/Slack communities

### Week 1
- [ ] Submit to ProductHunt
- [ ] Create TikTok/Reels
- [ ] Monitor Firebase for usage

### Ongoing
- [ ] Respond to reviews
- [ ] Share milestones (1K sealed, 10K sealed)
- [ ] A/B test share text

---

## Quick Stats Check

Firebase Console → Firestore:
- `stats/global` → `sealedCount` = total truths
- `sealed_truths` collection → all messages

---

## Emergency Fixes

### If counter stuck:
Check Firestore rules allow read/write

### If app crashes:
```bash
flutter clean
flutter pub get
flutter run
```

### If Firebase errors:
Verify `firebase_options.dart` has correct config

---

*Ready to launch. Let's go.*
