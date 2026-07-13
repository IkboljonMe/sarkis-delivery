# Plan — Backend build & app rewire

Related: [[request]] · [[changes]] · [[../2026-07-13 restructure and backend migration/api-routes|original route sketch]]

## Discovered domain (from the Flutter code)

The apps are richer than the original plan assumed. Firestore collections in use: `users`, `orders`, `products`, `categories`, `coupons`, `regionGroups` (city delivery zones with polygons: Berlin, Hamburg, Frankfurt, München), `shifts` (delivery days per city, orders belong to a shift), `approvals` (profile-change moderation), `messages` (customer↔admin chat with media, voice, reactions), plus Storage (avatars, product photos, chat media).

**Key decision — JSON compatibility:** the API returns field names identical to the current Firestore maps (`name`, `lastName`, `group`, `shiftId`, `pendingApproval`, …) so Dart models keep working with minimal edits (Timestamp → ISO-8601 string being the main one).

## Backend (NestJS + Prisma + PostgreSQL) — `backend/`

Modules: `auth`, `users`, `catalog`, `orders`, `coupons`, `zones`, `shifts`, `messages`, `approvals`, `uploads`, `superadmin`, `notifications` (FCM, optional), `health`, `common` (client-info), `prisma`.

### Roles
`CUSTOMER < DRIVER < ADMIN < SUPERADMIN` (higher role passes lower checks).
- Superadmin is seeded from env (`SUPERADMIN_EMAIL` / `SUPERADMIN_PASSWORD`); it creates driver/admin credentials (email + password), can deactivate, reset passwords, list drivers with their devices/last-seen.
- The old `isAdmin` boolean is still emitted in user JSON (computed from role) for app compatibility.

### Client / device / IP tracking (scalability requirement)
- Apps send `X-Client-Platform: android|ios`, `X-App-Version`, `X-Device-Model`; web is inferred from `User-Agent` (ua-parser). IP honours `X-Forwarded-For` only from the reverse proxy (Express `trust proxy`).
- A global middleware attaches `clientInfo` to every request; auth writes it to `LoginEvent` (audit: who, when, from which IP/platform/device/browser) and to the refresh-token row (session list per user).
- `Device` table stores per-user devices (platform, model, OS, app version, FCM token, last IP, last seen).
- `@Platforms('android','ios')` guard restricts routes by device type (e.g. OTP endpoints are mobile-only; superadmin panel web-only later). Ready for future per-platform routing.

### Auth
- Phone OTP: `POST /v1/auth/otp/request` + `/verify` — 6-digit code, bcrypt-hashed, 5 min TTL, max 5 attempts, per-phone (1/min, 5/day) + per-IP throttles. SMS via provider interface: `GatewayApiSmsProvider` (env `GATEWAYAPI_TOKEN`) or `DevSmsProvider` (logs the code; in non-production returns `devCode` in the response so login can be tested without SMS spend).
- Email register/login (bcrypt), Google ID-token login (`google-auth-library`, enabled when `GOOGLE_CLIENT_ID` set — for the future Next.js frontend).
- JWT access (15 min) + rotating refresh tokens (30 d, hashed, reuse detection revokes the whole family).

### Orders (core business rules, enforced server-side)
Prices are computed on the server from the product table (incl. product discounts), coupons validated & atomically redeemed, shift must be open and match the customer's group; cancel/edit windows (`cancelDaysBefore`/`editDaysBefore`) enforced from the shift. Status flow: `pending → confirmed → out_for_delivery → delivered | cancelled` with per-status timestamps + `OrderEvent` audit trail; drivers mark `cashCollected` (COD).

### Chat
REST (topics, messages, media upload, reactions, read markers, unread counts) with `?after=<cursor>` polling. WebSocket gateway is a later upgrade; the route shape won't change.

### Ops
- Docker: multi-stage `Dockerfile`, `docker-compose.yml` (Postgres 16 + API + uploads volume), `.env.example`, Swagger at `/docs` (non-prod), helmet, CORS, global validation whitelist, rate limiting.
- Seed: superadmin + the four region groups + sample catalog.
- Jest e2e suite against a disposable test DB: auth flows, RBAC, platform guard, order lifecycle incl. coupon, superadmin driver management.

## Flutter rewire — `app/customer_app`, `app/admin_app`

- Remove `cloud_firestore`, `firebase_auth`, `firebase_storage`. **Keep `firebase_core` + `firebase_messaging`** — FCM stays the push channel (standard even with custom backends); backend sends pushes via `firebase-admin` when a service account is configured, otherwise no-ops.
- New `ApiClient` (http + token storage, auto-refresh on 401, sends `X-Client-Platform`/`X-App-Version`/`X-Device-Model` headers).
- Each service keeps its public signatures; Firestore `Stream`s become polling streams (`emit now + every N seconds`) so ~all screens keep working unchanged. Chat polls at 3 s, orders 10 s, catalog 60 s.
- Models: drop `Timestamp`, parse ISO strings.
- `AuthProvider` reworked around our JWT session instead of the Firebase `User`.

## Verification

Backend: e2e suite green + manual smoke via curl. Device: build customer app APK, install via adb on the connected phone, verify OTP login end-to-end against the laptop's LAN IP (dev SMS provider).
