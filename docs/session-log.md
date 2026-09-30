# Apex Rush — Session Log

Append-only history of work sessions. Newest entries **on top**. Keep entries short: goal → what changed →
what was verified → what is next.

## Current state

- **Structure:** feature-first (see `docs/architecture.md`) — `autoload/`, `scenes/<feature>/`,
  `assets/{sprites,fonts,audio,source}/`, `docs/`, `tools/`.
- **Health:** `127 res:// paths checked | missing: 0`; headless import clean; 13 scenes load; runtime boots clean.
- **Branch:** `refactor/project-structure` (refactor complete, not yet merged to `main`).
- **Only autoload:** `GameManager`. **Main scene:** `scenes/menu/main_menu.tscn`.
- **Open work:** see `docs/backlog.md`.

---

## 2026-09-30 — Docs, rules and cleanup

**Goal:** turn the finished refactor into a self-documenting project that a fresh session can pick up.

**Changed**
- Added `AGENTS.md` + `.clinerules` (hard rules + pointers), `docs/conventions.md`, `docs/workflow.md`,
  `docs/backlog.md`, `docs/session-log.md`.
- Deleted `docs/refactor-plan.md` and `docs/refactor-progress.md` (one-shot artifacts; history preserved in git).
- Deleted 3 unattached scripts and the orphaned art left behind by the removed backup scene.
- Reserved `assets/audio/music/` and `assets/audio/sfx/` in the structure (folders created).

**Verified**
- All four checks in `docs/workflow.md` (reference check, headless import, 13-scene sweep, runtime boot).

**Next:** `docs/backlog.md`.

---

## 2026-09-30 — Project structure refactor

**Goal:** take the project from a flat 90-file root to a production-shaped Godot layout without breaking
a single reference.

**Changed** (branch `refactor/project-structure`)
- `7fc90ad` docs: architecture + refactor plan/progress (superseded by this file).
- `3e378dc` chore: removed `track_level_backup.tscn`, `defeatscene.png`, `creditmem (1).png` (+ sidecars).
- `dd534f5` refactor: 40 assets renamed to `snake_case` (77 files incl. sidecars), references rewritten in 42 files.
- `7e2042d` refactor: 75 resources moved into `autoload/`, `scenes/<feature>/`, `assets/sprites/*`; legacy
  `Main menu/` and `powerups/` folders removed.
- `c41d466` docs: completion + verification record.
- `b1f1edb` chore: added `tools/check_references.ps1`.

**Verified**
- `127 res:// paths checked | missing: 0`; `.import` sidecar audit clean; headless import 0 errors/0 warnings;
  all 13 scenes load clean; `project.godot` needed no edits (UID references survived).
- Two traps found and fixed: PowerShell's case-insensitive `-ne` silently skipping case-only renames, and Godot
  reassigning UIDs on re-import (restored original UIDs from `HEAD`).

**Next:** docs + cleanup (this entry above).
