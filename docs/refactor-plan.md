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

- [ ] **Phase 5 — verification & progress log**
  - Godot headless import of the project with no script/scene errors
  - Manual flow check: menu → car select → loading → race → victory/defeat → back to menu
  - Update `refactor-progress.md`
  - Commit: `docs: record refactor completion and verification`

## Verification Commands

```powershell
# Reference sweep (run after phases 2, 3, 4)
Select-String -Path *.tscn,*.gd,*.tres,project.godot,scenes\*\*.tscn,scenes\*\*.gd -Pattern 'OLD_NAME'

# Godot headless validation
& "C:\Users\Ivan\Downloads\Godot_v4.7.2-stable_win64.exe" --headless --path . --import
```
