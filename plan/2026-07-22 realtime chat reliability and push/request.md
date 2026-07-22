# Request — 2026-07-22

The chat has big problems in real use. The user wants a WhatsApp/Telegram-grade chat experience. Reported symptoms:

- All messages are not showing.
- New messages are not sent on chat.
- No history.
- No real-time messaging.
- No notifications about new messages.

Goal: make customer↔staff chat reliable and live, matching what users expect from WhatsApp/Telegram — messages always load, send with visible state, arrive in real time, survive reconnects, and notify when the app is backgrounded/closed.

Clarified during planning (via AskUserQuestion):
- **Scope:** Full WhatsApp-grade plan (all diagnosed items), designed first then implemented in reviewed steps.
- **Push transport:** **FCM HTTP v1 (Android) + APNs (iOS) sent server-side directly from NestJS**, WITHOUT the Firebase client SDK that was removed in the rebrand. Android still needs a `google-services`/sender config for token registration only.
