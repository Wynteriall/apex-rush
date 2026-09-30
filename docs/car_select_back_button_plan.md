# Car Select — Back Button Implementation Plan

**Branch:** `feature/car-select-back-button` · **Date:** 2026-09-30 · **Status:** approved

## Goal

Add a visible **Back button** to the car selection scene (`scenes/menu/car_select.tscn` / `.gd`),
positioned top-left, that returns to the main menu (`scenes/menu/main_menu.tscn`).

## Context / findings

- **Scene flow:** `main_menu` → `car_select` → `loading_scene` → `track_level`
  (see `docs/architecture.md`). Menu-to-menu navigation already uses direct
  `get_tree().change_scene_to_file("res://scenes/menu/...")` — e.g. `main_menu.gd:_on_play_pressed` —
  so `GameManager.target_scene_path` (rule 8: the next *race* scene) is **not** involved here.
- **Existing back buttons** in `main_menu.tscn` (Help/Credits/Settings modals) are invisible flat
  hotspots that only close a modal — there is no reusable navigation back button. This is a new
  pattern, built from the same idioms: `@onready … get_node_or_null("Path")` + null-guarded
  `pressed.connect(...)`.
- **Background geometry:** `assets/sprites/ui/car_selection.png` is 14272×8960 (aspect ≈ 1.59),
  drawn with `stretch_mode = 5` (keep aspect centered) → in the 1280×720 viewport it renders at
  x ≈ 67..1213, full height. The red frame's inner top-left starts ≈ (110, 46); the "SELECT CAR"
  banner starts ≈ x 330. The region **(124, 60) → (264, 108)** is empty and clear of all art.
- **No back-arrow art exists** in `assets/sprites/ui/`, so the button must be a *visible styled
  button* (the existing Prev/Next/Select buttons are invisible hotspots over art).
- **No click SFX:** `assets/audio/{music,sfx}/` contain only `.gitkeep`; no `ClickSound` node exists
  in any scene — SFX is out of scope until audio assets land.
- **Font:** `Minecraft.ttf` is already `ExtResource("3_4atiy")` in `car_select.tscn` — reuse it.

## Changes

### 1. `scenes/menu/car_select.tscn`

- Two `sub_resource`s of type `StyleBoxFlat` (+ hover/pressed variants), palette matched to the art:
  - normal bg ≈ `Color(0.365, 0.145, 0.169, 1)` (dark maroon), border 2px ≈ `Color(0.788, 0.412, 0.443, 1)`
    (rose), corner radius 4, content margins 20/8.
  - hover = lighter maroon, pressed = darker maroon.
- New node **`BackButton`** (type `Button`, child of `CarSelect`), added right after `Backgorund`
  so it draws above the background:
  - `layout_mode = 0`, offsets `(124, 60) → (264, 108)` — **top-left**, inside the frame.
  - `mouse_default_cursor_shape = 2` (matches every other button).
  - `text = "BACK"`, `theme_override_fonts/font = ExtResource("3_4atiy")`, `font_size = 24`,
    cream `font_color` ≈ `Color(0.949, 0.871, 0.871, 1)`.
  - theme override styles: `normal` / `hover` / `pressed` → the `StyleBoxFlat` sub-resources.

### 2. `scenes/menu/car_select.gd`

```gdscript
const MAIN_MENU_SCENE: String = "res://scenes/menu/main_menu.tscn"   # top of file, conventions: one path per concern

@onready var back_btn: Button = get_node_or_null("BackButton")       # with the other @onready vars

# in _ready():
if back_btn:
    back_btn.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
    get_tree().change_scene_to_file(MAIN_MENU_SCENE)

# parity with main_menu.gd: Escape also goes back
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        _on_back_pressed()
```

## Verification (all four checks in `docs/workflow.md`)

1. `powershell -ExecutionPolicy Bypass -File tools/check_references.ps1` → `OK - all references resolve`
2. Headless `--import` → exit 0, 0 errors / 0 warnings (also proves the hand-edited `.tscn` parses).
3. Per-scene sweep → 13/13 scenes load clean.
4. Runtime boot `--quit-after 180` → no script errors.

## Commits (this branch)

1. `docs: add car select back button implementation plan` (this file)
2. `feat: add back button to car select scene` — `.tscn` + `.gd` (only after the four checks pass)
3. `docs: log car select back button session` — `docs/session-log.md` entry

## Assumptions / trade-offs

- Button position/size eyeballed from the art at 1280×720 — trivially nudged if it looks off in-game.
- StyleBoxes are inline in the `.tscn`; the project has no shared `Theme` resource (out of scope).
- Hand-added node carries a fresh `unique_id`; the scene sweep validates the file, and the Godot
  editor will reassign on next save if needed.
- This plan file is intentionally kept as a branch artifact; delete it before merge if it is judged a
  one-shot doc (history precedent: `docs/refactor-plan.md` was removed post-refactor).
