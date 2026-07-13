# Changes Log

## 2026-07-13 10:24 — Phase 0: WebSocket gateway, local database schema, and sync foundation

**What changed:**

**Backend:**
- Added NestJS WebSocket gateway (`backend/src/realtime/realtime.gateway.ts`, `realtime.module.ts`) with Socket.IO, JWT-authenticated handshake, three room types: `user:<id>` (personal), `staff` (ADMIN/SUPERADMIN only), `chat:<topicId>` (on-demand join/leave)
- Integrated domain events into existing services (`backend/src/orders/orders.service.ts`, `backend/src/messages/messages.module.ts`, `backend/src/approvals/approvals.module.ts`) — emitting `order:*`, `message:*`, `topic:updated`, `approval:*` events to appropriate rooms
- `NotificationsService` (`backend/src/notifications/notifications.module.ts`) now persists `Notification` rows and emits `notification:created` event alongside FCM sends
- New REST endpoints: `GET /v1/notifications?since=`, `POST /v1/notifications/:id/read` (`backend/src/notifications-inbox/notifications-inbox.module.ts`)
- Added `?since=<ISO updatedAt>` delta-sync query params to `GET /orders/mine`, `GET /driver/orders`, `GET /admin/orders`, `GET /categories`, `GET /products`, `GET /admin/coupons`, `GET /shifts`, `GET /zones` (`backend/src/catalog/catalog.controller.ts`, `catalog.service.ts`, `orders.controller.ts`, and others)
- Updated response DTOs to include `updatedAt` field for catalog/product/coupon/shift entities
- Prisma schema (`backend/prisma/schema.prisma`): added `updatedAt @updatedAt` to `Category`, `Coupon`, `Shift`, `Message`; new `Notification` model with userId, type, title, body, data, orderId, topicId, readAt, createdAt fields
- New dependencies: `@nestjs/websockets`, `@nestjs/platform-socket.io`, `socket.io` (added to `backend/package.json`)
- Verified: `npx tsc --noEmit` clean, `npm run build` and `npm run start:dev` boot without errors; NestJS logs confirm all modules, routes, and socket handlers registered correctly

**Client (both `app/customer_app/` and `app/admin_app/`):**
- New dependencies: `drift`, `sqlite3_flutter_libs`, `path`, `flutter_secure_storage`, `socket_io_client`, `connectivity_plus` (+ dev: `drift_dev`, `build_runner`) in `pubspec.yaml` for both apps
- New local Drift SQLite database (`lib/local_db/app_database.dart`): tables mirroring server models — LocalUser, Categories, Products, CartItems/CartMeta, Orders/OrderItemRows, ChatTopics/Messages, NotificationRows, Coupons, Shifts, RegionZones, Approvals, PendingMutations (offline queue), SyncCursors (per-table watermarks); admin_app omits cart and scopes orders/chat/approvals to staff-wide
- Renamed Drift columns to avoid shadowing: `text` → `content`, `tableName` → `entity` to prevent collision with Drift builder methods
- New `lib/session/secure_session_store.dart`: wraps `flutter_secure_storage` for access/refresh JWT persistence (replacing plaintext SharedPreferences storage in `lib/services/api_client.dart`)
- Updated `ApiClient` (`lib/services/api_client.dart`) to read/write tokens via secure store; added `accessToken` getter for socket handshake
- New `lib/realtime/socket_service.dart`: Socket.IO wrapper with JWT handshake auth, republishes gateway events as single broadcast Stream, exposes `joinChat`/`leaveChat` for on-demand rooms
- New `lib/sync/sync_engine.dart`: subscribes to socket events, upserts to Drift, exposes delta-pull methods (`syncOrders`, `syncMessages`, `syncNotifications`, etc.) using `since=` cursors persisted in SyncCursors table
- New `lib/sync/mutation_queue.dart`: wraps offline-sensitive writes, tries REST immediately, queues failures (ApiException code 0) in PendingMutations, drains queue on reconnect via connectivity_plus listener, preserves FIFO ordering
- Verified: `flutter analyze` clean on all new files (zero issues) in both apps; full-project analysis shows only pre-existing unrelated style/deprecation infos, zero errors

**Why:** The backend migration from Firebase to Node/Postgres left session storage as plaintext SharedPreferences, client apps had no local database, and real-time was timer-based polling only. This phase establishes the shared foundation — secure token storage, local SQLite schema, WebSocket connectivity, offline queueing, and delta-sync anchoring — that all per-feature steps (auth, catalog, cart, orders, chat, notifications, approvals) will build upon, approved per the user-accepted plan.

**Verification:** 
- Git status shows all expected file additions and modifications across backend, customer_app, admin_app, and plan directories
- Backend: `npm run build` and `npm run start:dev` execute cleanly with zero errors
- Client (both apps): `flutter analyze` executes cleanly (zero errors on new code); `dart run build_runner build` (Drift codegen) completes successfully
- Prisma: schema push validated by manual docker exec migration and successful `npx prisma generate` regeneration of client types
