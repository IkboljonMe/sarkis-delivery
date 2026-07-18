# Changes Log

## 2026-07-17 14:30 — Fixed compile errors, auth flow bugs, and Firebase cleanup

**What changed:**

- **Drift schema & message service** (`app/customer_app/lib/services/message_service.dart`, `app/customer_app/lib/local_db/app_database.dart`, `app/customer_app/lib/sync/sync_engine.dart`): Rewrote message schema to use flat columns (textContent, replyToId, replyToText, replyToSender, mediaUrl, mediaUrlsJson, durationMs, orderId, waveformJson, sizeBytes, uploading, uploadCount, reactionsJson) replacing the old content+extraJson pair. Updated SyncEngine to write these columns and mapped `deleted` through to the MessageModel. Fixed deleteMessage to set the flag rather than type.
- **Auth provider imports** (`app/customer_app/lib/providers/auth_provider.dart`): Moved stray `import 'package:flutter/widgets.dart';` from middle of file to top (directive_after_declaration error).
- **Cart provider** (`app/customer_app/lib/providers/cart_provider.dart`): Fixed CouponModel construction missing required `code` argument; removed unused dart:convert import.
- **Admin auth provider** (`app/admin_app/lib/providers/admin_auth_provider.dart`): Removed unused mutation_queue import.
- **Auth flow logic** (`app/customer_app/lib/providers/auth_provider.dart`): Fixed loadCurrentUser() falling back to null on any syncProfile() error (routing valid users to /register). Now: 401 → session dead; others → cached Drift row. Also wrapped FCM init so push registration can't block login. Fixed verifyOtp() that awaited SyncEngine.fullSync() inline (single endpoint failure made login look failed) — now runs in background.
- **Firebase constants cleanup** (both apps): Removed dead AppConstants.adminUid ('HjygD2zQpKZ0zakT0JZWFvc3GcA3') from customer_app and its usage in post-order "thank you" messages; sender name 'Sarkis' removed and message now sent as customer. Removed unused adminUid param from sendWelcomeIfNew in message_service (both apps).
- **Privacy text** (`app/customer_app/lib/l10n/app_strings.dart`, `app/admin_app/lib/l10n/app_strings.dart`): Updated all 5 languages (EN/RU/DE/TR/HY) to say data is "on our servers" instead of "stored securely in Firebase".
- **Settings screen** (both apps): Replaced "Firebase: <project-id>" info row with "API server: <apiBaseUrl>"; renamed l10n key setFirebase→setApi; removed firebaseProjectId getter and demo_firebase_options import from utils/constants.dart.
- **Stale comments**: Reworded Firestore-era comments (api_client.poll, group_provider, region_group_model).
- **Dev dependencies** (`backend/package.json`): Moved socket.io-client from dependencies to devDependencies (used only by test_ws.mjs).
- **Deleted** (`app/admin_app/fix.py`, `app/admin_app/fix_final.py`): Removed other agent's throwaway patch scripts.

**Why:** The other agent's Drift wiring had compile errors that blocked the build. Real bugs in the new offline-first auth flow (e.g., syncProfile errors routing users to /register) would defeat offline-first design. Firebase era constants and comments were stale now that the backend is Node/Postgres. Cleaning these up ensures the codebase accurately reflects the current architecture.

**Verification:** `flutter analyze` on both apps: 0 errors, 0 warnings (only pre-existing style infos). Drift codegen clean for both. Backend `npx tsc --noEmit` clean. No emulator was run per user instruction. Frontend (landing + shop) built and smoke-tested separately in the landing-redesign-and-shop-webapp folder.
