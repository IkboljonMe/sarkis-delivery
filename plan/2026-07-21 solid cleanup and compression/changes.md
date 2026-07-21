# Changes Log

## 2026-07-21 22:15 — SOLID cleanup pass complete across all codebases

**What changed:**

**Repository root:**
- Deleted unused media assets `animation idea.mp4` (2.5 MB) and `new logo.png` (2.1 MB), referenced only in old plan documentation
- Hardened `.gitignore` with entries for `node_modules/`, `**/build/`, `**/dist/`, `.dart_tool/`
- Untracked stray committed build artifact `app/customer_app/android/build/reports/problems/problems-report.html`

**customer_app (Flutter):**
- Deleted unused Dart file `lib/screens/profile/info_page.dart` (InfoPage class, never referenced)
- Removed dead `AppLoader` class from `lib/widgets/app_lottie.dart`
- Removed orphaned `AppAnim.loading` const and `app_colors.dart` import in `lib/widgets/app_lottie.dart`
- Removed unused `constants.dart` import in `lib/providers/auth_provider.dart`
- Deleted unused assets `assets/animations/loading.json` and `assets/icon/wheat_fg.png`
- Reduced analyzer warnings from 1 to 0 (45 pre-existing info-level issues remain, unrelated)

**admin_app (Flutter):**
- Removed 3 unused dependencies from `pubspec.yaml`: `grouped_list`, `badges`, `googleapis_auth` (Firebase leftover)
- Deleted unused asset `assets/icon/wheat_fg.png`
- Analyzer shows 55 info-level issues, zero errors/warnings, no new issues introduced
- Intentionally kept `sqlite3_flutter_libs` (runtime native dependency of drift ORM)

**backend (NestJS/TypeScript):**
- Removed 3 dead imports: `Role` from `src/auth/auth.service.ts`, `Prisma` from `src/messages/messages.module.ts`, `Module` from `src/orders/orders.controller.ts`
- Removed 2 unused dependencies from `package.json`: `uuid` and `socket.io-client`
- Deleted throwaway manual smoke-test file `test_ws.mjs`
- Reduced strict unused-check errors from 3 to 0
- Intentionally kept `rxjs` (Nest framework runtime peer dependency)
- Verified: `tsc --noEmit` clean, `nest build` passes

**frontend (Next.js):**
- landing app: removed unused `LANGS` import in `app/[locale]/delete-account/page.jsx`
- shop app: no dead code found (already lean)
- Both apps: `npm run build` succeeds with unchanged route output

**Why:** All four codebases were already fairly tight; the pass focused on removing only verified dead code (symbols with zero references verified by independent review agent) and orphaned files. This reduced disk weight and improved code clarity without altering any runtime behavior, routes, UI, or database schema.

**Verification:** Independent review agent confirmed PASS on all five areas:
- Every deleted symbol/file/asset/package verified to have zero remaining source references
- customer_app: `flutter analyze` (0 new issues)
- admin_app: `flutter analyze` (0 new issues)
- backend: `tsc --noEmit` clean, `nest build` passes, strict unused-check 3→0 errors
- frontend landing: `npm run build` succeeds
- frontend shop: `npm run build` succeeds
