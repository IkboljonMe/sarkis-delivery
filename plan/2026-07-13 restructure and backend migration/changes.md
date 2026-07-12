# Changes — restructure and backend migration

## 2026-07-13 — Repo restructure + plan vault + change-logger agent

**What changed:**
- Created top-level folders `app/`, `backend/`, `frontend/`, `plan/`.
- Moved `admin_app/` → `app/admin_app/` and `customer_app/` → `app/customer_app/` (via `git mv`, history preserved; uncommitted edits in `customer_app` moved along untouched).
- Moved the untracked Next.js project `landing/` → `frontend/landing/`.
- Created the Obsidian plan vault: `plan/Home.md` index and this request's folder.
- Created the `change-logger` agent at `.claude/agents/change-logger.md` — it appends every future change batch to the matching request's `changes.md`.

**Why:** Requested repo reorganization ahead of the Firebase → self-hosted backend migration, plus a documented planning workflow in Obsidian.

**Verification:** `git status` shows clean renames (`R` entries) for both Flutter apps; `frontend/landing/` contains the Next.js project. Flutter apps are self-contained so the move does not break builds. Known follow-up: paths mentioned in `docs/*.md` (e.g. `customer_app/...`) are now stale and should be updated to `app/customer_app/...`.
