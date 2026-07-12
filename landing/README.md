# Sarkis Delivery — web

Next.js (App Router) site with three jobs:

1. **Smart download link** (`/`) — detects the visitor's device from the
   User-Agent and redirects to the right store:
   - Android → Google Play (`com.sarkisbread.pl`)
   - iOS → App Store (set the real id in `app/config.js`)
   - Desktop / unknown → shows both buttons.
2. **Privacy Policy** (`/privacy`)
3. **Terms of Service** (`/terms`)

Privacy & Terms are multilingual (EN / RU / DE / TR / HY) with a language
switcher (`?lang=ru` etc.), matching the mobile apps.

## Run

```bash
cd landing
npm install
npm run dev      # http://localhost:3000
# or
npm run build && npm start
```

## Configure before publishing

Edit `app/config.js`:
- `APPSTORE_URL` — the real App Store id once the iOS app is live.
- `PLAY_URL` — already points to `com.sarkisbread.pl`.
- `SUPPORT_EMAIL`, `CONTACT_WHATSAPP`.

Deploy anywhere that runs Next.js (e.g. Vercel). After deploying, put the
site's `/privacy` and `/terms` URLs into the mobile app
(`customer_app/lib/utils/constants.dart` → `AppConstants.privacyUrl` /
`termsUrl`), and use the root URL as the shareable download link.
