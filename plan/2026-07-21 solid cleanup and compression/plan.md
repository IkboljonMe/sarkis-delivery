# SOLID Cleanup & Compression — Master Plan

**Date:** 2026-07-21
**Goal:** Make every app lighter, faster, and cleaner. Remove all dead code, commented-out
code, unused imports/packages, unused assets (images/videos/animations), and any accidental
complexity. Only essential code stays. Apply the `solid` skill throughout. Every app must still
build/compile and pass its tests after cleanup.

## Scope map (no agent crosses these boundaries)

| Agent | Directory | Stack |
|-------|-----------|-------|
| customer_app | `app/customer_app` | Flutter / Dart (173 dart files, lib=1.2M) |
| admin_app | `app/admin_app` | Flutter / Dart (lib=1.1M) |
| backend | `backend` | NestJS / TypeScript / Prisma (src=288K) |
| frontend | `frontend/landing` + `frontend/shop` | Next.js (2 apps) |
| review | ALL of the above (read-only verify) | cross-cutting |
| (self) | repo root | media & config |

## Per-agent mandate
1. Invoke the `solid` skill first.
2. Delete: unused Dart/TS files, unused imports, dead/unreachable code, commented-out code
   blocks, unused functions/classes/variables, unused packages (pubspec/package.json),
   unused assets (icons, animations, images, videos), duplicated logic (Rule of Three).
3. Do NOT change runtime behavior or public contracts. This is cleanup, not a rewrite.
4. Verify: the app still compiles/builds and existing tests pass. Report exact commands + output.
5. Stay strictly inside your directory. Report a concise summary of what was removed and the
   before/after size + file count.

## Root-level (self)
- `animation idea.mp4` (2.5M) — referenced only in old plan docs → delete.
- `new logo.png` (2.1M) — referenced only in old plan docs → delete.
- `.gitignore` — ensure `build/` and `node_modules/` are ignored.

## Verification gate (review agent)
- Confirm each app builds: `flutter analyze` (both apps), `npm run build` (backend + both frontends).
- Confirm no removed symbol is still referenced.
- Report any breakage introduced by the worker agents.
