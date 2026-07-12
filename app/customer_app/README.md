# Sarkis Bread — Customer App (v2)

Dark, premium Flutter app for ordering Armenian breads (cash on delivery,
Berlin & Hamburg). Phone login, 5 languages, shift-based delivery dates,
category/product browsing, cart, order tracking, and live chat with the admin.

## Setup
1. Clone the repository.
2. `cd customer_app`
3. Add `google-services.json` to `android/app/` (Android builds).
4. Update `lib/utils/constants.dart`:
   - `adminWhatsappNumber`
   - `adminUid`
   - Firebase config lives in `lib/demo_firebase_options.dart`.
5. `flutter pub get`
6. Run:
   - Web: `flutter run -d chrome`
   - Android: `flutter run -d <device>`

## Screens
- **Splash** — animated brand, routes by auth/language state.
- **Language** — first-run 5-language picker.
- **Phone / OTP** — Firebase phone auth (test-number friendly).
- **Register** — 3-step profile (name → address → confirm) with auto group
  detection from postal code.
- **Home** — greeting, available shifts (horizontal), category preview, recent
  orders.
- **Categories / Products** — grid + product cards with qty pickers and a
  sticky cart bar.
- **Cart** — items, swipe-to-delete, confirm bottom sheet → order.
- **Order Success** — confetti + copyable order id.
- **My Orders** — Active / Completed tabs, status timeline in detail.
- **Chats** — two-way chat with admin (gold bubbles), unread badge in nav.
- **Profile** — edit info, switch language, WhatsApp, logout.

## Architecture
Provider state management, Firebase (Auth/Firestore/FCM), service layer per
collection, hand-written localization (`lib/l10n`), shared design system in
`lib/utils` + `lib/widgets`.

## Design system
Dark palette (#0A0A0A / gold #C8972A → orange #FF6B35), Playfair Display
headings + Inter body (google_fonts), animations via flutter_animate.
