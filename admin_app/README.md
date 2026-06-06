# Sarkis Bread — Admin / Driver App

Flutter app for the owner/driver to manage the Sarkis Bread delivery business.
Single admin account (email + password). Manage delivery dates and products,
view and progress orders, message customers (with FCM push), tap an address to
open Google Maps navigation, and call customers directly. UI is in Russian
(primary) with English fallbacks.

## Prerequisites
- Flutter 3.x (`flutter --version`)
- Firebase CLI (`npm install -g firebase-tools`)
- Android Studio + Android SDK

## Setup

### Step 1 — Clone the repo
```bash
git clone <repo-url>
cd SarkisBread/admin_app
```

### Step 2 — Add `google-services.json`
Download it from the Firebase console (see
[`../docs/FIREBASE_SETUP.md`](../docs/FIREBASE_SETUP.md)) and place it at:
```
admin_app/android/app/google-services.json
```

### Step 3 — Set keys in `lib/utils/constants.dart`
```dart
static const String adminUid          = 'YOUR_ADMIN_UID_HERE';
static const String firebaseProjectId = 'YOUR_FIREBASE_PROJECT_ID';
static const String adminWhatsappNumber = 'YOUR_NUMBER_HERE';
```
> **Create the admin account manually** in the Firebase Console
> (Authentication → Users → Add user), then **copy its UID** into
> `adminUid` above and into `firestore.rules`.

For push notifications, configure `lib/services/fcm_service.dart` with a
service-account key (testing) or point it at a Cloud Function (production).
Also set the Google Maps API key in
`android/app/src/main/AndroidManifest.xml`.

### Step 4 — Install dependencies
```bash
flutter pub get
```

### Step 5 — Run
```bash
flutter run
```
Build a release apk with:
```bash
flutter build apk
```

## Screen overview
| Screen | Description |
| --- | --- |
| **Login** | Email/password with "remember me" auto-login. |
| **Dashboard** | Real-time summary cards (pending, today, Berlin/Hamburg) + quick actions. |
| **Delivery dates** | Create/open/close/delete delivery dates per group. |
| **Products** | CRUD products with per-language names, price, unit, max qty, active toggle. |
| **Orders** | Filter by status tab, group chip and delivery date; real-time list. |
| **Order detail** | Customer info, tap-to-call, Maps navigation, items table, status actions, message thread with FCM. |
| **Messages overview** | Orders with unread customer messages. |
| **Settings** | Edit min/max order qty, admin WhatsApp number, app version. |

## Tech
Firebase Auth (email), Cloud Firestore, FCM HTTP v1, Provider, url_launcher,
grouped_list, badges.
