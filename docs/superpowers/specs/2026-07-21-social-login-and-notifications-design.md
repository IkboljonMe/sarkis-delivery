# Google/Apple Sign-In, Session Verification, and Notification Inbox

**Date:** 2026-07-21
**Status:** Approved for planning

## Context

Prior session removed Firebase Cloud Messaging and rewired local notification display onto the existing Socket.IO `notification:created` event. That work surfaced that the backend already carries substantial infrastructure that this feature builds directly on:

- **Auth/session**: `backend/src/auth/` already implements phone-OTP, email/password, and Google login, all going through a shared `finishLogin()` that issues a short-lived JWT access token plus a rotating, per-device refresh token (theft detection via token-family revocation), records `LoginEvent`s, and upserts a `Device` row. `POST /auth/logout` supports single-device or all-devices revocation. Both apps' `ApiClient` already does secure token storage, header injection, and silent refresh-on-401.
- **Notifications data layer**: `backend/src/notifications-inbox/` already exposes `GET /notifications` (delta sync via `?since=`) and `POST /notifications/:id/read`. Both apps already sync this into a local Drift `NotificationRows` table (`SyncEngine.syncNotifications()`) and receive live updates over `SocketService` (`notification:created`). What's missing is entirely UI: no screen renders this table, and mark-as-read is never called from either app.
- **Google Sign-In**: `POST /auth/google` already exists server-side (verifies an ID token via `google-auth-library` against `GOOGLE_CLIENT_IDS`, throws a clean 503 if unconfigured). Nothing calls it from either app yet.
- **Apple Sign-In**: does not exist anywhere — no endpoint, no `appleId` on `User`, no app-side package.

This spec covers four independent-but-related pieces of work, scoped down from the original ask through user Q&A:

1. Google Sign-In — customer_app only, full stack (app UI wired to the existing backend endpoint).
2. Apple Sign-In — customer_app only, iOS-gated, full stack including new backend endpoint + migration.
3. Session management — **verification only**, both apps. No new UI. Confirm the existing login-persistence / silent-refresh / logout-clears-everything flow is correct; fix what isn't; add test coverage where thin.
4. Notification inbox — **new UI only**, both apps. The sync/data/backend layer already exists; build the screen, the mark-read call, and an unread-badge bell icon.

