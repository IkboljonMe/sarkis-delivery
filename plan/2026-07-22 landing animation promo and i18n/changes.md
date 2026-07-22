# Changes Log

## 2026-07-22 08:52 — Animated delivery hero, 50% promo, and language switcher (d576ab1)

**What changed:**
- New component `frontend/landing/app/components/PromoRibbon.jsx` — sticky, dismissible promo ribbon announcing 50% off first order; dismissal state persists in localStorage
- New component `frontend/landing/app/components/DeliveryScene.jsx` — inline SVG animation replacing static logo halo; features bobbing van with spinning wheels, bread aboard with rising steam, floating baked-goods icons (loaf/bagel/croissant/wheat), streaming road with motion-conveying dashes, and fading "delivery" wordmark; all motion via transform/opacity, honours prefers-reduced-motion
- New component `frontend/landing/app/components/LanguageSwitcher.jsx` — dropdown switcher covering all 5 locales (en, hy, ru, tr, de) with endonym labels and flags; swaps leading locale path segment, degrades gracefully without JS
- Modified `frontend/landing/app/components/MobileNav.jsx` — wired language switcher into mobile menu
- Modified `frontend/landing/app/[locale]/page.jsx` — ribbon and header now live in shared sticky ".top-stack" wrapper so dismissing ribbon leaves header flush at top
- Modified `frontend/landing/app/globals.css` — removed dead `.logo-halo` CSS and unused `float` keyframe, added `.top-stack` sticky wrapper, bumped `scroll-padding-top` to account for ribbon
- Updated all 5 locale message files (`frontend/landing/messages/{en,hy,ru,tr,de}.json`) — added new keys: `nav.language`, `hero.sceneCaption`, `promo.ribbon`, `promo.ribbonCta`, `promo.badge`, `promo.dismiss`; fully translated previously-English Armenian (hy) and Turkish (tr) content

**Why:** The marketing request was to showcase the Sarko niche (cheap cash-on-delivery Armenian bread) with an animated delivery atmosphere, a first-order discount offer, and a 5-language switcher accessible from the header and mobile menu.

**Verification:** `npm run build` passes successfully; commit d576ab1 verified on main branch.
