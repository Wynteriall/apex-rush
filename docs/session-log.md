# Apex Rush — Session Log

Append-only history of work sessions. Newest entries **on top**. Keep entries short: goal → what changed →
what was verified → what is next.

## Current state

- **Structure:** feature-first (see `docs/architecture.md`) — `autoload/`, `scenes/<feature>/`,
  `assets/{sprites,fonts,audio,source}/`, `docs/`, `tools/`.
- **Health:** `122 res:// paths checked | missing: 0`; headless import clean; 13 scenes load; runtime boots clean.
  (The count dropped from 127 to 122 because five `.import` sidecars were deleted — each one counted a `res://`
  `source_file` entry.)
- **Branch:** `feature/car-select-back-button` — car select back button implemented and verified; ready to
  review/merge into `main`. (`main` itself is clean: the refactor is merged.)
- **Only autoload:** `GameManager`. **Main scene:** `scenes/menu/main_menu.tscn`.
- **Open work:** see `docs/backlog.md`.
- **Non-issue to expect:** the Godot **editor** caches the file list in `.godot/editor/filesystem_cache10`.
  After a set of renames it can still show old names (`main_menu_1.png`, `menu_preview.png`) in the
  FileSystem dock. Close and reopen the project; if entries persist, delete the whole `.godot/` folder and let
  it re-import. `.godot/` is generated and git-ignored — never edit it by hand.

---

## 2026-09-30 — Car select back button

**Goal:** give `car_select` a visible top-left Back button that returns to the main menu, on the branch
`feature/car-select-back-button`.

**Changed** (branch `feature/car-select-back-button`)
- `634f97a` docs: added `docs/car_select_back_button_plan.md` — the approved implementation plan.
- `3621a84` feat: `scenes/menu/car_select.tscn` gained a `BackButton` node at (124, 60)–(264, 108), just
  inside the frame's top-left (clear of the SELECT CAR banner): text "BACK", Minecraft font 24px, three
  inline `StyleBoxFlat`s (maroon fill / rose border) matched to `car_selection.png`.
- `scenes/menu/car_select.gd`: `MAIN_MENU_SCENE` const, `back_btn` via `get_node_or_null`, null-guarded
  `pressed.connect` (the `main_menu.gd` idiom), `_on_back_pressed()` → `change_scene_to_file`, and
  `ui_cancel` (Escape) → back for parity with `main_menu.gd`.

**Verified**
- All four checks in `docs/workflow.md`: `123 res:// paths checked | missing: 0` (+1 for the new const),
  headless import exit 0 with 0 errors/0 warnings, per-scene sweep **13/13 OK** (exit 0, no error output),
  runtime boot `--quit-after 180` exit 0, no script errors.

**Next:** eyeball the button position in the editor, review and merge the branch into `main`.

---

## 2026-09-30 — Branch merged to `main`

**Goal:** close the refactor out so a new session starts from a clean `main` instead of a long-lived branch.

**Changed**
- `docs/conventions.md`: the "numbered variants" example pointed at `main_menu_1.png`, a file the asset cleanup
  renamed away — it now uses `broadleaf_tree_2.png`, which exists and is actually referenced.
- `docs/workflow.md`: expected baseline corrected from `127` to `122` `res://` paths, with a note on why the
  number moved and how to read a change (lower = a reference disappeared, higher = new references).

**Verified**
- Clean fast-forward: `main` was 10 commits behind and 0 ahead, so no conflicts were possible. Pushed to
  `origin/main`; the now-redundant local branch was deleted.
- One check beyond the four in `workflow.md`: every `uid="uid://…"` reference in `.tscn` / `project.godot`
  cross-checked against the owning `.import` / `.uid` sidecar — **58 references, 0 problems**, and both
  `project.godot` UIDs resolve (`→ main_menu.tscn`, `→ game_manager.gd`). `tools/check_references.ps1` only
  checks `res://` paths, not UID-vs-path agreement, so after a rename it is worth re-checking UIDs by hand.

**Next:** feature work on a fresh branch (audio is the obvious one — `assets/audio/music/`, `assets/audio/sfx/`
and the `Music` / `SFX` buses already exist, see `docs/conventions.md`). The stray fourth bus named `Volume` in
`default_bus_layout.tres` is still there and is still meaningless.

---

## 2026-09-30 — Docs, rules and cleanup

**Goal:** turn the finished refactor into a self-documenting project that a fresh session can pick up.

**Changed**
- Added `AGENTS.md` + `.clinerules` (hard rules + pointers), `docs/conventions.md`, `docs/workflow.md`,
  `docs/backlog.md`, `docs/session-log.md`.
- Deleted `docs/refactor-plan.md` and `docs/refactor-progress.md` (one-shot artifacts; history preserved in git).
- Deleted 3 unattached scripts (`camera_2d.gd`, `path_follow_2d.gd`, `path_follow_2d_rival.gd`).
- Deleted 5 superseded art files after eyeballing each against its in-use counterpart, renamed 3 assets whose
  names were stale or wrong, and reserved `assets/audio/music/` + `assets/audio/sfx/`.
- Refreshed `docs/architecture.md` to the real tree plus a "Where do I put a new file?" table.

**Verified**
- All four checks in `docs/workflow.md`: `122 res:// paths / 0 missing`, 0 sidecar problems, headless import
  0 errors/0 warnings, 13/13 scenes load, runtime boot clean. UIDs preserved through every rename.

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
