# Apex Rush — Refactor Progress Log

Baseline: `main` @ `1369bb4` (clean tree, 148 tracked files).
Branch: `refactor/project-structure`.

| Phase | Status | Commit | Verified |
|---|---|---|---|
| 0 — branch | ✅ done | *(branch created)* | — |
| 1 — docs | ✅ done | *(this commit)* | files created |
| 2 — delete dead files | ✅ done | `3e378dc` | headless import OK |
| 3 — rename assets | ✅ done | *(this commit)* | 127/127 `res://` refs resolve, import + runtime exit 0, 0 warnings |
| 4 — move to feature-first | ⬜ pending | — | — |
| 5 — verify + log | ⬜ pending | — | — |

## Notes / Decisions

- `loadaing.png` and `b2bc970b-..._removalai_preview.png` were **not** deleted — they are actively referenced by `loading_scene.tscn` and `main_menu.tscn`; they are renamed in Phase 3 instead.
- `creditmem (1).png` confirmed unreferenced (only `Credits.png` art exists separately) → deleted in Phase 2.
- Godot binary used for validation: `C:\Users\Ivan\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe` (4.7.2, matches `project.godot` feature tag `4.7`). Note the `Downloads\Godot_v4.7.2-stable_win64.exe` entry is a folder, not the binary.
- Validation command: `& $godot --headless --path . --import` → must exit 0 with no script/scene parse errors.
- Runtime smoke test: `& $godot --headless --path . --quit-after 180` → exit 0, no script errors.

## Phase 3 — Rename Details

40 assets renamed to `snake_case` (77 files incl. `.import` sidecars); 42 files had references rewritten
(`.tscn` `ext_resource path=`, `.gd` `preload()` / `change_scene_to_file()`, `.import` `source_file`/`dest_files`).
Full old→new list lives in the rename script (`%TEMP%\apex_phase3_rename.ps1`), key examples:

| old | new |
|---|---|
| `playerr.png` | `player_car.png` |
| `Rival_Car.png` | `rival_car.png` |
| `Shiled_Frames.png` | `shield_frames.png` |
| `loadaing.png` | `loading.png` |
| `b2bc970b-..._removalai_preview.png` | `menu_preview.png` |
| `upd impact.png` | `impact_spark.png` |
| `upd smoke.png` | `smoke_puff.png` |
| `NewCar1.png` / `NewCar2.png` | `new_car_1.png` / `new_car_2.png` |
| `Main menu/MAIN MENU (1).png` | `Main menu/main_menu_1.png` |
| `powerups/Booster_FRAMES.png` | `powerups/booster_frames.png` |

### Orphaned artwork (unreferenced, kept deliberately)

These were only referenced by the deleted `track_level_backup.tscn`, so they are now unused but were **kept**
as an art library. Decide later whether to delete or wire them up:
`racee.png`, `armco_guardrail.png`, `credits.png`, `impact_sparks.png`, `marshal_post.png`,
`exhaust_smoke_2.png`, `Main menu/main_menu.png`, plus `.piskel` sources.

### Validation performed

- `res://` reference resolver over every `.tscn`/`.gd`/`.tres`/`.import`/`project.godot`: **127 refs checked, 0 missing**
- `.import` sidecar audit: every `source_file` exists and matches its sidecar name: **0 problems**
- Godot 4.7.2 `--headless --import`: exit 0, **0 errors / 0 warnings** (two consecutive runs)
- Godot 4.7.2 `--headless --quit-after 180` (boots `main_menu.tscn`): exit 0, no script errors

## Issues Encountered

1. **PowerShell `-ne` is case-insensitive** → the first rewrite pass silently skipped all *case-only* renames
   (e.g. `Shield_ICON.png` → `shield_icon.png`), leaving 3 `.tscn` files stale.
   Fix: compare with `[string]::Equals($a, $b, [StringComparison]::Ordinal)`.
2. **Godot reassigned UIDs** for the 6 re-imported assets, so scenes referencing the original UIDs logged
   `invalid UID ... using text path instead` (worked, but noisy).
   Fix: restored the original `uid=` values in those `.import` sidecars from `HEAD`, then deleted the
   regenerable `.godot/uid_cache.bin`. Result: 0 warnings, and no UID churn in any `.tscn`.
3. `Downloads\Godot_v4.7.2-stable_win64.exe` is a **folder**, not the executable — the binary is inside it
   (use `Godot_v4.7.2-stable_win64_console.exe` for terminal output).
