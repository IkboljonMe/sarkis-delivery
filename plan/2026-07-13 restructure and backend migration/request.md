# Request — 2026-07-13

## What was asked

1. Create an Obsidian vault folder `plan/`, with one folder per request.
2. Create an AI agent that logs every change made into the vault.
3. Restructure the repo: create `backend/`, `frontend/`, `app/` folders; move all app folders into `app/`.
4. Plan the migration from Firebase to a real backend:
   - API server in Python or Node.js, DB PostgreSQL or MongoDB, deployed to a VPS later.
   - Design the API routes the clients will use.
   - Frontend: Next.js landing page + login (Google account or email) + ordering.
   - Mobile apps: login via mobile OTP (find cheap EU SMS providers) and email.

## Business context

- **Product:** national breads (e.g. Armenian), delivered to the door.
- **Market:** Europe, currently Germany only.
- **Payment:** cash on delivery only — no prepayment.
- **Delivery fee:** free.
- **Apps:** `admin_app` (drivers/admin, Flutter) and `customer_app` (iOS/Android, Flutter), currently on Firebase (test).

Links: [[plan]] · [[changes]]
