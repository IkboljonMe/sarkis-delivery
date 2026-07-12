import 'package:firebase_core/firebase_core.dart';

/// Real Firebase config for project `sarkisbread`.
///
/// NOTE: appId here is the ANDROID app id (1:...:android:...). It is reused for
/// the web run so the SDK initializes against the real project. For a proper
/// production web deployment, register a Web app in the Firebase console and use
/// its `1:...:web:...` appId. Phone auth on web relies on reCAPTCHA + the
/// project's Authorized domains (localhost is allowed by default), not the appId.
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
