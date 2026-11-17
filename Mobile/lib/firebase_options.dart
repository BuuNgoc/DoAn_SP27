import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with Firebase.initializeApp
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
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBcIRU-3DtPCDveyT6ZiDkw2FLPSlraZzg',
    appId: '1:462033431838:web:3512ce9388d23f187e2d0f',
    messagingSenderId: '462033431838',
    projectId: 'smarttravel-se13',
    authDomain: 'smarttravel-se13.firebaseapp.com',
    storageBucket: 'smarttravel-se13.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBcIRU-3DtPCDveyT6ZiDkw2FLPSlraZzg',
    appId: '1:462033431838:android:3512ce9388d23f187e2d0f',
    messagingSenderId: '462033431838',
    projectId: 'smarttravel-se13',
    storageBucket: 'smarttravel-se13.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBcIRU-3DtPCDveyT6ZiDkw2FLPSlraZzg',
    appId: '1:462033431838:ios:3512ce9388d23f187e2d0f',
    messagingSenderId: '462033431838',
    projectId: 'smarttravel-se13',
    storageBucket: 'smarttravel-se13.firebasestorage.app',
    iosBundleId: 'com.se13.smarttravel.smart_travel_app',
  );
}
