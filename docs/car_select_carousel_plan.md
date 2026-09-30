# Apex Rush - Car Select Carousel Plan

**Branch:** `feature/car-select-carousel` **Scene:** `scenes/menu/car_select.tscn` + `car_select.gd`

## Goal

Replace the single static car on the car select screen with a three-across carousel: the selected car
sits in the middle at full size and brightness, its two neighbours sit left and right, smaller and
dimmed. Pressing an arrow slides the whole row one place so a neighbour becomes the selection.

## Non-goals

- No change to the car roster, the SELECT flow, `GameManager.selected_car_texture`, or the transition to
  `loading_scene.tscn`.
- No sound effects.
- No new art, no new autoload, no new folder.

## Facts the design is built on

Three measurements drive every number below, all checked against the assets rather than assumed:

1. **The car textures are authored nose-RIGHT.** `player_car.png` and `rival_car.png` are 32x32 with
   opaque pixels only in `y[8..23]`; `new_car_1.png` is `y[7..24]`, `new_car_2.png` is `y[6..23]`. Every
   car is a ~2:1 landscape shape inside a square texture: the car already lies on its side with its nose
   at +X. Nothing in the scene, the script, `project.godot` or the `.import` sidecars applies rotation, so
   what is on screen is exactly what the artist drew.
2. **A half turn is therefore the correct rotation** to make the cars point left: 180, not -90.
3. **The panel art** (`car_selection.png`, 14272x8960) lands at roughly x 192..1088, y 119..380 once
   `KEEP_ASPECT_COVERED` has cropped it to 1280x720, i.e. centred near (640, 250). The arrow glyphs sit at
   about x 320..336 and x 944..960.

## Orientation is one editable value

The most likely thing to need changing, so it is a first-class Inspector-editable control rather than a
buried constant:

```gdscript
enum Facing { NOSE_RIGHT = 0, NOSE_DOWN = 90, NOSE_LEFT = 180, NOSE_UP = 270 }

@export var car_facing: Facing = Facing.NOSE_LEFT:
	set(value):
		car_facing = value
		_apply_facing()
```

The enum values *are* the degrees, so `rotation_degrees = float(car_facing)` needs no lookup table, and
the Inspector shows a four-item dropdown. Changing it re-applies live to every slot. If 180 turns out to
be wrong, pick another entry - no code edit and no reselect of the scene.

## Belt model

`car_roster.size()` is 4; five `TextureRect` slots sit on a conceptual belt at offsets
`[-2, -1, 0, +1, +2]` from the middle slot:

| Offset | Role |
|---|---|
| -1 | visible, left, dimmed + scaled |
| 0 | visible, middle, full size |
| +1 | visible, right, dimmed + scaled |
| -2 / +2 | off-screen *staging* slots, alpha 0 |

The two staging slots are what make the wrap seamless in **both** directions: whichever end a car leaves
by, the opposite staging slot already holds the car about to arrive, so the incoming car is always
animated in rather than popped in. A 4-slot version is possible but needs direction-specific
pre-staging; the fifth slot buys one uniform code path for both arrows.

Slot `i` shows `car_roster[posmod(current_index + offset_i, 4)]` and is drawn at
`CAROUSEL_CENTER + Vector2(offset_i * SLOT_SPACING, 0)`.

### Sliding

Pressing **next** does `current_index += 1` and shifts every `offset_i -= 1` (**prev**: `current_index -= 1`,
`offset_i += 1`). Because `(current_index + direction) + (offset - direction) == current_index + offset`,
**every slot keeps its texture through the shift**. The only slot whose content changes is the one
recycled from one staging end to the other, and it is invisible at both ends. That is why no car pops.

A slide is one parallel tween per moving slot over `position`, `scale` and `modulate`; the recycled slot
is *snapped* instead of tweened. Buttons are disabled and `_is_sliding` latched for the duration.

## Constants

| Constant | Value | Why |
|---|---|---|
| `CAROUSEL_CENTER` | `Vector2(640, 250)` | x centres the row on the panel art; y matches the panel middle |
| `SLOT_SPACING` | `230` | keeps the scaled side cars (144 wide, so +/-72) clear of the arrow glyphs at x ~336 / ~944 |
| `SLOT_SIZE` | `240` | must stay **square** - the 32x32 texture is fitted into it and the square is what rotation pivots around |
| `SIDE_SCALE` | `0.6` | side cars read as secondary |
| `SIDE_ALPHA` | `0.45` | dimmed, per the brief |
| `SLIDE_DURATION` | `0.32` | one slot per press, snappy |
| `SLIDE_TRANS` / `SLIDE_EASE` | `TRANS_CUBIC` / `EASE_IN_OUT` | settles rather than stopping dead |

## Why the slot must stay square

`expand_mode = 1` (`EXPAND_IGNORE_SIZE`) plus `stretch_mode = 5` (`KEEP_ASPECT_CENTERED`) fits the square
texture into the rect and centres it. With a square rect the 240x240 render holds the car as 240x120 with
its real margins intact; a non-square rect would crop or letterbox it. Rotation and scale both hinge on
`pivot_offset = Vector2(120, 120)`, the slot centre, so a 180 turn maps the square onto itself and the car
does not drift.

## Files

| File | Change |
|---|---|
| `scenes/menu/car_select.tscn` | `CarDisplay` (one `TextureRect`) becomes `Carousel` (a mouse-ignoring `Control`) holding `CarSlot0`..`CarSlot4`: five 240x240 `TextureRect`s, `pivot_offset` 120/120, `expand_mode=1`, `stretch_mode=5`, `mouse_filter=2`. Child order is belt order; z-order is unchanged (above the background, below `PrevButton`). |
| `scenes/menu/car_select.gd` | Tuning block, `Facing` export, five-slot belt, tweened `_slide()`, name-label cross-fade. Roster, SELECT flow and Escape behaviour untouched. |
| `docs/architecture.md` | One line: describe `car_select.tscn/.gd` as a carousel. |

The slots carry no texture in the `.tscn`; `_ready()` assigns all five. That avoids adding
`ext_resource` entries - and therefore UID risk (see the `.godot/uid_cache` gotcha in `docs/workflow.md`) -
for textures the script overwrites anyway.

## Verification

The four checks in `docs/workflow.md`, then in the running game: each arrow slides one place in the right
direction, the wrap works from index 0 back to 3 and forward past 3 to 0, the middle car is full size and
only the middle car is un-dimmed, and mashing an arrow cannot queue two slides.

## Commits

1. `docs:` this plan.
2. `feat(car_select):` the carousel.