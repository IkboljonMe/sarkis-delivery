# Request — 2026-07-13 (2): Build backend, rewire apps off Firebase

## What was asked

1. **No Firebase data migration** — existing Firestore data can be wiped; start fresh.
2. Build a complete, secure, tested, deployable REST API backend (NestJS + PostgreSQL, per [[../2026-07-13 restructure and backend migration/plan|previous plan]]) with **all routes available**.
3. Remove Firebase code from **both Flutter apps** and replace it with backend API calls.
4. Phone is connected to the laptop — install the app and verify **login works** on the real device (keep token usage modest).
5. **Device & IP tracking**: capture per-request client platform (Android / iOS / web browser), device info, and IP — needed later for analytics and for restricting some routes to certain device types. Design the backend to be scalable for this.
6. **Roles**: drivers, plus **one superadmin** who can see all drivers and create their login credentials.

Links: [[plan]] · [[changes]]
