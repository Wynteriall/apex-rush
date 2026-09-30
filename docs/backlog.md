# Apex Rush — Backlog

Known gaps and deferred work. **These are not plans** — nothing here is scheduled. When you pick one up,
move it to a `docs/session-log.md` entry and delete it from this list.

| ID | Item | Why it matters | Effort |
|---|---|---|---|
| BL-01 | `assets/sprites/track/racee.png` has an unclear name (looks like a typo of "race") | Unreadable naming; content needs identifying then renaming or deleting | S |
| BL-02 | `skid_mark.tscn` pairs with `skid_marks.gd` (singular vs plural) | Breaks the scene-script naming rule | S |
| BL-03 | `scenes/race/rival_path.gd` is the rival **car controller**, not a path helper | Misleading name for the main AI script | S |
| BL-04 | `scenes/race/track_level.gd` (283 lines) and `player_car.gd` (236 lines) are doing a lot | Candidate for splitting HUD / lap logic / spawn logic into their own scenes or helper scripts | M |
| BL-05 | No `export_presets.cfg` in the repo | Needed before any real build/export | S |
| BL-06 | UI art is heavy: `car_selection.png` 2.4 MB, `main_menu_1.png` 575 KB, victory/defeat ~400 KB each | Import presets / compression will shrink the shipped build a lot | M |
| BL-07 | `.editorconfig` only sets `charset = utf-8` | Could encode GDScript formatting rules (tabs, EOL) for consistent edits | S |
| BL-08 | Pre-existing `ObjectDB instances were leaked at exit` on `loading_scene.tscn` | Harmless shutdown warning from a pending `create_timer`; fix only if it becomes noise | S |
| BL-09 | No automated tests or CI | The four checks in `docs/workflow.md` are manual; a script could run them in one command | M |

## Removed candidates (already cleaned up)

- 3 unattached scripts (`camera_2d.gd`, `path_follow_2d.gd`, `path_follow_2d_rival.gd`) — deleted, recoverable
  from git history.
- Orphaned art that only the deleted `track_level_backup.tscn` referenced — deleted, recoverable from git
  history (`git log --diff-filter=D --name-only -- 'assets/*'`).
