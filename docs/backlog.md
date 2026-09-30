# Apex Rush — Backlog

Known gaps and deferred work. **These are not plans** — nothing here is scheduled. When you pick one up,
move it to a `docs/session-log.md` entry and delete it from this list.

| ID | Item | Why it matters | Effort |
|---|---|---|---|
| BL-01 | `assets/sprites/track/racee.png` is unreferenced art of an **alternate track layout** (jagged, vs the smooth live `race_track.png`) | Either wire it up as a second track or delete it; the name `racee` is meaningless — rename to something like `race_track_alt.png` | S |
| BL-10 | `assets/sprites/track/armco_guardrail.png` is an unreferenced barrier strip (the track uses `crash_cushion_barrier.png`) | Decide whether the guardrail belongs in the track prop set or gets deleted | S |
| BL-02 | `skid_mark.tscn` pairs with `skid_marks.gd` (singular vs plural) | Breaks the scene-script naming rule | S |
| BL-03 | `scenes/race/rival_path.gd` is the rival **car controller**, not a path helper | Misleading name for the main AI script | S |
| BL-04 | `scenes/race/track_level.gd` (283 lines) and `player_car.gd` (236 lines) are doing a lot | Candidate for splitting HUD / lap logic / spawn logic into their own scenes or helper scripts | M |
| BL-05 | No `export_presets.cfg` in the repo | Needed before any real build/export | S |
| BL-06 | UI art is heavy: `car_selection.png` 2.4 MB, `main_menu_1.png` 575 KB, victory/defeat ~400 KB each | Import presets / compression will shrink the shipped build a lot | M |
| BL-07 | `.editorconfig` only sets `charset = utf-8` | Could encode GDScript formatting rules (tabs, EOL) for consistent edits | S |
| BL-08 | Pre-existing `ObjectDB instances were leaked at exit` on `loading_scene.tscn` | Harmless shutdown warning from a pending `create_timer`; fix only if it becomes noise | S |
| BL-09 | No automated tests or CI | The four checks in `docs/workflow.md` are manual; a script could run them in one command | M |

## Deleted in the 2026-09 cleanup (recoverable from git history)

Do not re-add any of these without a reason; restore one with `git checkout <commit>^ -- <path>`.

- Unattached scripts: `camera_2d.gd`, `path_follow_2d.gd`, `path_follow_2d_rival.gd` (0 refs by name *and* UID).
- `track_level_backup.tscn` and the art only it referenced.
- Superseded art variants, deleted only after a visual pass confirmed the content already lives in a used asset:
  `ui/main_menu.png` (684 KB, old light theme), `ui/credits.png` (263 KB, full-screen credits mock — the
  shipped `CreditsModal` renders `credits_panel.png`), `ui/impact_sparks.png` (colour variant of
  `effects/impact_spark.png`, and misfiled under `ui/`), `effects/exhaust_smoke_2.png` (variant of
  `effects/smoke_puff.png`; the `.piskel` source is still in `assets/source/`), `track/marshal_post.png`
  (duplicate of the used marshal post).
