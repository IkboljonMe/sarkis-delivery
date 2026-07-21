# Changes Log

## 2026-07-21 21:06 — Firebase removal across apps and backend; old branding cleanup

**What changed:**

### customer_app (`app/customer_app/`)
- Deleted Firebase-specific files: `lib/demo_firebase_options.dart`, `lib/services/fcm_service.dart`, `android/app/google-services.json`, `web/firebase-messaging-sw.js`
- Removed `firebase_core` and `firebase_messaging` dependencies from `pubspec.yaml` and `pubspec.lock` (dropped 7 transitive packages)
- Rewired foreground notifications in `lib/services/local_notifications.dart`: renamed API from `showFromMessage(RemoteMessage)` to `showFromPayload(Map<String, dynamic>)`, now driven by Socket.IO payload instead of FCM; renamed Android channel id from `sarkis_bread_channel` to `app_notifications_channel`
- Removed all Firebase initialization, background-handler, and message-listener code from `lib/main.dart`; retained local-notification initialization and tap routing
- Updated `lib/screens/main_shell.dart`: foreground notification subscription now listens to `SocketService.instance.events` filtered on `notification:created` instead of FCM foreground stream
- Removed `FcmService.instance.init(...)` call sites from `lib/providers/auth_provider.dart` (two locations)
- Removed FCM default-channel metadata block from `android/app/src/main/AndroidManifest.xml`
- Renamed app class: `SarkisApp` → `SarkoApp` in `lib/main.dart`
- Rebranded all 5 i18n files (`lib/l10n/app_en.arb`, `app_de.arb`, `app_hy.arb`, `app_ru.arb`, `app_tr.arb`): updated `appName` and `welcome` string values
- Removed stale "Sarkis backend" comment from `lib/services/auth_service.dart`
- Removed stale Firebase-era comment from `lib/providers/cart_provider.dart`
- Removed stale comment from `lib/utils/constants.dart`
- Updated in-app chat admin persona display name ("Sarkis" → "Sarko") in `lib/utils/welcome_message.dart` (`senderName` variable) and corresponding localized welcome message text across all EN/RU/DE/TR/HY translations; this is live customer-facing chat copy, user-confirmed before change
- Removed stale comment from `lib/utils/order_messages.dart` referencing old admin naming
- Updated `README.md` title
- **Deliberately left untouched (deployment/infra risk):** Android `applicationId`/namespace `com.sarkisbread.pl`, the deployed URL constant `https://sarkis-delivery.vercel.app`, and the unused `UserModel.fcmToken` field (kept as inert storage to avoid DB migration)

### admin_app (`app/admin_app/`)
- Deleted Firebase-specific files: `lib/demo_firebase_options.dart`, `lib/services/fcm_service.dart`, `web/firebase-messaging-sw.js`
- Removed `firebase_core` and `firebase_messaging` dependencies from `pubspec.yaml` and `pubspec.lock`
- Rewired notifications in `lib/services/local_notifications.dart`: same `showFromMessage` → `showFromPayload` rewrite; renamed channel id from `sarkis_bread_admin_channel` to `app_notifications_channel`
- Collapsed Firebase initialization in `lib/main.dart` and updated `lib/screens/main_scaffold.dart`: now listens on `SocketService.instance.events` for `notification:created` instead of FCM listeners
- Removed two stale Firebase/Firestore-era comments from `lib/models/region_group_model.dart` (no behavior change)
- Removed FCM default-channel metadata block from `android/app/src/main/AndroidManifest.xml`
- Updated `README.md` title
- Updated comment wording in `test/gen_icon_test.dart`
- Manual follow-up fix found during review: `lib/screens/orders/order_detail_screen.dart` — updated chat message `senderName: 'Sarkis'` → `'Sarko'` and rewrote stale "push handled by the order-status Cloud Function" comment to describe the actual NestJS/Postgres server-side notification path
- **Note:** Android `applicationId` was already non-Sarkis (`com.example.admin_app`), so no exception needed

### backend (`backend/`)
- Removed all Firebase Admin SDK code from `src/notifications/notifications.module.ts`: deleted dynamic import of `firebase-admin`, removed `onModuleInit` initialization logic, removed `OnModuleInit` interface implementation, removed now-unused `ConfigService` injection, removed `sendEachForMulticast` and dead-token-pruning block
- The notification service now only persists the `Notification` row to database and broadcasts via Socket.IO gateway — this was already the fallback path; it is now the only path
- Removed `firebase-admin` dependency from `package.json` and `package-lock.json` (dropped 94 packages from lockfile)
- Removed `FIREBASE_SERVICE_ACCOUNT` from `.env` and `.env.example`
- **Deliberately left untouched (operational identifiers, out of scope):** Prisma `Device.fcmToken` column and related API surface in `users.controller.ts`/`users.service.ts` (inert token storage now, kept to avoid schema migration), and numerous backend branding/config identifiers that were discovered to still exist but require follow-up validation (see Known Follow-up below)

**Why:** Firebase Cloud Messaging is the only real Firebase usage left in the project (backend was already migrated to Postgres/Prisma; no Firestore exists in code). Removing FCM means losing OS-level background/killed-state push notifications, but in-app notifications continue to work via the existing Socket.IO `notification:created` event + Postgres `Notification` table + local Drift-synced inbox, which operate independently of FCM. Foreground local notifications are now driven by that socket event instead of Firebase's onMessage listener. The old "Sarkis Bread" / "Sarkis Delivery" branding has been replaced with "Sarko" across customer-facing surfaces and internal code, with deliberate exceptions for deployment-sensitive identifiers (package names, deployed URLs, schema fields) and operational names that require validation before change.

**Verification:**
- Zero Firebase references found (grep -r "firebase" across customer_app, admin_app, backend, excluding node_modules/build/dist/.dart_tool: 0 matches)
- `flutter analyze` on both customer_app and admin_app: clean (only pre-existing style infos, unrelated to this change)
- Backend `npx tsc --noEmit`: 0 errors
- All changes present in `git status --short` as staged modifications; not yet committed

**Known Follow-up NOT Done (Flagged Risk):**
A scoping error during backend work: the grep command used to check for "sarkis" branding in backend was told there were no results, but the check actually had a zsh glob error and silently failed. A corrected grep afterward found real "sarkis"-branded identifiers still in `backend/` that were deliberately NOT changed:
- `package.json`/`package-lock.json`: `"name": "sarkis-backend"`
- `ecosystem.config.js`: PM2 process name `'sarkis-backend'`
- `docker-compose.yml`: Postgres user/password/database all named `sarkis`/`sarkis_dev_password`
- `.env.example`: `DATABASE_URL` and `DATABASE_URL_TEST` with those credentials
- `.env.example`: `SUPERADMIN_EMAIL=superadmin@sarkis.delivery`
- `.env.example`: `GATEWAYAPI_SENDER=Sarkis` (external SMS provider sender ID)
- `src/main.ts`: startup log line "Sarkis API listening on :..."
- `test/api.e2e-spec.ts`: test suite name `describe('Sarkis API (e2e)', ...)`

These are **operational identifiers**, not just internal naming — they include live database credentials, a PM2 process name that may be referenced in deploy scripts, and a real external SMS-provider sender ID. Renaming them without confirming they are safe to change (and, for `GATEWAYAPI_SENDER`, without re-registering with the SMS provider) risks breaking a running deployment. This requires a follow-up conversation with the user.
