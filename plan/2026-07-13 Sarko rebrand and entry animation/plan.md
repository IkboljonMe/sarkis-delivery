# Plan — Sarko rebrand + entry animation

## 1. Logo assets
- Regenerate `assets/icon/{logo_s,app_icon,adaptive_fg}.png` in both apps from the clean
  `new logo.png` (tight-cropped, transparent).
- Update `flutter_launcher_icons` in both pubspecs: `image_path` → new icon,
  `adaptive_icon_background` → charcoal `#2E2F36`, `adaptive_icon_foreground` → `adaptive_fg.png`.

## 2. Brand mark widget
- Rewrite `lib/widgets/brand_logo.dart` in **both** apps to render the PNG logo (rounded) via
  `Image.asset`, dropping the old gold-badge + pin painter. `.wordmark` shows the logo beside a
  "Sarko" / "DELIVERY" lockup.

## 3. Rename brand strings (user-facing only)
- `Sarkis Delivery` → `Sarko Delivery` across Dart UI, l10n (`app_strings.dart`, all 5 langs:
  appName/welcome/verifyBody/termsBody), `main.dart` titles, default notification titles,
  pubspec + package.json descriptions.
- Android labels: customer `android:label` → **Sarko**; admin → **Sarko Driver**.

## 4. Entry animation (customer app)
- New `SplashScreen`: dark textured backdrop, a winding S-route path draws in with a dashed
  centreline, an orange car travels the path (via `PathMetric` tangent) toward a pulsing
  location pin, then the whole scene cross-fades to the logo + "Sarko Delivery" wordmark +
  tagline "We deliver goods till your house". Pure Flutter (`CustomPainter` + AnimationController),
  no video. Preserve existing post-delay routing logic.

## 5. Verify
- `flutter pub get` + `flutter analyze` on customer app; regenerate launcher icons.
