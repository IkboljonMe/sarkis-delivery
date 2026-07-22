# Changes log

## 2026-07-22 17:00 — Implement Phases 1–5: WhatsApp-grade realtime chat + push

**What changed:**

*Phase 1 — Client realtime + history recovery:*
- `app/admin_app/lib/realtime/socket_service.dart` and `app/customer_app/lib/realtime/socket_service.dart`: self-healing socket rooms with `Set<String>` to track active topics; added `onConnect` handler that re-emits `chat:join` for every active topic on reconnect; added `onConnect` Stream expose; added 'polling' as websocket fallback transport.
- `app/admin_app/lib/sync/sync_engine.dart` and `app/customer_app/lib/sync/sync_engine.dart`: now subscribe to `socket.onConnect` and run `fullSync()` as catch-up on every reconnect.
- `app/customer_app/lib/screens/chats/chats_screen.dart` and `app/admin_app/lib/screens/chats/chat_detail_screen.dart`: chat screens now own their lifecycle — join room + pull history (`syncMessages`) on open via `initState`, leave on `dispose`, with `_syncFailed` flag and retry affordance when cache is empty and pull failed.
- `app/admin_app/lib/services/message_service.dart` and `app/customer_app/lib/services/message_service.dart`: fixed inverted message ordering by changing `messagesStream` from `createdAt DESC` to `ASC`, so newest message is genuinely at the bottom.
- `app/customer_app/lib/l10n/app_strings.dart` and `app/customer_app/lib/l10n/app_en.arb`: added localization key `couldNotLoadMessages`.

*Phase 2 — Send-state reliability:*
- `app/admin_app/lib/local_db/app_database.dart` and `app/customer_app/lib/local_db/app_database.dart`: added `sendFailed` bool column to Messages table; bumped schema version 1→2 with MigrationStrategy (addColumn); regenerated drift code.
- `app/admin_app/lib/models/message_model.dart` and `app/customer_app/lib/models/message_model.dart`: added `pendingSync` and `sendFailed` fields; added `sendStatus` getter returning enum (sending/sent/read/failed); `messagesStream` maps the two columns.
- `app/admin_app/lib/services/message_service.dart` and `app/customer_app/lib/services/message_service.dart`: extracted `_dispatchSend` method and added `resendMessage`; on real server rejection optimistic row is flagged `sendFailed`, on connectivity failure it stays queued.
- `app/admin_app/lib/sync/mutation_queue.dart` and `app/customer_app/lib/sync/mutation_queue.dart`: on real rejection flag message `sendFailed` and cap retries at 5 (drops mutation after); admin queue also gained success-path localRef reconcile it was missing.
- `app/admin_app/lib/widgets/chat/message_bubble.dart` and `app/customer_app/lib/widgets/chat/message_bubble.dart`: added WhatsApp-style status ticks via `_statusIcon` (clock=sending, single/double check=sent/read blue, red error=failed) with tap-to-retry via optional `onRetry` callback wired from both chat screens (customer via MessageProvider.resendMessage, admin via MessageService.resendMessage).

*Phase 3 — Delta cursor correctness:*
- `backend/src/messages/messages.module.ts`: `toMessageJson` now emits `updatedAt`; `list()` and controller gained `updatedSince` query param filtering `updatedAt > cursor` ordered by `updatedAt asc` (keeps `after`/`createdAt` for scroll-back paging).
- `app/admin_app/lib/sync/sync_engine.dart` and `app/customer_app/lib/sync/sync_engine.dart`: `syncMessages` now uses `updatedSince` keyed on max server `updatedAt` seen, reconciling edits/deletes/reactions/read-state that changed while offline (previously only brand-new messages via `createdAt`).

*Phase 4 — Push (FCM HTTP v1 + APNs, no Firebase SDK):*
- `backend/src/push/` (new module): added `PushService` sending via FCM HTTP v1 (google-auth-library + global fetch for Android/web) and APNs over HTTP/2 (jsonwebtoken ES256 for iOS); config-gated by env (FCM_SERVICE_ACCOUNT, FCM_PROJECT_ID, APNS_KEY, APNS_KEY_ID, APNS_TEAM_ID, APNS_BUNDLE_ID, APNS_PRODUCTION); no-ops with single warn when unconfigured; prunes dead tokens (UNREGISTERED / 410 / malformed).
- `backend/src/app.module.ts`: registered PushModule (Global scope).
- `backend/src/notifications/notifications.module.ts`: `NotificationsService.sendToUser` now fires `push.sendToUser(...)` after persisting + socket-emitting, so backgrounded/closed apps receive notifications.
- `app/customer_app/lib/services/push_service.dart` (new) and `app/admin_app/lib/services/push_service.dart` (new): added `PushRegistrar` that obtains native token via `MethodChannel('sarko/push')` and registers via `POST /v1/users/me/fcm-token`, handling OS token rotation; degrades gracefully (MissingPluginException) until native setup complete.
- `app/customer_app/lib/providers/auth_provider.dart` and `app/admin_app/lib/providers/admin_auth_provider.dart`: wired `PushService.register()` into login flow.
- `app/customer_app/lib/screens/splash_screen.dart` and `app/admin_app/lib/screens/splash_screen.dart`: wired `PushService.register()` into session-restore on app start.

