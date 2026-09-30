# Apex Rush — Architecture

Target file structure and conventions. **This is the source of truth** — new files must be created in the folder that matches their purpose.

## Target Structure

```
race/
├── docs/                        # Project documentation (not shipped)
├── tools/                       # Repo maintenance scripts (not shipped)
├── autoload/                    # Global singletons (registered in project.godot)
│   └── game_manager.gd          # GameManager: carries selected car + target scene between scenes
├── scenes/                      # Every gameplay/menu scene, grouped by feature
│   ├── menu/
│   │   ├── main_menu.tscn/.gd
│   │   ├── car_select.tscn/.gd
│   │   └── loading_scene.tscn/.gd
│   ├── race/
│   │   ├── track_level.tscn/.gd     # Main race scene: HUD, laps, positions, spawning
│   │   ├── player_car.tscn/.gd      # Player vehicle controller
│   │   ├── rival_path.gd            # Rival vehicle controller
│   │   ├── path_follow_2d.gd        # Rival path follower
│   │   ├── path_follow_2d_rival.gd  # Rival path follower (alternate)
│   │   └── camera_2d.gd             # Follow camera
│   ├── pickups/
│   │   ├── nitro_pickup.tscn/.gd    # Boost pickup
│   │   ├── oil_pickup.tscn/.gd      # Oil drop pickup
│   │   ├── oil_slick.tscn/.gd       # Oil hazard
│   │   └── shield_pickup.tscn/.gd   # Shield pickup
│   ├── effects/
│   │   ├── skid_mark.tscn + skid_marks.gd
│   │   └── impact_spark.tscn + impact_spark.gd
│   └── results/
│       ├── victory_scene.tscn/.gd
│       └── defeat_scene.tscn/.gd
└── assets/                      # Non-code resources
    ├── sprites/
    │   ├── cars/                # player_car, rival_car, new_car_1/2
    │   ├── track/               # race_track + props (trees, kerb, cones, tires, roofs, barriers)
    │   ├── ui/                  # menu art, counters, panels, loading/victory/defeat art
    │   ├── powerups/            # powerup frames + icons (booster, oil, shield)
    │   └── effects/             # smoke_puff, impact_spark, tire_skid_marks
    ├── fonts/                   # Minecraft.ttf
    └── source/                  # .piskel sources (art originals, excluded from exports)
```

Project-root files that stay put: `project.godot`, `default_bus_layout.tres`, `icon.svg`.

## Conventions

- **Folders & filenames:** `snake_case`, lowercase, no spaces or parentheses.
- **Scene + script colocation:** a scene and its script live in the same folder, script named after the scene (`player_car.tscn` + `player_car.gd`).
- **Assets:** grouped by consumer first (`cars`, `track`, `ui`, `powerups`), type second.
- **Source files:** anything not needed at runtime (`.piskel`) goes in `assets/source/`.
- **Autoloads:** only true global state; currently just `GameManager`.
- **References:** rely on `uid://` where possible; after any move/rename, re-grep for the old path string in `.tscn`/`.gd`.

## Reference Map (what points where)

- `project.godot` → main scene (`uid://bb8k3si8225ph`), autoload `GameManager` (`uid://cekeau5ms6uvd`), `res://icon.svg`
- `.tscn` files → `ext_resource path="res://..."` entries for scripts, textures, fonts and sub-scenes
- Scripts → `preload("res://...")` constants and `get_tree().change_scene_to_file("res://...")` calls
- Scene flow: `main_menu` → `car_select` → `loading_scene` → `track_level` → `victory_scene` / `defeat_scene`
