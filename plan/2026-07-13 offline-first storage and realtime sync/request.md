# Request — 2026-07-13

Since the backend moved from Firebase to Node.js/Postgres, session management and local storage in both apps are bad. The user wants local SQL storage on both `customer_app` and `admin_app`: when logged in, download important data from the server DB, and when something changes (chat, orders, notifications), update the app quickly.

Instructions:
- Go through each customer-app function, list them, and think about the best way to store data, when to update, and what mechanism to use for what — then implement one by one with a plan. Don't leave out small functionality.
- Same for the driver app (admin_app), which has many more functionalities — expect a bigger plan.

Clarified during planning (via AskUserQuestion):
- Real-time transport: **WebSocket (Socket.IO gateway on NestJS) + FCM hybrid** (not polling-only).
- Driver app scope: **storage/session/sync only** — do not add new driver-role features (assigned-orders, accept/reject, location tracking, proof-of-delivery, availability toggle) in this pass.
