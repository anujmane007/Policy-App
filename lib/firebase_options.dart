// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'Replace with your Key',
    appId: 'Replace with your Key',
    messagingSenderId: 'Replace with your Key',
    projectId: 'Replace with your Key',
    storageBucket: 'Replace with your Key',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'Replace with your Key',
    appId: 'Replace with your Key',
    messagingSenderId: 'Replace with your Key',
    projectId: 'Replace with your Key',
    storageBucket: 'Replace with your Key',
    iosBundleId: 'Replace with your Key',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'Replace with your Key',
    appId: 'Replace with your Key',
    messagingSenderId: 'Replace with your Key',
    projectId: 'Replace with your Key',
    authDomain: 'Replace with your Key',
    storageBucket: 'Replace with your Key',
    measurementId: 'Replace with your Key',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'Replace with your Key',
    appId: 'Replace with your Key',
    messagingSenderId: 'Replace with your Key',
    projectId: 'Replace with your Key',
    storageBucket: 'Replace with your Key',
    iosBundleId: 'Replace with your Key',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'Replace with your Key',
    appId: 'Replace with your Key',
    messagingSenderId: 'Replace with your Key',
    projectId: 'Replace with your Key',
    authDomain: 'Replace with your Key',
    storageBucket: 'Replace with your Key',
    measurementId: 'Replace with your Key',
  );

}