*Phase 5 — Verification:*
- `app/customer_app/test/message_status_test.dart` (new): added 4 unit tests for `sendStatus` derivation covering sending/sent/read/failed states.

**Why:** Chat experience was broken — messages didn't load, sends showed no state, and backgrounded users missed notifications. These five phases implement a complete WhatsApp/Telegram-grade solution: reliable realtime delivery (phases 1–3), visible send state (phase 2), server-side push notifications (phase 4), and verification (phase 5). Self-healing sockets + lifecycle-driven joins fix the realtime + history loading gaps; send-state tracking with tap-retry gives users confidence; delta cursors ensure offline edits sync correctly; and HTTP v1 push (no SDK) restores background delivery without reintroducing Firebase.

**Verification:** 
- Backend: `tsc --noEmit` — 0 errors. 
- Customer app: `flutter analyze lib` — 0 errors/0 warnings (pre-existing deprecation infos only).
- Admin app: `flutter analyze lib` — 0 errors/0 warnings (pre-existing deprecation infos only).
- Unit tests: `message_status_test.dart` (4 tests) — all pass, plus existing smoke test.
- Not yet tested end-to-end: native push token acquisition, backend e2e run, on-device manual test matrix (needs provisioning of APNs .p8 key and FCM service-account JSON). Both are blocking items flagged in `plan.md` open items.

## 2026-07-22 14:00 — FCM native wiring: Android build setup and secrets config

**What changed:**

*Backend configuration:*
- `backend/.gitignore`: added exclusions for `secrets/`, `*firebase-adminsdk*.json`, and `google-services.json` to prevent accidental secrets commits.
- `backend/.env.example`: added `GOOGLE_APPLICATION_CREDENTIALS=./secrets/fcm-service-account.json` and `FCM_PROJECT_ID=sarko-site` with explanatory comments; APNs variables (APNS_KEY, APNS_KEY_ID, APNS_TEAM_ID, APNS_BUNDLE_ID, APNS_PRODUCTION) templated but commented out pending iOS setup.
- `backend/docker-compose.yml`: added read-only volume mount `./secrets:/app/secrets:ro` to the api service for FCM service-account key (local-dev only; prod uses PM2 with absolute path).

*Customer app (Android):*
- `app/customer_app/android/settings.gradle.kts`: added Firebase google-services plugin (com.google.gms.google-services v4.4.2).
- `app/customer_app/android/app/build.gradle.kts`: changed namespace to `com.sarko.site`, updated applicationId to match; added Google services plugin; added Firebase Cloud Messaging dependency (firebase-bom 33.7.0) with no Firebase Dart SDK.
- `app/customer_app/android/app/google-services.json`: added (Firebase project sarko-site, client com.sarko.site).
- `app/customer_app/android/app/src/main/kotlin/com/sarko/site/MainActivity.kt`: created new with native `sarko/push` MethodChannel bridging FirebaseMessaging.getToken() to Dart; added Android 13+ POST_NOTIFICATIONS permission request on app startup.

*Admin app (Android):*
- `app/admin_app/android/settings.gradle.kts`: added Firebase google-services plugin (com.google.gms.google-services v4.4.2).
- `app/admin_app/android/app/build.gradle.kts`: changed namespace to `com.sarko.site.admin`, updated applicationId; added Google services plugin; added Firebase Cloud Messaging dependency (firebase-bom 33.7.0).
- `app/admin_app/android/app/src/main/kotlin/com/sarko/site/admin/MainActivity.kt`: moved/updated with native `sarko/push` MethodChannel (same implementation as customer app); added Android 13+ POST_NOTIFICATIONS permission request.
- `app/admin_app/android/app/google-services.json`: received and staged (untracked; contains both com.sarko.site and com.sarko.site.admin clients from Firebase project sarko-site).

**Why:** Phases 1–5 implemented the Dart-level realtime chat and push interfaces, but native Android token acquisition and backend secret config were still pending. This follow-up wires the native FCM layer: both apps now obtain the device token via native Android code (FirebaseMessaging SDK), backend can authenticate to FCM for sending via the service-account JSON, and Dart calls over the `sarko/push` MethodChannel to get the token for registration. Secrets are properly gitignored and docker-compose mounts them safely for local dev. Old packages (com.sarkisbread.pl, com.example.admin_app) built and installed on device j7pbdiwg6tciae4h; debug APKs for both new packages built and installed.

**Verification:** 
- Git commit 3bd458c shows all Android configuration, plugin registration, and namespace migrations applied.
- Backend .env and docker-compose reflect FCM service-account setup; no actual secrets committed.
- Both apps' build files compile and gradle applies google-services plugin without errors.
- Customer and admin app MainActivitys successfully instantiate MethodChannel and request runtime permission.
- Old packages (com.sarkisbread.pl, com.example.admin_app) and new packages (com.sarko.site, com.sarko.site.admin) coexist on test device.
- APKs built as debug (test device j7pbdiwg6tciae4h).

*Remaining (prod deploy + verification):*
- Production VPS deployment: git pull, npm run build, pm2 restart with updated --update-env, scp service-account JSON to absolute GOOGLE_APPLICATION_CREDENTIALS path.
- Rotate the exposed FCM service-account key.
- iOS/APNs still unconfigured.
- End-to-end on-device push test pending prod backend availability (phone talks to https://api.sarko.site).
