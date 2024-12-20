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
    apiKey: 'AIzaSyDWfxBueMwGb4BhV3gkhvPmrVC0JsZwwic',
    appId: '1:362082290742:android:b405e040ff4286ab7d9c97',
    messagingSenderId: '362082290742',
    projectId: 'greennursery-7eccd',
    storageBucket: 'greennursery-7eccd.appspot.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDkFmMl0ezx1M1fBsG3dR-4-7RPdqmQ7ew',
    appId: '1:362082290742:web:c4a0fa82fb50b73e7d9c97',
    messagingSenderId: '362082290742',
    projectId: 'greennursery-7eccd',
    authDomain: 'greennursery-7eccd.firebaseapp.com',
    storageBucket: 'greennursery-7eccd.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBan2a9PBiZ-HbR8DqLjy5bTsGLlcMWBsw',
    appId: '1:362082290742:ios:e6135301de2728aa7d9c97',
    messagingSenderId: '362082290742',
    projectId: 'greennursery-7eccd',
    storageBucket: 'greennursery-7eccd.appspot.com',
    iosClientId: '362082290742-huc1cm698417bd54gla5asu2n8aveiia.apps.googleusercontent.com',
    iosBundleId: 'com.example.greennursery',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBan2a9PBiZ-HbR8DqLjy5bTsGLlcMWBsw',
    appId: '1:362082290742:ios:e6135301de2728aa7d9c97',
    messagingSenderId: '362082290742',
    projectId: 'greennursery-7eccd',
    storageBucket: 'greennursery-7eccd.appspot.com',
    iosClientId: '362082290742-huc1cm698417bd54gla5asu2n8aveiia.apps.googleusercontent.com',
    iosBundleId: 'com.example.greennursery',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDkFmMl0ezx1M1fBsG3dR-4-7RPdqmQ7ew',
    appId: '1:362082290742:web:49886dc5a3601e747d9c97',
    messagingSenderId: '362082290742',
    projectId: 'greennursery-7eccd',
    authDomain: 'greennursery-7eccd.firebaseapp.com',
    storageBucket: 'greennursery-7eccd.appspot.com',
  );

}