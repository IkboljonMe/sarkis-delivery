# Migration Plan — Firebase → Self-hosted Backend

**Decisions (2026-07-13):** Node.js + **NestJS** (TypeScript) · **PostgreSQL** · OTP via **GatewayAPI** (SMS to Germany ≈ €0.05–0.06/msg).

Related: [[request]] · [[api-routes]] · [[changes]]

## Target architecture

```
                    ┌─────────────────────────── VPS (Docker Compose) ──┐
Next.js frontend ──►│  Caddy (TLS, reverse proxy)                       │
Flutter customer ──►│    └─► NestJS API  ──► PostgreSQL                 │
Flutter admin    ──►│            ├─► GatewayAPI (SMS OTP)               │
                    │            ├─► Firebase Admin SDK (FCM push only) │
                    │            └─► pg backups (nightly, off-VPS)      │
                    └───────────────────────────────────────────────────┘
```

- **One API** serves all three clients; roles (`customer`, `driver`, `admin`) gate the admin/driver routes.
- **Firebase is not fully removed:** FCM stays for push notifications (free, best-in-class). Firestore, Firebase Auth, and Storage get replaced.
- ORM: **Prisma** (type-safe, migrations, plays well with NestJS).
- Product images: served from the VPS (`/uploads` volume behind Caddy); can move to S3-compatible storage (Hetzner Object Storage) later.

## Repo layout (after restructure — done)

```
app/customer_app/     Flutter customer app
app/admin_app/        Flutter admin/driver app
backend/              NestJS API (to be scaffolded)
frontend/landing/     Next.js — landing + login + ordering
plan/                 this Obsidian vault
```

## Data model (PostgreSQL)

- **users** — id (uuid), phone (unique, nullable), email (unique, nullable), password_hash (nullable), google_id (nullable), name, role (`customer|driver|admin`), phone_verified_at, email_verified_at, created_at
- **addresses** — user_id, label, street, house, zip, city, country (`DE`), lat/lng, is_default
- **categories** — id, slug, name (jsonb, multi-language)
- **products** — id, category_id, name (jsonb), description (jsonb), price_cents, currency (`EUR`), image_url, stock, is_active
- **orders** — id, number (human-readable), user_id, driver_id (nullable), status, address_snapshot (jsonb — orders keep the address as it was), items_total_cents, payment_method (`cod` only for now), cash_collected (bool), delivery_notes, timestamps per status
- **order_items** — order_id, product_id, name_snapshot, price_cents_snapshot, qty
- **otp_codes** — phone, code_hash, expires_at, attempts, created_at
- **refresh_tokens** — user_id, token_hash, device_info, expires_at, revoked_at
- **devices** — user_id, fcm_token, platform

**Order status flow:** `pending → confirmed → preparing → out_for_delivery → delivered` (+ `cancelled`, `failed_delivery`). `delivered` requires the driver to mark `cash_collected = true` (cash-on-delivery reconciliation).

## Authentication

JWT **access token** (15 min) + rotating **refresh token** (30 days, stored hashed). Same token system for all clients.

| Client | Methods |
|---|---|
| Next.js web | Google Sign-In (ID token → `POST /auth/google`), email + password |
| Flutter apps | Phone OTP via GatewayAPI, email + password |

**OTP flow (GatewayAPI):**
1. `POST /auth/otp/request` — validate German/EU number (E.164), generate 6-digit code, store bcrypt hash with 5-min expiry, send via GatewayAPI REST.
2. `POST /auth/otp/verify` — max 5 attempts per code, then invalidate.
3. **Anti-abuse (this is what controls SMS cost):** per-phone limit 1 SMS/60s and 5/day; per-IP daily cap; silent success for unknown throttled numbers. Log every send — at €0.05/SMS an abuse loop gets expensive fast.
4. GatewayAPI setup: EU account, prepaid top-up, register alphanumeric sender ID "Sarkis" for German carriers.

## Migration phases

1. **Scaffold backend** — NestJS + Prisma + Postgres in `backend/`, Docker Compose for local dev, health endpoint, CI (lint + tests).
2. **Auth module** — email/password, Google ID-token verification, OTP via GatewayAPI (behind an SmsService interface so the provider is swappable), JWT + refresh rotation.
3. **Core domain** — catalog, orders, addresses; admin + driver endpoints (see [[api-routes]]); FCM push from backend via `firebase-admin` on order-status changes.
4. **Next.js frontend** — build in `frontend/landing`: landing page, product catalog, Google/email login, checkout (COD), order history. API access via a typed client (OpenAPI-generated from NestJS Swagger).
5. **Flutter apps switch** — replace Firestore/Firebase-Auth service classes with a Dio-based API client; keep the existing provider/screen layer intact (services are already isolated in `lib/services/`). Keep `firebase_messaging` for push.
6. **Data migration** — script: Firestore export → transform → Postgres insert (users, products, order history). Phone-auth users map by phone number.
7. **VPS deployment & cutover** — Docker Compose (Caddy + API + Postgres), nightly `pg_dump` shipped off-VPS, `.env` secrets, staging test with real order end-to-end, then point apps at production API and decommission Firestore/Rules/Functions.

## VPS notes (for later)

- Any EU VPS (Hetzner CX22/CX32 is the usual price/performance pick, Germany-located = good for GDPR and latency).
- Caddy for automatic HTTPS; UFW firewall (80/443/SSH only); Postgres not exposed publicly.
- Domains: `api.sarkis-delivery.…` for the API, apex for Next.js (Next.js can also run on the VPS via Docker, or on Vercel free tier initially).
