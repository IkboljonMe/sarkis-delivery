# Changes Log — Sarko rebrand and entry animation

## 2026-07-13 09:00 — Rebrand to Sarko + new S-route logo + entry animation

**What changed:**

- **Logo assets** (both apps): Generated tight-cropped, transparent PNG icons from the user's `new logo.png` into `app/customer_app/assets/icon/` and `app/admin_app/assets/icon/`: `logo_s.png` (in-app brand mark), `app_icon.png` (launcher source), `adaptive_fg.png` (Android adaptive foreground with icon at ~66% within safe zone).

- **Launcher icon config** (both `app/*/pubspec.yaml`): Updated `flutter_launcher_icons` settings: `adaptive_icon_background` #C8972A → #2E2F36 (charcoal); `adaptive_icon_foreground` `wheat_fg.png` → `adaptive_fg.png`. Ran `dart run flutter_launcher_icons` to regenerate all mipmap resources. Updated pubspec `description` lines: customer → "Sarko Delivery…", admin → "Sarko Driver…".

- **BrandLogo widget rewrite** (`app/customer_app/lib/widgets/brand_logo.dart` and `app/admin_app/lib/widgets/brand_logo.dart`): Dropped the old gold-gradient badge + custom pin painter. Now renders the PNG logo via `Image.asset('assets/icon/logo_s.png')`. Wordmark lockup: customer shows "Sarko / DELIVERY", admin shows "Sarko / DRIVER", both using the new `AppColors.brandOrange` (#F16702).

- **Brand color palette** (both `app/*/lib/utils/app_colors.dart`): Added four new constants sampled from the logo: `brandOrange` #F16702, `brandOrangeLight` #FF8A34, `roadDark` #2E2F36, `roadDarker` #212228. Gold design-system colours (`primary`, `accent`, etc.) left in place (full re-theme not in scope).

- **Brand-string rename** ("Sarkis Delivery" → "Sarko Delivery") across:
  - **Customer app**: `lib/l10n/app_strings.dart` (all 5 languages: appName, welcome, verifyBody, termsBody), `lib/main.dart` MaterialApp title, `lib/services/local_notifications.dart` default channel titles, `lib/services/api_client.dart` comments, `lib/utils/welcome_message.dart` brand mentions.
  - **Admin app**: `lib/main.dart`, `lib/screens/splash_screen.dart`, `lib/screens/login_screen.dart`, `lib/screens/main_scaffold.dart`, `lib/services/local_notifications.dart` all set to "Sarko Driver".
  - **Android manifests**: customer `android:label` "Sarkis Delivery" → "Sarko"; admin "Sarkis Delivery Admin" → "Sarko Driver".
  - **Backend** (`backend/src`): `main.ts` Swagger title, `auth/sms.provider.ts` OTP SMS text + sender name, `messages/messages.module.ts` notification title + default senderName.
  - **Landing site** (`frontend/landing/app/*`): config APP_NAME, `layout.jsx` metadata, `legal.js`, `privacy/page.jsx`, `terms/page.jsx`, `delete-account/page.jsx` (all 5 languages).
  - **Package metadata**: `app/*/pubspec.yaml` descriptions, `backend/package.json`, `frontend/landing/package.json` all reflect "Sarko Delivery".
  - **Example coupon**: SARKIS10 → SARKO10.

- **Localization key** `tagline` added to all 5 languages in `app/customer_app/lib/l10n/app_strings.dart` (en: "We deliver goods till your house", plus ru/de/tr/hy translations matching the reference video's tagline).

- **Animated entry splash** (complete rewrite of `app/customer_app/lib/screens/splash_screen.dart`): A `StatefulWidget` with a single 3.4-second `AnimationController` and interval-based sub-animations. **Act 1**: a `CustomPainter` (`_RouteScenePainter`) draws a winding S-shaped road with a dashed centre-line; an orange delivery car (drawn via canvas with headlight glow) travels the path's leading tip using `PathMetric` tangents, arriving at a popping location pin. **Act 2**: the road scene dissolves and cross-fades into the `BrandLogo` image, then the "Sarko Delivery" wordmark and localized tagline rise in. Pure Flutter (no video embed). Existing post-delay routing/auth logic preserved (navigate to /welcome, /register, or /main).

- **Technical identifiers left intentionally unchanged** (tied to live services): Firebase project `sarkisbread`, Android package `com.sarkisbread.pl`, notification channel IDs (`sarkis_bread_channel`), `google-services.json`, web URLs (`sarkis-delivery.vercel.app`), npm package names, admin persona's human name "Sarkis" in chat/welcome copy, `senderName: 'Sarkis'`.

**Why:** The user requested a visual rebrand to the new "Sarko" brand identity with the custom S-route logo and a polished entry animation that captures the reference video's idea (car-on-road → logo → wordmark + tagline). The entry animation reinforces brand recall and sets a premium tone for the customer experience.

**Verification:**
- `flutter analyze` on both `app/customer_app` and `app/admin_app`: 0 errors (only pre-existing `withOpacity` info-lints).
- Launcher icons regenerated and verified visually in the asset directories.
- Splash animation route geometry validated via throwaway widget test (since deleted) and rendered to PNG snapshots: road reveal, car-on-path with headlight glow, and pin arrival all render correctly.
- Brand strings spot-checked across Dart l10n, backend Swagger/SMS, and landing site config.
- `git status` confirms all intended files modified; untracked logo source files (`new logo.png`, `animation idea.mp4`) and icon assets (`*_fg.png`, `logo_s.png`) in place.
