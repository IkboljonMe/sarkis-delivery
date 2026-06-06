# Sarkis Bread — Customer App

Flutter app for customers to order Armenian breads for cash-on-delivery in
Berlin and Hamburg, Germany. Customers log in by phone number, browse the
delivery dates open for their group, place orders, and receive messages from
the admin about their order — in 5 languages (English, Armenian, Russian,
Turkish, German).

## Prerequisites
- Flutter 3.x (`flutter --version`)
- Firebase CLI (`npm install -g firebase-tools`)
- Android Studio + Android SDK

## Setup

### Step 1 — Clone the repo
```bash
git clone <repo-url>
cd SarkisBread/customer_app
```

### Step 2 — Add `google-services.json`
Download it from the Firebase console (see
[`../docs/FIREBASE_SETUP.md`](../docs/FIREBASE_SETUP.md)) and place it at:
```
customer_app/android/app/google-services.json
```

### Step 3 — Set API keys in `lib/utils/constants.dart`
```dart
static const String googleGeocodingApiKey = 'YOUR_KEY_HERE';
static const String adminWhatsappNumber  = 'YOUR_NUMBER_HERE';
static const String adminUid             = 'YOUR_ADMIN_UID_HERE';
```
Also set the Google API key in
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
| **Splash** | Brand screen; routes to login / profile / home based on auth state. |
| **Phone** | Phone-number entry with country picker (DE/AM/RU/TR); SMS or WhatsApp fallback. |
| **OTP** | 6-digit code with 60s resend countdown and auto-verify. |
| **Profile setup** | First-login profile; validates address via Google Geocoding, auto-assigns Berlin/Hamburg by postal code. |
| **Home** | Open delivery dates for the user's group; pull to refresh. |
| **Order** | Product catalog with +/- quantity controls and sticky cart bar. |
| **My orders** | Real-time list of the user's orders with status & unread-message badges. |
| **Order detail** | Items, total, status and read-only admin message thread. |
| **Profile** | Edit name/address, switch language (5), contact WhatsApp, logout. |

## Tech
Firebase Auth (phone), Cloud Firestore, FCM, Provider, ARB localization.
