# LIMITED

**One truth. One chance. Forever.**

A confession app where you get exactly ONE opportunity per category to write something permanent. No edits. No deletes. No second chances.

---

## The Concept

We all carry weight. Words unspoken. Feelings buried. Truths we've never said.

LIMITED is a ritual of release. Write your truth, seal it forever, and let it go.

---

## Features

### Core
- **One chance per category** - Choose wisely
- **Permanent seal** - No edits, no deletes
- **Real global counter** - See how many truths have been sealed worldwide
- **Global Wall** - Anonymous truths from people around the world
- **Viral sharing** - Share your seal moment with download link

### Design
- **FOMO UI** - Pulse red warnings, sacred gold rewards
- **Urgency elements** - "This cannot be undone"
- **Haptic feedback** - Feel the weight of permanence
- **Dark void aesthetic** - Serious, intentional

### Engagement Features
- **Daily Prompts**: Fresh writing prompts every day
- **Streak System**: Track your emotional wellness journey
- **Swipeable Wall**: Beautiful card-based view of all sealed messages
- **Timestamps**: See exactly when each truth was sealed

### 10 Categories
**Free**: Love, Regret, Goodbye, Confession  
**Premium**: Forgive, Promise, Last Words, Gratitude, Fear, Hope

### Viral Sharing
- Share individual rewards with friends
- Share messages from your wall
- Invite friends with compelling copy
- "Why LIMITED" page designed for viral spread

---

## Monetization Strategy

### How This Makes Money (Realistically)

**1. Ads (AdMob)**
- Banner ads on Category and Wall screens
- Interstitial ad shown ONCE after each lock (feels like "paying the toll")
- Test IDs included, ready to swap for production

**2. Premium One-Time Purchase**
- Remove all ads forever
- Unlock 6 premium categories (Forgive, Promise, Last Words, Gratitude, Fear, Hope)
- Exclusive reward lines
- Suggested price: $4.99 - $9.99

**3. Future Monetization**
- Sponsored reward packs (brands sponsor reward lines)
- Affiliate links to journaling apps, therapy directories
- "Second Chance" IAP: Pay to write in a category again (rare, premium)

### Why Users Will Pay
- **Emotional investment**: After locking messages, users are invested
- **Scarcity creates value**: The permanence makes it feel important
- **Premium feels exclusive**: Extra categories feel like a reward
- **No subscription fatigue**: One-time purchase is more appealing

---

## Tech Stack

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `cloud_firestore` | Real-time database for global counter + wall |
| `shared_preferences` | Local offline storage |
| `google_mobile_ads` | Banner + interstitial ads |
| `share_plus` | Share functionality |

---

## Getting Started

### Prerequisites
- Flutter SDK 3.0.0+
- Android Studio / VS Code
- Android device or emulator

### Quick Start
```bash
cd /Users/vinoteca/Desktop/Limited
flutter pub get
flutter run
```

### Build for Release
```bash
# APK for direct install
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release
```

---

## Configuration

### AdMob Setup
1. Create AdMob account at https://admob.google.com
2. Add your app and create ad units
3. Replace test IDs in `lib/services/ads_service.dart`:
```dart
static const String _bannerAdUnitIdAndroid = 'YOUR_BANNER_ID';
static const String _interstitialAdUnitIdAndroid = 'YOUR_INTERSTITIAL_ID';
```
4. Update `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="YOUR_ADMOB_APP_ID"/>
```

### In-App Purchases
See detailed TODO in `lib/services/premium_service.dart`

### Firebase (Future)
`DataRepository` interface in `storage_service.dart` makes Firebase swap easy.

---

## Project Structure

```
lib/
├── main.dart                     # App entry point
├── constants/
│   └── app_constants.dart        # Design system, categories, rewards
├── screens/
│   ├── splash_screen.dart        # Animated splash with glow
│   ├── onboarding_screen.dart    # 4-screen emotional onboarding
│   ├── category_screen.dart      # Category grid with daily prompts
│   ├── write_screen.dart         # Message composition with validation
│   ├── lock_screen.dart          # Dramatic lock animation
│   ├── reward_screen.dart        # Reward reveal with sharing
│   ├── wall_screen.dart          # Swipeable sealed messages
│   ├── about_screen.dart         # Premium + stats + contact
│   └── why_screen.dart           # 7-screen emotional journey
├── widgets/
│   ├── animated_background.dart  # Particles + glow effects
│   └── premium_button.dart       # Reusable gold button
└── services/
    ├── storage_service.dart      # Local storage + Firebase interface
    ├── ads_service.dart          # AdMob with test IDs
    ├── premium_service.dart      # IAP stub with TODOs
    ├── audio_service.dart        # Whisper sound
    └── haptic_service.dart       # Haptic feedback sequences
```

---

## Design System

| Token | Value | Usage |
|-------|-------|-------|
| Background | `#000000` | Pure black base |
| Gold | `#D4AF37` | Primary accent |
| Gold Light | `#E8C547` | Highlights |
| Gold Dark | `#B8960F` | Shadows |
| Secondary | `#B0B0B0` | Muted text |
| Card BG | `#0A0A0A` | Elevated surfaces |

### Typography
- Display: 56px / 900 weight / 8px letter-spacing
- Headline: 28px / 600 weight / 2px letter-spacing
- Body: 18px / 400 weight / 0.5px letter-spacing
- Label: 14px / 600 weight / 2px letter-spacing

---

## What Makes This Revolutionary

1. **First of its kind**: No other app locks messages permanently with this ritual
2. **Emotional design**: Every animation, sound, and word is intentional
3. **Viral mechanics**: "Why" page designed to be shared
4. **Ethical monetization**: Ads feel like part of the ritual, not intrusive
5. **Offline-first**: Works without internet, ready for Firebase later
6. **Premium without sleaze**: No manipulation, just value

---

## License

MIT License

---

*Built with intention. Designed for courage.*
