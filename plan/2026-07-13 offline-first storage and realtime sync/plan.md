# Offline-first local storage + real-time sync for customer_app & admin_app

## Context

The backend moved from Firebase to NestJS/Prisma/Postgres. Both Flutter apps still behave like a half-finished migration:

- **Session tokens are stored in plaintext `SharedPreferences`** (`api_access`/`api_refresh`/`api_user` in both apps' `services/api_client.dart`) — no encryption at rest.
- **No local database exists in either app.** Zero `sqflite`/Drift/Isar/Hive usage anywhere.
- **"Real-time" is actually polling.** `ApiClient.poll()` (customer: `app/customer_app/lib/services/api_client.dart:184-195`, admin: same shape in `app/admin_app/lib/services/api_client.dart`) is a comment-labelled "Firestore-like stream" that just re-fetches on a timer — 3s for chat, 8-10s for orders, 15-30s for everything else — in **both** apps. No websocket exists in the backend either.
- **Every screen re-polls independently** with no shared cache (e.g. `home_screen.dart` and `my_orders_screen.dart` both hit `GET /orders/mine` on their own timers), so navigating the app re-triggers network round-trips and loading spinners constantly, and there is **zero offline behavior** — any request while offline throws and the screen shows empty/error state.
- **No offline write queue** — placing an order, sending a chat message, or updating an order status all fail hard if the network blips; nothing is queued for retry.
- **Notifications aren't persisted anywhere** (client or server) — FCM messages are ephemeral OS-tray pop-ups only, with no in-app history.

Goal: give both apps a local SQLite-backed cache that's the single source of truth for the UI, populated once at login and kept live via a WebSocket connection (with FCM as the background wake signal and REST delta-sync as the reconciliation layer), with secure token storage and an offline write queue for the actions users take without connectivity.

**Decided scope** (per user):
- Real-time transport: **WebSocket (Socket.IO gateway on NestJS) + FCM hybrid** — build the socket layer, not polling-only.
- Driver app: **storage/session/sync only** — do NOT add driver-role features (assigned-orders view, accept/reject, location tracking, proof-of-delivery, availability toggle). Apply the same architecture to the app exactly as it exists today (shared admin/driver screens).

---

## Architecture decisions

| Concern | Choice | Why |
|---|---|---|
| Local DB | **Drift** (`drift` + `sqlite3_flutter_libs`, codegen via `build_runner`) over raw `sqflite` | Type-safe queries, schema migrations, and — critically — **reactive `.watch()` streams**: writing to a table auto-notifies every open `StreamBuilder` watching it. This directly replaces `ApiClient.poll()` and kills the redundant-fetch problem, since all screens read the same local cache instead of hitting the network themselves. |
| Token storage | **`flutter_secure_storage`** | Replaces plaintext `SharedPreferences` token storage in both `api_client.dart` files (Keychain/Keystore-backed). |
| User profile cache | Drift `local_user` single-row table | Replaces the `api_user` JSON blob in prefs; consistent with everything else being queryable/reactive. |
| Real-time transport | **NestJS `@WebSocketGateway` (Socket.IO)**, JWT auth on handshake, rooms per user/topic/role | Only real-time infra that exists today is one-way FCM. Socket.IO is the standard NestJS-native choice, has a mature Flutter client (`socket_io_client`), and supports auth + rooms out of the box. Single backend instance today (docker-compose has one `api` container, no Redis) — an adapter for horizontal scaling is explicitly **not** needed now; flag as future work if the backend is ever scaled beyond one instance. |
| Background wake | **Keep FCM**, narrow its job to (a) OS-tray alert when app is backgrounded/killed, (b) a data payload that triggers a delta-sync pull on next foreground/tap. Sockets handle live updates while the app is open. | Reuses the FCM plumbing that already works in both apps; avoids needing background-isolate socket connections, which are unreliable on Android/iOS. |
| Reconciliation | REST **delta sync** (`?since=<ISO updatedAt>`), modeled on the one pattern that already exists (`GET /messages/:topicId?after=`) | Sockets can drop messages (reconnect gaps, backgrounded app). Every domain sync in this plan does an initial full pull at login, then trusts socket events live, and falls back to a `since` pull on reconnect/resume as a safety net. |
| Offline writes | Local `pending_mutations` Drift table + `connectivity_plus` listener | Writes (place order, send message, update profile, order status) go to REST immediately; on failure due to connectivity they're queued and optimistically written locally with a `pendingSync` flag, then drained FIFO on reconnect. |

---

## Phase 0 — Shared foundation

### 0.1 Backend: WebSocket gateway

New `backend/src/realtime/realtime.gateway.ts` (+ module), using `@nestjs/websockets` + `@nestjs/platform-socket.io` (new deps — not currently installed). Handshake auth: verify the same JWT used for REST (reuse `JwtService`/the logic in `common/guards.ts`) from the socket `auth` payload; disconnect on invalid/expired token. On connect, join rooms:
- `user:<userId>` — personal channel (own orders, own notifications, own chat topic).
- `staff` — all ADMIN/DRIVER/SUPERADMIN connections (new-order alerts, topic-list changes, any-order updates — mirrors what staff already poll today).
- `chat:<topicId>` — joined on-demand when a chat screen is open (emit/leave on screen enter/exit) — keeps message fan-out scoped.

Emit events from existing services at their existing write points (no new business logic, just adding an emit next to each place a push notification is already sent):
- `orders.service.ts` (create/update/assign/status-change) → `order:created` / `order:updated` to `user:<customerId>` and `staff`.
- `messages` module (send/edit/delete/react/read) → `message:created` / `message:updated` / `message:deleted` / `message:reaction` to `chat:<topicId>` and `staff` (for topic-list badge updates).
- New `notifications` writes (0.3 below) → `notification:created` to `user:<userId>`.

### 0.2 Backend: delta-sync cursors

Add `?since=<ISO>` query param (filtering `updatedAt: { gt: since }`, same shape as the existing `messages` `after` param) to: `GET /orders/mine`, `GET /driver/orders`, `GET /admin/orders`, `GET /products`, `GET /categories`, `GET /admin/coupons` (or public `/coupons` if customer needs it), `GET /shifts`, `GET /zones`.

Prisma migration: add `updatedAt @updatedAt` to `Category`, `Coupon`, `Shift`, `Message` (currently missing — `Message` only has `editedAt`, which isn't queryable for edit/delete/reaction deltas today). Bump `schema.prisma`, run `prisma migrate dev`.

### 0.3 Backend: persisted notifications

New Prisma model `Notification` (id, userId, type: order|chat|system, title, body, data Json, orderId?, topicId?, readAt?, createdAt). New `notifications` module: `GET /notifications?since=`, `POST /notifications/:id/read`. Write a row at every point the backend currently fires an FCM push (`notifications/notifications.service.ts` call sites: new order, order status change, driver assignment, new chat message, approval decision) — alongside the existing FCM send and the new socket emit from 0.1. This is what seeds the client-side notification inbox (customer app currently has none at all).

### 0.4 Client: shared package additions (both apps' `pubspec.yaml`)

```
drift, sqlite3_flutter_libs          # local DB
flutter_secure_storage               # token storage
socket_io_client                     # realtime
connectivity_plus                    # offline-write-queue triggering
# dev: drift_dev, build_runner
```

### 0.5 Client: shared architecture pieces (same shape in both apps, separate schemas)

- `lib/local_db/app_database.dart` — Drift `AppDatabase`, tables mirroring the server models each app actually needs (see per-app breakdown below), plus local-only tables `pending_mutations` (id, entityType, payload JSON, createdAt, retryCount, lastError) and `sync_cursors` (table name → last `since` watermark).
- `lib/session/secure_session_store.dart` — wraps `flutter_secure_storage` for `accessToken`/`refreshToken`; `ApiClient` (`api_client.dart` in both apps) is edited to read/write through this instead of `SharedPreferences` directly (its HTTP-verb/refresh-retry logic at lines 91-128 stays as-is).
- `lib/realtime/socket_service.dart` — connects with the current access token on login/app-resume, exponential-backoff reconnect, disconnects on logout/background-after-grace-period; exposes a stream of typed domain events.
- `lib/sync/sync_engine.dart` — subscribes to `SocketService` events and upserts rows straight into Drift; on login, reconnect, or FCM-triggered wake, calls the relevant `since=` endpoint per table and upserts + advances `sync_cursors`. Owns full wipe-on-logout.
- `lib/sync/mutation_queue.dart` — wraps offline-sensitive writes: try REST now; on connectivity failure, write optimistically to Drift with `pendingSync=true` and enqueue in `pending_mutations`; a `connectivity_plus` listener drains the queue FIFO with retry/backoff on reconnect.

Providers currently wrapping `ApiClient.poll()` streams (`order_provider.dart`, `message_provider.dart`, and the product/shift/coupon/etc. services' `*Stream()` methods in both apps) are rewired to instead expose Drift `.watch()` queries — screens don't change their `StreamBuilder` usage pattern, only what stream they're handed.

---

## Phase 1 — customer_app, feature by feature

Build/land in this order (each is independently shippable and testable):

**1. Auth/session** — `screens/auth/*`, `providers/auth_provider.dart`, `services/auth_service.dart`, `services/api_client.dart`. Move tokens to `SecureSessionStore`. Login success triggers `SyncEngine` initial pull (profile, recent orders, chat topic, categories/products) + `SocketService.connect()`. Logout: disconnect socket, wipe Drift, clear secure storage. Also persist the in-memory-only `RegistrationDraft` (`auth_provider.dart`) to Drift so a killed app mid-registration doesn't lose progress.

**2. Catalog (categories/products)** — `services/product_service.dart`, `screens/products/*`, `screens/home/home_screen.dart`. Drift `categories`/`products` tables. Low change frequency — no dedicated socket event needed initially; sync on login + app-foreground + pull-to-refresh via `since=`. Screens read `db.watchCategories()`/`watchProducts()` instead of the 60s poll.

**3. Cart** — `providers/cart_provider.dart`, `screens/cart/*`. Move off partial `SharedPreferences` JSON (which currently loses shift/coupon selection on restart, per research) to a Drift `cart_items` table (+ selected shift/coupon fields) — fixes that bug as a side effect of the migration.

**4. Place / edit order** — `cart_provider.dart` (`placeOrder`), `services/order_service.dart`. Goes through `MutationQueue`: optimistic local `orders` row (status `pending`, `pendingSync=true`) written immediately so `order_success_screen` / order list reflect it even if the POST hasn't confirmed yet; reconciled to the server row once the request succeeds (or retried on reconnect if it was queued offline).

**5. Track order status / order history** — `screens/orders/*`, `providers/order_provider.dart`, `services/order_service.dart`. Drift `orders`, `order_items`, `order_events` tables. Socket `order:updated` events upsert directly; `order:created`/reconnect does a `since=` pull. `home_screen`'s active-order banner and `my_orders_screen`'s list both read the same `db.watchUserOrders()` — kills the current redundant double-poll.

**6. Chat** — `screens/chats/chats_screen.dart`, `providers/message_provider.dart`, `services/message_service.dart`. Drift `chat_topics`, `messages` tables. Join `chat:<topicId>` room on screen open, leave on close; `message:*` socket events upsert/delete rows live (no more full-list-rebuild-per-poll). Sends go through `MutationQueue` (optimistic message row with `pendingSync`, retried if offline). Media (images/voice) cached to local file storage with the path referenced from the Drift row so previously-viewed media works offline.

**7. Notifications** — new: `services/fcm_service.dart` gets a data-payload handler that (a) shows the tray notification as today via `local_notifications.dart`, (b) upserts into a new Drift `notifications` table from the payload or a `since=` pull of the new `GET /notifications` endpoint. Add a simple in-app notifications list screen (currently doesn't exist) backed by `db.watchNotifications()`, with `POST /notifications/:id/read` on open. This is new UI surface but a small one — flag as an easy add given the backend/client plumbing is already built for orders/chat.

**8. Profile / addresses / language** — `screens/profile/*`, `providers/auth_provider.dart`, `services/user_service.dart`. Drift `local_user` row kept in sync via `GET /users/me` on login/resume + `PATCH` through `MutationQueue` for edits (some fields route through the existing `Approval` workflow server-side — no change to that logic, just where the pending state is displayed from). `locale_provider.dart`'s `SharedPreferences` usage is fine as-is (pure UI pref, not sync-relevant).

**9. Coupons / shifts / zones** — `services/coupon_service.dart`, `services/shift_service.dart`, `services/region_group_service.dart`. Drift cache tables, `since=`-based refresh on login/foreground (no socket event needed — low-frequency admin-edited data).

---

## Phase 2 — admin_app (driver), feature by feature

Same architecture pattern, applied to the app **as it exists today** (no new driver-role screens/flows, per decided scope). Build order:

**1. Auth/session** — `screens/auth/login_screen.dart`, `providers/admin_auth_provider.dart`, `services/api_client.dart`. Same `SecureSessionStore` move as customer app. `admin_remember`/`admin_email` stay in `SharedPreferences` (pure UI convenience, not sensitive/sync data).

**2. Orders (list/detail/status-change)** — `screens/orders/*`, `services/order_service.dart`. This is the app's core screen and highest-poll-frequency feature (8-10s today). Drift `orders`/`order_items`/`order_events` tables shared shape with customer app's but scoped to "all orders in the staff member's group" instead of "my orders". `staff` room socket events (`order:created`/`order:updated`) upsert live — this is the single biggest UX win for this app, since new-order alerts currently only appear on the next poll tick. Status-change writes go through `MutationQueue`.

**3. Chat** — `screens/chats/chats_screen.dart`, `screens/chats/chat_detail_screen.dart`, `services/message_service.dart`. Same Drift `chat_topics`/`messages` tables and socket wiring as customer app step 6, plus the `staff` room for topic-list live updates (new-message badges across all customer conversations, not just one open thread).

**4. Dashboard** — `screens/dashboard/dashboard_screen.dart`. Reads derived from the same Drift `orders` table (counts/aggregates via Drift queries) instead of its own separate poll — no new sync needed, just a query rewrite.

**5. Approvals** — `screens/approvals/approvals_screen.dart`, `services/approval_service.dart`. Drift `approvals` table, `staff` room socket event on new/resolved approval (add this emit point alongside 0.1), replacing the 15s poll.

**6. Products/categories, coupons, shifts, groups (zones)** — `screens/products/*`, `screens/coupons/*`, `screens/shifts/*`, `screens/groups/*`. Same low-frequency Drift-cache-plus-`since=`-refresh treatment as customer app step 9 (these are the tables staff *edit*, so writes go through `MutationQueue` too, and a successful write should immediately upsert Drift so the editing admin sees their own change instantly rather than waiting for the socket echo).

**7. Reports** — `screens/reports/reports_screen.dart`, `utils/reports_aggregator.dart`. Purely derived from the local `orders` Drift table — no separate sync needed once orders are cached locally; this also makes reports work offline for already-synced date ranges.

**8. Settings** — `screens/settings/settings_screen.dart`, `services/settings_service.dart`. Single-row Drift `settings` cache, refresh on login/foreground (rarely changes, no socket event needed).

**9. Notifications** — mirrors customer app step 7 (new `notifications` Drift table + list screen), scoped to whatever the backend sends staff (new order, new message, approval created).

---

## Explicit non-goals (per decided scope)

- No driver-only assigned-orders/accept-reject flow, no availability toggle, no location tracking, no proof-of-delivery capture — `assignDriver()` stays unused/dead code as today, `Order.driverId` stays unexposed in the Flutter `OrderModel`.
- No in-app turn-by-turn navigation (existing Google Maps hand-off in `navigation_service.dart` untouched).
- No Redis/horizontal-scaling work for the socket gateway — single-instance is fine given the current single `api` container.
- Not fixing the admin/driver role-conflation in the UI (same 11-screen drawer for everyone) — out of scope per the storage/sync framing.

---

## Verification

- Backend: each new/modified endpoint gets a request against a running `docker-compose` Postgres via existing test patterns (check `backend/test` or `backend/src/**/*.spec.ts` for the project's existing convention before adding new specs); manually exercise the socket gateway with a throwaway `socket.io-client` script (connect, join room, assert an emitted event on e.g. a status-change PATCH).
- Client: after each numbered feature above, run the app (`/run` skill) against the local backend, toggle airplane mode mid-session to confirm optimistic writes queue and drain correctly, and confirm the relevant screen updates within ~1s of a server-side change made from another client/session (proving the socket path, not just the fallback poll).
- Regression check per phase: confirm the feature still works with the backend socket gateway killed (client should fall back to `since=` pull on next resume) — this is the safety net and must not silently break.
