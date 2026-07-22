# Realtime chat reliability + push (WhatsApp/Telegram-grade)

## Context

Chat is customer↔staff support (one `ChatTopic` per customer, `ChatTopic.id == User.id`). Backend: NestJS + Prisma + Socket.IO gateway. Clients: `customer_app` and `admin_app`, offline-first with Drift as the single source of truth, fed by socket events + REST `since=`/`after=` delta pulls + an optimistic mutation queue.

The design only works on the happy path immediately after login. Five reported symptoms trace to concrete gaps:

| Symptom | Root cause | Evidence |
|---|---|---|
| No notifications about new messages | Firebase removed (commit `aa63a93`); backend push deleted. `NotificationsService` only persists a row + emits a socket event — reaches **connected** clients only. | [notifications.module.ts:9](../../backend/src/notifications/notifications.module.ts#L9) |
| No real-time messaging | `chat:join` emitted **once** at login; socket auto-reconnects but nothing re-joins the `chat:<topicId>` room. Chat screen never joins on open. | [sync_engine.dart:37](../../app/customer_app/lib/sync/sync_engine.dart#L37), [socket_service.dart](../../app/customer_app/lib/realtime/socket_service.dart), [chats_screen.dart:91](../../app/customer_app/lib/screens/chats/chats_screen.dart#L91) |
| No history / messages not showing | History pulled only by `fullSync→syncMessages` at login; **every call site swallows errors** (`.catchError((_) {})`). Chat screen never re-pulls on open. | [auth_provider.dart:63](../../app/customer_app/lib/providers/auth_provider.dart#L63), [splash_screen.dart:96](../../app/customer_app/lib/screens/splash_screen.dart#L96) |
| New messages not sent | Connectivity-shaped failures queue silently; optimistic `local_…` row sits `pendingSync=true` with no visible state or retry. Combined with the realtime gap, no server echo returns. | [message_service.dart](../../app/customer_app/lib/services/message_service.dart), [mutation_queue.dart](../../app/customer_app/lib/sync/mutation_queue.dart) |
| (Smell) inverted order | `messagesStream` returns `createdAt DESC` but the list renders index 0→n as oldest→newest. | [message_service.dart](../../app/customer_app/lib/services/message_service.dart), [chats_screen.dart:117](../../app/customer_app/lib/screens/chats/chats_screen.dart#L117) |

Both apps share the same socket wiring (`setTransports(['websocket'])`, emit-once `joinChat`, separate `syncMessages(topicId)`), so every client-side fix applies to both — with the difference that admin/staff open **many** topics (must join/leave per open chat) while the customer only ever has their own.

## Decisions

| Concern | Choice | Why |
|---|---|---|
| Background delivery | **FCM HTTP v1 + APNs, sent server-side from NestJS; no Firebase client SDK** | Restores closed-app notifications (the only true fix) without reintroducing the removed `firebase_messaging` SDK. `Device.fcmToken` + `Device.platform` already exist in schema — push is storage-ready. |
| Room membership | **Self-healing** — re-join on every socket `connect`/reconnect, and join/leave driven by the chat screen lifecycle | Removes the single-point-in-time join that breaks after the first reconnect. |
| Sync trigger | **Screen-driven** — opening a chat always fires a `since=` catch-up + room join; never rely on login-time sync alone | A chat screen that opens must be able to fully recover state on its own. |
| Delta cursor | Switch the messages catch-up from `after=createdAt` to **`updatedAt`-based** | Server already bumps `Message.updatedAt` on edit/delete/react/read and indexes `(topicId, updatedAt)`; the current `createdAt` cursor misses those while offline. |
| Send state | Surface **queued → sent → delivered → read** with tap-to-retry on failed rows | WhatsApp-grade feedback; kills the "looks stuck" ambiguity. |
| Error handling | **Stop swallowing** sync errors; log + retry with backoff; show a refresh affordance when Drift is empty AND the last pull failed | Silent failures are why "no history" is invisible today. |

---

## Phase 1 — Client realtime + history recovery (no backend changes)

Highest leverage: fixes "no realtime", "no history", "messages not showing" for both apps.

### 1.1 Self-healing socket rooms
- `SocketService` (both apps): add `socket.on('connect', …)` that (a) re-emits `chat:join` for every currently-active topic, and (b) fires a `since=` catch-up pull. Track active topics in a `Set<String>` updated by `joinChat`/`leaveChat`.
- Keep `setTransports(['websocket'])` but add polling fallback (`['websocket','polling']`) so a proxy that won't upgrade still connects.
- `reconnectWithFreshToken` already rebuilds the socket — ensure the `connect` handler re-joins after token refresh too.

### 1.2 Chat screen owns its lifecycle
- `chats_screen.dart` (both apps) `initState`: `syncMessages(topicId)` (await, with error surfaced) + `SocketService.joinChat(topicId)`.
- `dispose`: `leaveChat(topicId)`.
- Admin app: do the same per-customer chat opened (it already has `syncMessages(topicId)`), so staff join only the rooms they're viewing.

### 1.3 Stop swallowing sync errors
- Replace `.catchError((_) {})` at [auth_provider.dart:63](../../app/customer_app/lib/providers/auth_provider.dart#L63)/`221`, [splash_screen.dart:96](../../app/customer_app/lib/screens/splash_screen.dart#L96) (+ admin equivalents) with logging + retry/backoff.
- Chat screen: when the stream is empty AND the last `syncMessages` failed, show a retry affordance instead of the bare `EmptyState`.

### 1.4 Fix list ordering
- Confirm intended order against admin app; make `messagesStream` ordering and the list index mapping consistent (newest at bottom). Fix whichever side is wrong; add a widget test.

**Exit criteria:** open chat cold → history loads; send while both online → appears live on the other side within ~1s; drop/restore network → next message still arrives live without reopening the app.

## Phase 2 — Send-state reliability

### 2.1 Delivery states
- Add a `status` concept to local messages (`queued|sent|delivered|read|failed`) derived from `pendingSync`, server echo, and read flags. Render ticks accordingly in `message_bubble.dart` (both apps).
### 2.2 Retry UX + queue hardening
- `MutationQueue.drain`: cap retries, expose failed mutations; tap-to-retry / delete on a failed bubble.
- Ensure the optimistic `local_…` row is reconciled by BOTH the POST response and a socket echo (dedupe by server id) so a message never appears twice or stays stuck.

**Exit criteria:** sending offline shows a clear "queued" state and auto-sends on reconnect; a server-rejected message shows "failed" with retry; no duplicate bubbles.

## Phase 3 — Delta cursor correctness

### 3.1 Backend
- `GET /messages/:topicId`: add an `updatedSince=<ISO>` param filtering `updatedAt: { gt }`, ordered by `updatedAt asc` (keep existing `after`/`createdAt` paging for scroll-back). Uses the existing `(topicId, updatedAt)` index.
### 3.2 Client
- `syncMessages` catch-up uses `updatedSince` keyed on the max `updatedAt` seen, so edits/deletes/reactions/read-state that changed while offline are reconciled — not just brand-new messages.

**Exit criteria:** edit/delete/react to a message while the recipient is offline → it reconciles on their reconnect.

## Phase 4 — Push (FCM HTTP v1 + APNs, no Firebase SDK)

### 4.1 Backend push service
- New `PushService`: send via **FCM HTTP v1** (OAuth2 service-account, `googleapis`/`google-auth-library`) for Android tokens and **APNs** (`node-apn` or HTTP/2 + JWT `.p8`) for iOS tokens. Config via env (service-account JSON, APNs key id/team id/bundle id).
- Wire into `NotificationsService.sendToUser`: after persisting + socket-emit, look up the user's `Device` rows and push to each `fcmToken`/APNs token. Chat pushes carry `{ type:'chat', topicId }` so a tap deep-links to the chat.
- Prune dead tokens on `NotFound`/`Unregistered` responses.
### 4.2 Client token registration (no firebase_messaging)
- Android: register for FCM tokens via a lightweight path (sender-id / `google-services` config for token retrieval only — no messaging SDK surface). iOS: request APNs authorization, capture device token.
- Send token → existing device-registration endpoint to populate `Device.fcmToken`/`platform`. Refresh on rotation.
- Foreground: rely on the socket (no OS banner needed). Background/killed: OS delivers the push; tap → deep-link to chat and trigger a `since=` catch-up.

**Exit criteria:** app fully closed, staff replies → customer device shows an OS notification; tapping opens the chat with the new message loaded.

## Phase 5 — Verification

- Widget/unit tests: ordering, dedupe reconciliation, send-state transitions, mutation-queue retry cap.
- Manual matrix (both apps): cold open, live send both directions, reconnect mid-session, offline send + drain, edit/delete offline, closed-app push. Record results in `changes.md`.

---

## Sequencing / risk

- **Phase 1 first** — resolves 3 of 5 symptoms, client-only, low risk, immediately testable.
- **Phase 2–3** — reliability + correctness; Phase 3 needs a small backend param + no migration (uses existing `updatedAt`/index).
- **Phase 4 last** — highest infra cost (service-account + APNs cert plumbing, platform config); isolated so it can't block the realtime fixes.

## Open items
- APNs credentials (`.p8` key, team id, bundle id) and an FCM service-account JSON must be provisioned by the user before Phase 4 can be tested end-to-end.
- Confirm the intended message list order against the admin app (Phase 1.4) before editing.
