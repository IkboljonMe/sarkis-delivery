import 'package:firebase_core/firebase_core.dart';

/// Real Firebase config for project `sarkisbread` (shared with the customer app
/// for the web run). appId is the ANDROID id; register a Web app for production
/// web. Admin uses email/password auth, which only needs valid project config.
class DemoFirebaseOptions {
  static const FirebaseOptions current = FirebaseOptions(
    apiKey: 'AIzaSyBxRHDfeqfjKeE2982uS8sKp1_sLtHXlBE',
    appId: '1:889234012731:android:ec3eed6029461cf8b7fa1e',
    messagingSenderId: '889234012731',
    projectId: 'sarkisbread',
    authDomain: 'sarkisbread.firebaseapp.com',
    storageBucket: 'sarkisbread.firebasestorage.app',
  );
}
