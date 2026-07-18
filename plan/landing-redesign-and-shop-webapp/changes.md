# Change Log

## 2026-07-17 04:57 — Landing redesign & web shop scaffold

**What changed:**

PART A — Marketing landing redesign:
- `frontend/landing/app/page.jsx`: replaced minimal store-redirect page with full marketing landing page (sticky header with logo + nav + "Order online" button, hero section with gradient text, features strip with 4 inline SVG icons, "How it works" 3-step section, cities grid, get-the-app download buttons, footer with WhatsApp/support/legal links). Kept Android/iOS user-agent redirects to Play Store and App Store.
- `frontend/landing/app/layout.jsx`: added new metadata (title, description, OG tags) and imported Fraunces + Inter fonts via next/font/google.
- `frontend/landing/app/config.js`: updated `SUPPORT_EMAIL` to "support@sarko-delivery.de", added `SHOP_URL` = "https://shop.sarko-delivery.de", renamed `APP_NAME` reference to "Sarko Delivery".
- `frontend/landing/app/globals.css`: appended landing-specific styles (hero, features, cities sections, form styling). Legal page styles untouched.
- `frontend/landing/app/legal.js`: renamed "Sarkis Delivery" → "Sarko Delivery" in team attribution.
- `frontend/landing/app/delete-account/page.jsx`: renamed "Sarkis" → "Sarko" in account deletion copy.
- `frontend/landing/public/logo.png`: added (Sarko rebrand logo).

PART B — New customer web-ordering app (Next.js 14, JSX, hand-written CSS, no Tailwind/TypeScript):
- `frontend/shop/` (new directory): scaffolded Next.js 14 customer ordering web app.
- `frontend/shop/package.json`: configured Next.js ^14.2.35, React 18.3.1, no UI framework deps.
- `frontend/shop/next.config.mjs`: minimal config.
- `frontend/shop/.gitignore`: standard Node.js ignore rules.
- `frontend/shop/.env.local.example`: environment variables (NEXT_PUBLIC_API_URL, NEXT_PUBLIC_GOOGLE_CLIENT_ID).
- `frontend/shop/public/logo.png`: Sarko rebrand logo.
- `frontend/shop/lib/api.js`: API client with base URL + /v1 prefix, Bearer token auth, single-flight 401 refresh logic, imageUrl helper for relative /uploads paths.
- `frontend/shop/lib/format.js`: locName (EN fallback), EUR formatting, product discount helpers (percent/fixed), effectiveMaxQty (0→10 default), CITIES array, ORDER_STATUS_LABELS.
- `frontend/shop/app/providers.jsx`: AuthContext (email login/register, Google path, logout, localStorage persistence) + CartContext (localStorage cart + city selection).
- `frontend/shop/app/layout.jsx`: site-wide layout with header, footer, favicon.
- `frontend/shop/components/Header.jsx`: sticky header with cart badge & account dropdown.
- `frontend/shop/components/Footer.jsx`: footer with links & support info.
- `frontend/shop/components/ProductCard.jsx`: product card with discount badge, struck-through price, qty stepper.
- `frontend/shop/components/Skeletons.jsx`: loading placeholders.
- `frontend/shop/components/EmptyState.jsx`: empty cart/results messaging.
- `frontend/shop/app/page.jsx`: home page — category grid + all products listing.
- `frontend/shop/app/category/[id]/page.jsx`: category detail page — filtered products by category ID.
- `frontend/shop/app/cart/page.jsx`: cart page — line items with qty edit, coupon input (GET /coupons/:code), city selection via chips, delivery-day selector (GET /shifts?group=&open=true), place order button (POST /orders), success screen with "Pay cash on delivery" message.
- `frontend/shop/app/login/page.jsx`: login/register toggle, email/password fields, env-gated Google login button with coming-soon tooltip (no Google script wiring yet), ?next= URL redirect support.
- `frontend/shop/app/orders/page.jsx`: my orders page — fetches GET /orders/mine, displays list with status chips.
- `frontend/shop/app/globals.css`: hand-written dark gold/orange brand styling (~20KB), CSS variables for colors/spacing, no Tailwind classes.

**Why:** Complete frontend redesign to establish Sarko brand identity with modern marketing landing, and launch customer web-ordering platform independent of mobile app. Landing keeps existing mobile redirects while driving desktop traffic to web shop.

