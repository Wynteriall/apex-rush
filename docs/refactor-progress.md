# Apex Rush — Refactor Progress Log

Baseline: `main` @ `1369bb4` (clean tree, 148 tracked files).
Branch: `refactor/project-structure`.

| Phase | Status | Commit | Verified |
|---|---|---|---|
| 0 — branch | ✅ done | *(branch created)* | — |
| 1 — docs | ✅ done | *(this commit)* | files created |
| 2 — delete dead files | ✅ done | *(this commit)* | headless import OK |
| 3 — rename assets | ⬜ pending | — | — |
| 4 — move to feature-first | ⬜ pending | — | — |
| 5 — verify + log | ⬜ pending | — | — |

## Notes / Decisions

- `loadaing.png` and `b2bc970b-..._removalai_preview.png` were **not** deleted — they are actively referenced by `loading_scene.tscn` and `main_menu.tscn`; they are renamed in Phase 3 instead.
- `creditmem (1).png` confirmed unreferenced (only `Credits.png` art exists separately) → deleted in Phase 2.
- Godot binary used for validation: `C:\Users\Ivan\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe` (4.7.2, matches `project.godot` feature tag `4.7`). Note the `Downloads\Godot_v4.7.2-stable_win64.exe` entry is a folder, not the binary.
- Validation command: `& $godot --headless --path . --import` → must exit 0 with no script/scene parse errors.

## Issues Encountered

*(none yet)*
