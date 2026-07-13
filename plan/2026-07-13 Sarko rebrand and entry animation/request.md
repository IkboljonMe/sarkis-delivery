# 2026-07-13 — Sarko rebrand + entry animation

## What was asked

1. **New logo** uploaded (`new logo.png` — an orange/charcoal rounded "S" route icon with
   a car, dashed route and a location pin). Adopt it as the app brand mark and launcher icon.
2. **New app name**: the brand is **Sarko Delivery**. The individual apps are named just
   **Sarko** (customer app) and **Sarko Driver** (admin/driver app).
3. **Entry animation**: the user uploaded `animation idea.mp4` (an orange car driving along a
   winding S-road that resolves into the logo, then the "Sarko Delivery — We deliver goods till
   your house" wordmark). Build a *similar* animation shown when a customer enters the app —
   **do not** embed that video; recreate the idea natively (car-on-route → logo reveal), or a
   logo animation.

## Constraints / decisions

- Do **not** touch technical identifiers tied to live services: Firebase project `sarkisbread`,
  Android package `com.sarkisbread.pl`, notification channel IDs (`sarkis_bread_channel`),
  `google-services.json`. Only user-facing brand strings + display names change.
- Keep the admin persona's human name ("Sarkis") in chat/welcome copy; only the brand string
  "Sarkis Delivery" → "Sarko Delivery".
- Gold design-system colours left in place for now; logo + splash use the new orange/charcoal.
