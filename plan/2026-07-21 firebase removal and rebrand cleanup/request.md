# Request

**Date:** 2026-07-21

Fully delete Firebase/Firestore from the project (customer_app, admin_app, backend) and do a large cleanup pass: remove unused packages, dead code, stale comments, and old naming ("Sarkis Bread", "Sarkis Delivery") across Customer App, Admin App, and backend. Dispatched to three parallel agents (customer_app, admin_app, backend), coordinated via the `solid` skill.

Key constraint discovered during scoping: Firebase Cloud Messaging (FCM) is the only real Firebase usage left (backend is already fully migrated to Postgres/Prisma — no Firestore in code). Removing FCM means losing OS-level background/killed-state push notifications; in-app notifications keep working via the existing Socket.IO `notification:created` event + Postgres `Notification` table + Drift-synced inbox, which already exists independently of FCM. Foreground local notifications are rewired to trigger off that socket event instead of `FirebaseMessaging.onMessage`.

Out of scope (flagged as risk, left alone): Android `applicationId`/package name (`com.sarkisbread.pl`), the deployed `sarkis-delivery.vercel.app` URL, and the Prisma `Device.fcmToken` / `UserModel.fcmToken` schema field (kept as inert storage to avoid a DB migration; call sites removed).
