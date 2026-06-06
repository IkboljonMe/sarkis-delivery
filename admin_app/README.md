# Sarkis Bread — Admin App (v2)

Dark, premium operational Flutter app for the owner/driver. Russian-primary UI.
Manage shifts, products, orders, chats, broadcast messages, and drive to
addresses with one-tap Google Maps navigation.

## Setup
1. Clone the repository.
2. `cd admin_app`
3. Add `google-services.json` to `android/app/` (Android builds).
4. Update `lib/utils/constants.dart` (`adminWhatsappNumber`). Firebase config is
   in `lib/demo_firebase_options.dart`.
5. Before the first Android build, add the `compileSdk 36` `subprojects` block to
   `android/build.gradle.kts` (see `../docs/ANDROID_SETUP.md`).
6. `flutter pub get`
7. Run:
   - Web: `flutter run -d chrome`
   - Android: `flutter run -d <device>`

## First login
- Use the email/password created in Firebase Console.
- The Firestore `users/{uid}` document **must** have `isAdmin: true` — the app
  verifies this after login and rejects non-admins.

## Key features
- **Dashboard** — live pending/confirmed/on-the-way/delivered counters
  (count-up animation), recent orders, all filtered by the active group.
- **Group switch** — Berlin/Hamburg toggle in the drawer & app bar; everything
  filters by it.
- **Shifts** — create/open/close/delete delivery dates; shift detail with
  Active/Finished tabs and mark-as-delivered.
- **Orders** — status tabs + date filter; detail with tap-to-call, copy
  address, Maps navigation, status workflow, and in-order chat with FCM push.
- **Products** — Categories & Products tabs; add/edit with 5-language tabbed
  name/description fields.
- **Chats** — topic list (unread-first), search, group filter, and broadcast
  (all / by group) with FCM.
- **Locations** — pick a shift, get current location, ordered address list with
  copy + navigate, and copy-all.
- **Settings** — min/max qty, contact numbers, app info, logout.

## Architecture
Provider (`AdminAuthProvider`, `GroupProvider`), shared service layer, shared
design system mirrored from the customer app.
