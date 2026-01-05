import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration - REPLACE WITH YOUR VALUES FROM FIREBASE CONSOLE
/// 
/// To get these values:
/// 1. Go to https://console.firebase.google.com
/// 2. Create a new project (or use existing)
/// 3. Add a Web app (click </> icon)
/// 4. Copy the config values below
/// 5. Enable Firestore Database in Build → Firestore

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDex0GSwDtPi6g5pZkllqt6qY9tqZePRqQ',
    appId: '1:217070548268:web:5f9730f268103ac1c92889',
    messagingSenderId: '217070548268',
    projectId: 'limited-47d6e',
    storageBucket: 'limited-47d6e.firebasestorage.app',
    authDomain: 'limited-47d6e.firebaseapp.com',
    measurementId: 'G-CD3TWEGLG3',
  );

  // For Android - add when ready for mobile
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDex0GSwDtPi6g5pZkllqt6qY9tqZePRqQ',
    appId: '1:217070548268:web:5f9730f268103ac1c92889',
    messagingSenderId: '217070548268',
    projectId: 'limited-47d6e',
    storageBucket: 'limited-47d6e.firebasestorage.app',
  );

  // For iOS - add when ready for mobile
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDex0GSwDtPi6g5pZkllqt6qY9tqZePRqQ',
    appId: '1:217070548268:web:5f9730f268103ac1c92889',
    messagingSenderId: '217070548268',
    projectId: 'limited-47d6e',
    storageBucket: 'limited-47d6e.firebasestorage.app',
    iosBundleId: 'com.example.limited',
  );
}
