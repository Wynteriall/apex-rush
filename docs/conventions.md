# Apex Rush — Conventions

Rules for naming and writing code, scenes and art. If something here is wrong or missing, fix this file in
the same commit as the change that made it wrong.

## Naming

| Thing | Rule | Example |
|---|---|---|
| Folders, files (script / scene / asset) | `snake_case`, lowercase, no spaces or parentheses | `player_car.tscn`, `broadleaf_tree.png` |
| Numbered variants | trailing `_1`, `_2` | `main_menu_1.png` |
| GDScript class / node names | `PascalCase` | `PlayerCar`, `SkidMark` |
| Variables & parameters | `snake_case` | `lap_count` |
| Constants | `SCREAMING_SNAKE_CASE` | `OIL_SLICK_SCENE` |
| Private members | leading underscore | `_current_lap` |
| Signals | `snake_case`, past tense | `lap_completed` |
| Autoload | `PascalCase` and used as a singleton | `GameManager` |

## Scene & script rules

- Scene and script live in the same feature folder and share a name (`oil_slick.tscn` + `oil_slick.gd`).
  Known exception to fix when touched: `skid_mark.tscn` + `skid_marks.gd` (see `backlog.md`).
- Use typed GDScript everywhere (`var speed: float`, `func _ready() -> void:`) — all existing scripts are typed.
- Prefer `@onready var x: Type = $Path` over repeated `get_node()` calls.
- `preload()` for resources you always need; `@export` when a designer should be able to swap the asset.
- Keep each `res://` path string in exactly one place per concern (a `const` at the top of the script).
- `auto_load` only for true global state; anything scene-local stays in the scene's script.

## Feature folders

| Folder | Contains |
|---|---|
| `scenes/menu/` | main menu, car select, loading screen — the pre-race flow |
| `scenes/race/` | the race itself: track, player car, rivals, camera |
| `scenes/pickups/` | things picked up or left on the track (nitro, oil, oil slick, shield) |
| `scenes/effects/` | short-lived visuals (skid marks, impact sparks) |
| `scenes/results/` | victory and defeat screens |
| `autoload/` | `game_manager.gd` only |

## Input actions (`project.godot`)

| Action | Player 1 | Player 2 |
|---|---|---|
| up | `p1_up` → ↑ | `p2_up` → `W` |
| down | `p1_down` → ↓ | `p2_down` → `S` |
| left | `p1_left` → ← | `p2_left` → `A` |
| right | `p1_right` → → | `p2_right` → `D` |
| boost | `p1_boost` → `Shift` | `p2_boost` → `Shift` (shared key) |

Deadzone is `0.2` on all actions. Values are physical keycodes in `project.godot` (arrows = 4194319-4194322,
`Shift` = 4194325, `WASD` = 87/83/65/68).

## Physics layers (`project.godot` → `layer_names`)

| Bit | Name | Used for |
|---|---|---|
| 1 | `Cars` | player + rival bodies |
| 2 | `Track_Roadway` | drivable surface |
| 3 | `Track_Boundaries` | walls / off-track |

## Rendering, audio, misc

- Texture filter is **nearest** (`default_texture_filter=0`) — pixel art must stay crisp, never enable filtering.
- Stretch mode `canvas_items` + integer scaling; author UI at 1280x720.
- Audio buses (`default_bus_layout.tres`): `Master`, `Music`, `SFX`, `Volume` — route new sounds to `Music`
  or `SFX`, never straight to `Master`.
- Audio assets live in `assets/audio/music/` and `assets/audio/sfx/`.
- Art sources (`.piskel`) live in `assets/source/` and are never loaded at runtime.