All new external credentials (Google OAuth client IDs, Apple key material) are left as empty placeholders with `// TODO` markers — the user will supply real values later. Code must handle "not configured" gracefully (the backend's Google path already does this pattern; Apple's new endpoint and both apps' buttons must follow the same convention: fail with a clear message, never crash).

## A. Google Sign-In (customer_app)

**Package:** `google_sign_in` (latest stable compatible with the app's Flutter/Dart SDK floor).

**New file:** `lib/services/google_auth_service.dart` — thin wrapper: `Future<String?> signIn()` returns an ID token or `null` on cancel/failure, `Future<void> signOut()` for the native-side sign-out (called from `AuthProvider.signOut()` so a re-login doesn't silently reuse a cached Google account).

**`AuthService`** (`lib/services/auth_service.dart`): add `Future<Map<String, dynamic>> googleLogin(String idToken)` — `POST /auth/google` with `{ idToken }`, same response shape as OTP/email login (`{ user, accessToken, refreshToken, isNewUser }`).

**`AuthProvider`**: add `Future<bool> signInWithGoogle()` following the exact shape of `verifyOtp()` — calls `GoogleAuthService.instance.signIn()`, on null token return `false` silently (user cancelled, not an error), on token call `AuthService.googleLogin`, save session via `ApiClient.saveSession`, set `_isNewUser`, kick off `SyncEngine.fullSync`/`start`, call `loadCurrentUser()`. Errors surface through the existing `_error`/`AuthStatus.error` fields — no new error-handling pattern needed.

**UI**: `WelcomeScreen` gets a "Continue with Google" button below the existing Register/Login buttons, separated by a divider ("or"). On success: if `isNewUser`, route to `/register` (profile completion, same as a new OTP user); else route to `/main`. Button shows a spinner tied to `AuthProvider.busy` like the other auth actions.

**Config (left empty, TODO-marked):**
- `backend/.env` / `.env.example`: `GOOGLE_CLIENT_IDS=` (already exists, already empty — no change needed, just confirm the comment explains it's a comma-separated list of allowed audiences: web/iOS/Android client IDs).
- `app/customer_app/android/app/build.gradle.kts`: no code change needed for `google_sign_in` (it doesn't require the Google Services Gradle plugin for basic ID-token sign-in); note in a comment that the Android OAuth client's SHA-1 must be registered in Google Cloud Console before this works.
- `app/customer_app/ios/Runner/Info.plist`: add a `CFBundleURLTypes` entry with a placeholder reversed-client-id `TODO-REPLACE-WITH-REVERSED-IOS-CLIENT-ID`, commented.
- `app/customer_app/.env` / `.env.example`: `GOOGLE_IOS_CLIENT_ID=` / `GOOGLE_SERVER_CLIENT_ID=` placeholders (server/web client ID is what the backend's `GOOGLE_CLIENT_IDS` must include; iOS client ID configures native `google_sign_in` itself).

**Error handling:** network/timeout errors bubble through the same `ApiException` path as every other `ApiClient` call. Google SDK errors (e.g. play-services missing, native config missing/placeholder) are caught in `GoogleAuthService.signIn()` and surfaced as a user-facing "Google sign-in isn't available right now" rather than a raw plugin exception.

**Testing:** unit test for `AuthProvider.signInWithGoogle()` covering: cancelled sign-in (returns false, no state change), successful new-user path (isNewUser true, routes correctly), successful existing-user path, backend rejection (invalid/expired token → error state). `GoogleAuthService` is mocked/injected so no real native call happens in tests.

## B. Apple Sign-In (customer_app + backend)

**Backend — schema:** add `appleId String? @unique` to `User` in `backend/prisma/schema.prisma`. New migration via `npx prisma migrate dev --name add_apple_id`.

**Backend — DTO:** `AppleLoginDto { @IsString() @IsNotEmpty() identityToken: string; @IsOptional() @IsString() fullName?: string; }` in `backend/src/auth/dto.ts`. (`fullName` because Apple only ever sends the user's name on the *first* authorization — the app must capture and forward it that one time, same as `payload.given_name` from Google.)

**Backend — service:** `AuthService.appleLogin(identityToken, fullName, client)` in `auth.service.ts`, mirroring `googleLogin()`:
- Verify `identityToken` as a JWT against Apple's public JWKS (`https://appleid.apple.com/auth/keys`), checking `iss === 'https://appleid.apple.com'` and `aud` against a configured `APPLE_CLIENT_ID` (the app's bundle ID / Services ID). Implementation choice deferred to the plan step: either the `apple-signin-auth` npm package or a manual `jwks-rsa` + `jsonwebtoken` verify — pick whichever has fewer transitive deps at implementation time, document the choice in the plan.
- No client secret needed for this verification-only flow (no server-to-Apple token exchange), so no Team ID / Key ID / private key required. If `APPLE_CLIENT_ID` is unset, throw the same `ServiceUnavailableException('Apple sign-in not configured')` pattern as Google.
- Payload's `sub` is the stable Apple user ID → same find-by-appleId-or-email-then-link-then-create flow as Google, using `fullName` (first login only) in place of `given_name`/`family_name`.
- Route through the same `finishLogin()`.

**Backend — controller:** `POST /auth/apple` in `auth.controller.ts`, `@Public()`, same throttle tier as `/auth/google`.

**App — package:** `sign_in_with_apple`.

**App — new file:** `lib/services/apple_auth_service.dart` — `Future<AppleAuthResult?> signIn()` wrapping `SignInWithApple.getAppleIDCredential(...)`, returning identity token + optional full name (only present on first auth), `null` on cancel.

**App — `AuthService`/`AuthProvider`**: `appleLogin(identityToken, fullName)` / `signInWithApple()`, same shape as the Google methods above.

**UI**: "Continue with Apple" button on `WelcomeScreen`, rendered only when `Platform.isIOS` (both because it's meaningless on Android and because Apple's guideline requiring parity only applies on iOS). Placed above or below the Google button — visual ordering decided during implementation to match platform convention (Apple's HIG generally wants their button most prominent on iOS).

**Config (left empty, TODO-marked):** `backend/.env`/`.env.example`: `APPLE_CLIENT_ID=` with a comment explaining it's the Services ID / bundle ID used as the JWT audience.

**Error handling:** same pattern as Google — plugin errors caught and surfaced as a friendly message, backend verification failures return 401 through the existing `ApiException` path.

**Testing:** backend unit tests for `appleLogin` covering invalid signature, wrong audience, wrong issuer, valid-token-new-user, valid-token-existing-user-link-by-email, valid-token-existing-appleId (mock the JWKS fetch/verify). App-side `AuthProvider.signInWithApple()` tests mirroring the Google ones.

## C. Session management — verification pass (no new UI)

Audit, on both apps:

1. `ApiClient.init()` is awaited before the first route decision in `main.dart` (already true for both — confirm no regression).
2. Silent refresh actually recovers a session: write an integration-style test that expires/invalidates the in-memory access token and confirms `ApiClient._send()` transparently refreshes and retries exactly once (not an infinite loop — `canRetry` already guards this, add a test proving it).
3. `AuthProvider.signOut()` / `deleteAccount()` (customer_app) and their `AdminAuthProvider` equivalent (admin_app) fully clear: secure-stored tokens, in-memory `currentUser`, all Drift tables (`wipeAll()`), and stop `SyncEngine`/disconnect `SocketService`. Confirm `SocketService.disconnect()` is actually called on logout on both apps (grep first — this may currently be missing, in which case it's a real bug fix, not just verification).
4. Refresh-token reuse-detection (family revocation) is exercised by at least one backend test: use a rotated/stale refresh token twice, confirm the second use gets rejected and the whole family is revoked (check `test/api.e2e-spec.ts` for existing coverage first; add if missing).

Any bug found during this audit gets fixed as part of this work, scoped tightly to what's broken — this section is explicitly not a redesign.

## D. Notification inbox (both apps)

**No backend changes** — `GET /notifications` and `POST /notifications/:id/read` already exist and work.

**New file per app:** `lib/services/notification_service.dart` — `Future<void> markRead(String id)` calling `POST /v1/notifications/:id/read`, then updating the local Drift row's `read` column optimistically (consistent with how other mutations in this codebase update local state immediately and let `SyncEngine`'s next pull reconcile).

**New screen per app:** `lib/screens/notifications/notifications_screen.dart` — a `StreamBuilder`/Drift-watch list of `NotificationRows` ordered by `createdAt desc`, each row showing title, body (truncated), relative timestamp, and an unread visual treatment (dot/bold, consistent with each app's existing chat-unread styling). Tapping a row: calls `markRead`, then routes using the same `type`/`topicId`/`orderId` → screen logic `routeNotification()` already uses for tapped tray notifications (reuse that function rather than duplicating the switch).

**Unread badge + entry point:**
- customer_app: bell `IconButton` in `HomeScreen`'s `AppBar`, badge = a Drift `count(where: read = false)` watch query, pushes `NotificationsScreen`.
- admin_app: same bell in `MainScaffold`'s `AppBar`, plus a "Notifications" entry in the existing `NavigationDrawer` list (alongside Dashboard/Orders/etc.), both driving to the same screen. Badge count shown on both the bell and (if the drawer supports trailing widgets already, matched to existing style) the drawer entry.
- Badge updates live: already-open `SocketService.events` subscription (added during the Firebase-removal work) triggers a re-render; no new socket wiring needed, just make sure the badge's data source (Drift watch) picks up the `_upsertNotification` write that subscription already performs.

**l10n:** new keys per app (`notifications`, `noNotifications`, `markAllRead` if a "mark all read" affordance is added — decided as a small nice-to-have during implementation, not required) across all 5 languages (EN/RU/DE/TR/HY) in `app_*.arb` / `AppLocalizations`/`AdminLocalizations`.

**Testing:** widget test for `NotificationsScreen` (empty state, populated list, tap-marks-read-and-navigates), and a unit test for the unread-count query against a seeded in-memory Drift DB.

## Out of scope (explicitly, per this spec)

- No "active sessions / manage devices" screen (user chose verification-only for session management).
- No Google/Apple credentials are actually provisioned — buttons and endpoints exist but return "not configured" until the user supplies real client IDs/keys.
- No changes to Android `applicationId`, deployed URLs, or other items already flagged out-of-scope in the prior Firebase-cleanup session.
- Apple Sign-In is not added to admin_app (staff use email/password by design — not part of this request).