**Verification:** 
- PART A: npm run build completed without errors in `frontend/landing/`; dev server on :3100 verified routes / /privacy /terms /delete-account all return 200.
- PART B: npm run build completed without errors in `frontend/shop/`; dev server on :3200 (with backend offline) verified all routes (/ /category/1 /cart /login /orders) load with graceful skeleton/error states, no TypeScript errors.
- Git status shows all changes in `frontend/landing/` and `frontend/shop/` directories committed or staged as expected.
- TODO: real Google client ID + Google Identity Services script integration; confirm real App Store URL; confirm production shop.sarko-delivery.de domain.

## 2026-07-18 10:00 — Deep UI/UX polish for landing: entrance animations, scroll-reveal, responsive refinements, 404 page

**What changed:**
- `frontend/landing/app/globals.css`: full rewrite/expansion to ~1283 lines. Added design tokens (`--ease-out` cubic-bezier, `--header-h`, fluid `--section-pad` via clamp), motion primitives (rise-in/scale-in keyframes with "from" state only for hover transition survival, float + drift keyframes for ambient hero motion), scroll-reveal CSS gated behind `html.rvl` class (page fully visible without JS), staggered nth-child reveal delays for grids, polished buttons (hover lift + gold glow, active scale .97, 44px+ tap targets), animated nav underline, card hover lift/border-glow/shadow for features/steps/cities, mobile hamburger + full-screen slide-in menu styles with burger→X icon morph, back-to-top button styles, subtle CSS-only film grain overlay (inline SVG feTurbulence data URI), fluid clamp() typography throughout (hero clamp(2.2rem,8vw,4.2rem)), scroll-padding-top/scroll-margin-top for anchor nav under sticky header, section eyebrow + gradient underline heading pattern, 4-column footer with hover states, 404 page styles, full `prefers-reduced-motion` override, and mobile-safe grid collapses (features 4→2→1, steps 3→1, cities 4→2→1 with `minmax(0,1fr)`, no horizontal scroll at 320px). Legal page CSS-only polish applied: `.wrap h1/h2` use display font with fluid sizes, card section dividers, improved footer link tap targets.
- `frontend/landing/app/page.jsx`: rewritten landing page with staggered hero entrance classes (anim-rise d-1..d-5, split headline lines), `data-reveal` / `data-reveal-group` attributes on all below-fold sections, section eyebrow labels, new header with header-actions + MobileNav component, restructured footer (Explore/Contact/Legal columns + cities line in footer-bottom), BackToTop and RevealInit components mounted. Kept server-side UA store-redirect logic intact (Android→Play Store, iOS→App Store, verified via curl 307s).
- `frontend/landing/app/components/RevealInit.jsx` (new): IntersectionObserver scroll-reveal bootstrap, adds `is-visible` class, respects `prefers-reduced-motion`, no-JS safe.
- `frontend/landing/app/components/MobileNav.jsx` (new): hamburger + full-screen slide-in menu component, body scroll-lock, closes on link/Escape/desktop-resize, animated burger→X morphing icon.
- `frontend/landing/app/components/BackToTop.jsx` (new): rAF-throttled floating button appearing after 560px scroll.
- `frontend/landing/app/not-found.jsx` (new): styled 404 page matching dark/gold brand, gradient 404 display, entrance animation, home + shop CTAs.
- `frontend/landing/app/layout.jsx`: added viewport meta export (width/initial-scale/themeColor #0a0a0a) and logo icons metadata.

**Why:** Enhanced landing page with smooth entrance animations, scroll-reveal for engagement, mobile-optimized navigation, comprehensive responsive grid refinements (no horizontal scroll at 320px), and a branded 404 page. All animations respect user motion preferences and work without JavaScript. Frontend-only polish maintains existing backend integrations and mobile app redirects.

**Verification:** `npm run build` passed (First Load JS 88.7 kB for /, all 5 routes ok); curl on temp port confirmed 200 for / /privacy /terms /delete-account, styled 404 for unknown routes, and 307 store redirects for mobile UAs preserved. No new runtime dependencies added. Frontend/shop handled separately by another agent.

## 2026-07-18 14:00 — Deep UI/UX polish for shop: new components, skeleton family, animations, a11y, responsive

**What changed:**
- `frontend/shop/components/Toast.jsx` (new): self-made ToastProvider with context API, fixed slide-in stack (3 max), success/error icon variants, auto-dismiss (3s default), aria-live="polite" for screen readers, 280ms fade-out exit animation.
- `frontend/shop/components/FadeImg.jsx` (new): image fade-in on load with cache-hit detection (checks `img.complete` on mount), cache-safe for fast re-renders.
- `frontend/shop/components/MobileCartBar.jsx` (new): sticky bottom bar on mobile (visible only when items > 0 and not on /cart page), shows item count + total price + "View cart" link, toggles `body.has-cartbar` class for footer + toast stack spacing, respects safe-area-inset-bottom via CSS.
- `frontend/shop/app/template.jsx` (new): route-level wrapper with `.route-fade` class triggering fade-up + rise entrance on every page change.
- `frontend/shop/components/Skeletons.jsx` rebuilt (was monolithic): refactored into component family — `SkeletonCategoryGrid`, `SkeletonProductGrid`, `SkeletonCartLines`, `SkeletonShiftChips`, `SkeletonOrders`. Each mirrors its real layout exactly (cards, grids, line items), shimmer animation, per-index stagger delay (max 11 indices × 45ms = 495ms cascade), injected via `aria-hidden` sections on all data-loading pages (home, category detail, cart, orders).
- `frontend/shop/components/EmptyState.jsx` rebuilt: four hand-drawn inline SVG illustration variants (bread, oven, cart, orders). Oven variant includes animated steam rise for "API unreachable" state; all variants include in-place Retry button via action prop.
- `frontend/shop/components/ProductCard.jsx` enhanced: "✓ Added" button text morph (1.4s auto-reset via timer), qty stepper with fade/slide transition (keyed on qty value, bumps via `qty-bump` keyframe), entrance stagger per grid index, add-to-cart toast integration, header cart badge pops on count change (via Badge component in Header).
- `frontend/shop/app/cart/page.jsx` enhanced: cart line item removal with `line-out` slide+fade animation, delivery-day shift chips as horizontal-scroll radiogroup (snap-scroll on mobile), coupon/place-order buttons with spinner state, order-success screen featuring stroke-draw checkmark animation (`check-draw` SVG keyframe) + staggered summary reveal, sticky "Place order" button bar on mobile.
- `frontend/shop/app/login/page.jsx` enhanced: spinner icon inside button label (swaps label text during request), friendly error message mapping (network/401 "Auth failed"/409 "Email taken").
- `frontend/shop/app/globals.css` expanded (~1828 lines): design tokens (--ease-out cubic-bezier, --gold/#c8972a, --accent/#ff6b35), motion keyframes (fade-up, pop-in, qty-bump, add-pulse, toast-in, slide-up, check-draw, line-out, steam-rise, scale-in, spin), focus-visible rings (2px gold, 2px offset, 4px radius) for keyboard nav, input font-size 16px + no zoom on iOS, button/link tap targets 44px+, 2-column product grid on mobile (1-column <360px), cart/categories grids collapse responsively (max-width: 640px breakpoints), no horizontal scroll at 320px width, `prefers-reduced-motion: reduce` kill-switch disables all keyframes + transitions.
- `frontend/shop/package.json`: dependency versions pinned (Next.js ^14.2.35, React 18.3.1, no UI framework).

**Why:** Comprehensive UI/UX polish across shop app to match landing rebrand quality. Skeleton loading family provides visual continuity during API delays. Toast provider, FadeImg, and MobileCartBar improve user feedback and mobile UX. Animation suite (route transitions, add-morph, line removal, order success stroke-draw) creates delight without friction. Full accessibility pass (focus rings, ARIA, no iOS zoom) and exhaustive responsive refinements ensure 16:9 hero on desktop, 2-col grid on tablets, 1-col on phones <360px, all tap targets 44px+, no horizontal scroll at any width.

**Verification:** 
- `npm run build` passed cleanly in `frontend/shop/`; First Load JS ~103 kB for main routes (/, /category/[id], /cart, /login, /orders).
- Built HTML contains skeleton classes (144 skeleton/transition class usages), motion primitives (fade-up, reveal, route-fade), and `aria-hidden` sections verified via grep on .next output.
- Responsive media queries tested: 640px (mobile), 360px (small phone), 520px, 860px breakpoints all present; `prefers-reduced-motion` override in final block confirmed.
- Toast, FadeImg, MobileCartBar, template integration compile without runtime errors; all new components export cleanly.
- Deployment step completed: both landing and shop production bundles rebuilt and live servers (landing :3100, shop :3200, backend :3000) restarted with both agents' work merged cleanly—no file conflicts, no lost changes despite mid-session interruption recovery.
