// =============================================================================
// FIREBASE OPTIONS - PLACEHOLDER TEMPLATE
// =============================================================================
//
// This file is a placeholder for the Firebase configuration.
// It will be automatically replaced when you run start.sh
//
// To configure Firebase:
// 1. Run ./start.sh from the project root
// 2. Or manually run: flutterfire configure --project=<your-project-id>
//
// =============================================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// This is a placeholder template. Run start.sh to configure your Firebase project.
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Placeholder values - will be replaced by flutterfire configure
  // API key format: 39 chars starting with 'AIza' to pass Firebase validation
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyABCDEFGHIJKLMNOPQRSTUVWXYZabc1234',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'placeholder-project',
    authDomain: 'placeholder-project.firebaseapp.com',
    storageBucket: 'placeholder-project.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyABCDEFGHIJKLMNOPQRSTUVWXYZabc1234',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'placeholder-project',
    storageBucket: 'placeholder-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyABCDEFGHIJKLMNOPQRSTUVWXYZabc1234',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'placeholder-project',
    storageBucket: 'placeholder-project.appspot.com',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyABCDEFGHIJKLMNOPQRSTUVWXYZabc1234',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'placeholder-project',
    storageBucket: 'placeholder-project.appspot.com',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyABCDEFGHIJKLMNOPQRSTUVWXYZabc1234',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'placeholder-project',
    authDomain: 'placeholder-project.firebaseapp.com',
    storageBucket: 'placeholder-project.appspot.com',
  );
}
