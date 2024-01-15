// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCmtT1rs9a3zqkuIFUyf5CKf-iW4jIreZw',
    appId: '1:175933602171:web:324c826075a51d6d4125de',
    messagingSenderId: '175933602171',
    projectId: 'myteleclinic-ef990',
    authDomain: 'myteleclinic-ef990.firebaseapp.com',
    storageBucket: 'myteleclinic-ef990.appspot.com',
    measurementId: 'G-LT8H1CN3SX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB4S8_Naic0JfLAKDTCgLld7eR6Mb4eNzo',
    appId: '1:175933602171:android:a5fecee749c988864125de',
    messagingSenderId: '175933602171',
    projectId: 'myteleclinic-ef990',
    storageBucket: 'myteleclinic-ef990.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBqtsPZykt1LQ7wetwjKfYRl6CPvBAQEbI',
    appId: '1:175933602171:ios:7d78bd37899bd7eb4125de',
    messagingSenderId: '175933602171',
    projectId: 'myteleclinic-ef990',
    storageBucket: 'myteleclinic-ef990.appspot.com',
    iosBundleId: 'com.example.myTeleclinic',
  );
}
