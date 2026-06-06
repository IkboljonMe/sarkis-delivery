# Android Setup — Sarkis Bread v2

Both apps were scaffolded with `flutter create` and target the
`com.sarkisbread.*` package family. This documents the Android-specific bits.

## Package names
- `customer_app` → `com.sarkisbread.pl` (matches the provided
  `google-services.json`).
- `admin_app` → set your own (e.g. `com.sarkisbread.admin`) and register a
  matching Android app in Firebase to get its `google-services.json`.

## Permissions

### customer_app/android/app/src/main/AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

### admin_app/android/app/src/main/AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.CALL_PHONE"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```
(Location is used by the admin Locations screen via `geolocator`.)

## FCM
- The default notification channel meta-data and the Firebase Messaging service
  are wired automatically by the `firebase_messaging` plugin.
- Add a `<meta-data android:name="com.google.firebase.messaging.default_notification_channel_id" .../>`
  if you want a custom channel.

## Build notes (important for this repo)
This project pins **compileSdk 36** for all plugin subprojects via a
`subprojects { ... }` block in `customer_app/android/build.gradle.kts`
(needed because some plugins ship AndroidX deps requiring API 34+). Replicate
that block in `admin_app/android/build.gradle.kts` before the first Android
build, and keep `minSdk` at the Flutter default (which `firebase_auth` requires
to be ≥ 23).

Gradle heap is reduced in `android/gradle.properties` (`-Xmx3g`) to build on
memory-constrained machines.

## Building
```bash
cd customer_app && flutter build apk --debug
cd ../admin_app   && flutter build apk --debug
```
