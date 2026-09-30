# Apex Rush — Architecture

**Source of truth for where files live.** New files must be created in the folder that matches their purpose —
never in the project root. Session entry point: `AGENTS.md`.

## Tree

```
race/
├── AGENTS.md                    # hard rules + doc pointers (start here)
├── .clinerules                  # short pointer to AGENTS.md
├── project.godot                # main scene + autoload + input map (refers by uid://)
├── default_bus_layout.tres      # audio buses: Master / Music / SFX / Volume
├── icon.svg
├── autoload/
│   └── game_manager.gd          # GameManager: carries selected car + target scene between scenes
├── scenes/                      # Every gameplay/menu scene, grouped by feature
│   ├── menu/
│   │   ├── main_menu.tscn/.gd       # play, settings / credits / help modals
│   │   ├── car_select.tscn/.gd      # car picker
│   │   └── loading_scene.tscn/.gd   # pre-race loading screen
│   ├── race/
│   │   ├── track_level.tscn/.gd     # Main race scene: HUD, laps, positions, spawning
│   │   ├── player_car.tscn/.gd      # Player vehicle controller
│   │   └── rival_path.gd            # Rival vehicle controller (AI)
│   ├── pickups/
│   │   ├── nitro_pickup.tscn/.gd    # Boost pickup
│   │   ├── oil_pickup.tscn/.gd      # Oil drop pickup
│   │   ├── oil_slick.tscn/.gd       # The hazard an oil pickup leaves behind
│   │   └── shield_pickup.tscn/.gd   # Shield pickup
│   ├── effects/
│   │   ├── skid_mark.tscn + skid_marks.gd
│   │   └── impact_spark.tscn/.gd
│   └── results/
│       ├── victory_scene.tscn/.gd
│       └── defeat_scene.tscn/.gd
├── assets/                      # Non-code resources
│   ├── sprites/
│   │   ├── cars/                # player_car, rival_car, new_car_1/2
│   │   ├── track/               # race_track + props (trees, kerb, cones, tires, roofs, barriers)
│   │   ├── ui/                  # menu + screen art, modals, counters, loading/victory/defeat
│   │   ├── powerups/            # *_frames.png (animation sheets) + *_icon.png (HUD icons)
│   │   └── effects/             # smoke_puff, impact_spark, tire_skid_marks
│   ├── fonts/                   # Minecraft.ttf
│   ├── audio/
│   │   ├── music/               # music tracks
│   │   └── sfx/                 # sound effects
│   └── source/                  # .piskel art originals (never loaded at runtime)
├── docs/                        # Project documentation (not shipped)
└── tools/                       # Repo maintenance scripts (not shipped)
```

Project-root files that stay put: `project.godot`, `default_bus_layout.tres`, `icon.svg`, `AGENTS.md`,
`.clinerules`, `.gitattributes`, `.editorconfig`.

**Unwired art kept on purpose** (tracked in `docs/backlog.md`): `track/racee.png` (an alternate track layout)
and `track/armco_guardrail.png` (a second barrier prop). Neither has an in-use equivalent, so they are *not*
dead duplicates — check the backlog before deleting anything that has zero references.

## Where do I put a new file?

| I am adding… | It goes in… | Notes |
|---|---|---|
| A gameplay/menu screen | `scenes/<feature>/` | new feature ⇒ new `snake_case` folder |
| A script that only serves one scene | next to that scene, same name | `player_car.tscn` + `player_car.gd` |
| Global / cross-scene state | `autoload/` | needs a `project.godot` **and** this doc updated |
| A car sprite | `assets/sprites/cars/` | + the `.piskel` original in `assets/source/` |
| Track or track prop art | `assets/sprites/track/` | |
| Menu / HUD / screen art | `assets/sprites/ui/` | |
| Powerup sheet or icon | `assets/sprites/powerups/` | `_frames` = animation sheet, `_icon` = HUD icon |
| A short-lived visual effect | `assets/sprites/effects/` | |
| Music | `assets/audio/music/` | route playback to the `Music` bus |
| A sound effect | `assets/audio/sfx/` | route playback to the `SFX` bus |
| A repo script or check | `tools/` | PowerShell, not shipped |
| Project documentation | `docs/` | |

Naming, code style and input/physics conventions live in `docs/conventions.md`.

## Reference Map (what points where)

- `project.godot` → main scene (`uid://bb8k3si8225ph`), autoload `GameManager` (`uid://cekeau5ms6uvd`),
  `res://icon.svg`
- `.tscn` files → `ext_resource` entries for scripts, textures, fonts and sub-scenes; each entry carries a
  `uid=` **and** a `path=`, so a moved asset stays resolvable as long as its sidecar `uid=` is untouched
- Scripts → `preload("res://...")` constants and `get_tree().change_scene_to_file("res://...")` calls
- `GameManager` → carries the selected car and the next scene between scenes
- Scene flow: `main_menu` → `car_select` → `loading_scene` → `track_level` → `victory_scene` / `defeat_scene`

## Deleted — do not resurrect

Removed during the 2026-09 cleanup; each was verified unreferenced *and* superseded before deletion. Recover
any of them from git history (`git log --diff-filter=D --name-only`) if a real need appears.

- `track_level_backup.tscn` (+ the art only it referenced)
- `camera_2d.gd`, `path_follow_2d.gd`, `path_follow_2d_rival.gd` — unattached scripts
- Superseded art variants: `ui/main_menu.png`, `ui/credits.png`, `ui/impact_sparks.png`,
  `effects/exhaust_smoke_2.png`, `track/marshal_post.png`
- Renamed away: `menu_preview.png` → `credits_panel.png` (it is the credits modal art, the old name was wrong)
