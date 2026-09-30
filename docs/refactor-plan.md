# Apex Rush — Refactor Plan

Goal: reorganize the flat project root into the feature-first structure described in `architecture.md`, **without breaking any scene reference or the playable flow**.

Branch: `refactor/project-structure` (branched from clean `main` @ `1369bb4`).

Rules:
- One phase = one commit. Never mix phases.
- Every phase ends with a reference grep + Godot import validation before committing.
- On a broken phase: fix it, or revert that phase only (`git revert` / `git reset --hard` the single commit). Do not stack a second phase on top of a broken one.

## Phases

- [x] **Phase 0 — branch**
  - `git checkout -b refactor/project-structure`
  - Commit: *(none, branch only)*

- [x] **Phase 1 — docs**
  - Create `docs/` with `architecture.md`, `refactor-plan.md`, `refactor-progress.md`
  - Commit: `docs: add architecture and refactor plan`

- [x] **Phase 2 — delete dead files**
  - Delete `track_level_backup.tscn`, `defeatscene.png`, `creditmem (1).png` (+ their `.import` files)
  - Pre-check: grep each name in `*.tscn` / `*.gd` → must be 0 hits
  - Commit: `chore: remove unused backup and duplicate assets`

- [x] **Phase 3 — rename assets to snake_case**
  - Rename every asset with spaces/parens/typos; update `ext_resource path=` in `.tscn` and `preload()` strings in `.gd`
  - Notable: `loadaing.png` → `loading.png`, `b2bc970b-..._removalai_preview.png` → `menu_preview.png`, `Shiled_Frames.png` → `shield_frames.png`
  - Post-check: grep every old filename across `*.tscn`/`*.gd`/`*.tres` → 0 hits
  - Commit: `refactor: rename assets to snake_case`

- [x] **Phase 4 — move into feature-first structure**
  - Move scripts/scenes into `scenes/{menu,race,pickups,effects,results}/`
  - Move `game_manager.gd` into `autoload/`
  - Move assets into `assets/{sprites/{cars,track,ui,powerups},fonts,source}/`
  - Update every `res://` path reference touched by the moves
  - Post-check: grep old paths → 0 hits; `project.godot` autoload + main scene still resolve
  - Commit: `refactor: reorganize project into feature-first structure`

- [x] **Phase 5 — verification & progress log**
  - Godot headless import of the project with no script/scene errors
  - Manual flow check: menu → car select → loading → race → victory/defeat → back to menu
  - Update `refactor-progress.md`
  - Commit: `docs: record refactor completion and verification`

## Verification Commands

```powershell
# Reference integrity: every res:// path resolves, .import sidecars intact
powershell -ExecutionPolicy Bypass -File tools/check_references.ps1
#    -> "OK - all references resolve" / exit 0, or a list of MISSING refs

# Godot headless import (must exit 0 with no ERROR/WARNING/invalid UID)
& $godot --headless --path . --import

# Runtime: boot the main scene for 180 frames (must exit 0, no script errors)
& $godot --headless --path . --quit-after 180

# Load every scene individually - catches broken ext_resource refs per scene
Get-ChildItem -Recurse -File -Filter '*.tscn' | Where-Object { $_.FullName -notmatch '\\\.godot\\' } |
  ForEach-Object { $rel = $_.FullName.Replace((Get-Location).Path + '\','').Replace('\','/')
    & $godot --headless --path . "$rel" --quit-after 90 }
```

`$godot` = `C:\Users\Ivan\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`

> Note: `git grep` is unreliable while moves/renames are unstaged (it reads tracked paths), and PowerShell's
> `-ne`/`-eq` are case-**in**sensitive - use `[string]::Equals(..., [StringComparison]::Ordinal)` for path
> comparisons, or a case-only rename will be silently skipped.
