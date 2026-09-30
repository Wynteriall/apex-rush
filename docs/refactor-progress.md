# Apex Rush — Refactor Progress Log

Baseline: `main` @ `1369bb4` (clean tree, 148 tracked files).
Branch: `refactor/project-structure`.

| Phase | Status | Commit | Verified |
|---|---|---|---|
| 0 — branch | ✅ done | *(branch created)* | — |
| 1 — docs | ✅ done | *(this commit)* | files created |
| 2 — delete dead files | ✅ done | `3e378dc` | headless import OK |
| 3 — rename assets | ✅ done | *(this commit)* | 127/127 `res://` refs resolve, import + runtime exit 0, 0 warnings |
| 4 — move to feature-first | ✅ done | *(this commit)* | 127/127 refs resolve, 13/13 scenes load clean, import + runtime 0 errors |
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

## Phase 4 — Move Details

75 resources moved (scripts, scenes, sprites, font, art sources), each carrying its `.import` / `.uid` sidecar;
63 files had `res://` references rewritten. Legacy `Main menu/` and `powerups/` folders removed (now empty).
Root now contains only `project.godot`, `default_bus_layout.tres`, `icon.svg` (+ dot-files) and `docs/`.

```
race/
├── autoload/ game_manager.gd
├── scenes/  menu(3) race(5 scenes+5 scripts) pickups(4) effects(2) results(2)
├── assets/  sprites/{cars(4) track(13) ui(14) powerups(6) effects(4)} fonts/ source/
└── docs/
```

UID safety: the autoload UID lives in `game_manager.gd.uid` and the main-scene UID in `main_menu.tscn`'s
header, so both `project.godot` references survived the move untouched (verified by grep before moving).

### Validation performed (after moves)

- `res://` reference resolver: **127 refs checked, 0 missing**
- `.import` sidecar audit: **0 problems**
- Godot 4.7.2 `--headless --import` (2 runs, uid cache cleared): exit 0, **0 errors / 0 warnings**
- **All 13 scenes** loaded individually with `--headless --quit-after 90`: exit 0, **0 errors each**
  (no `ERROR`, `SCRIPT ERROR`, `invalid UID`, `non-existent resource`)
- Main scene runtime `--headless --quit-after 180`: exit 0, **0 errors**
- Scene-transition and `preload()` targets manually inspected — all point at the new locations
  (`res://scenes/menu/...`, `res://scenes/race/...`, `res://scenes/results/...`, `res://assets/sprites/...`)

### Baseline comparison (regression guard)

`loading_scene.tscn` prints `WARNING: 6 ObjectDB instances were leaked at exit`. Reproduced **identically on the
unrefactored `main` branch** (via a throwaway `git worktree`) in 3/3 runs → pre-existing, caused by the pending
`await get_tree().create_timer(0.6).timeout` in `loading_scene.gd:48` being interrupted by forced shutdown.
Not a refactor regression.

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
