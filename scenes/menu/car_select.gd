extends Control

const MAIN_MENU_SCENE: String = "res://scenes/menu/main_menu.tscn"

# --- Carousel tuning ---------------------------------------------------------
# Everything that shapes the carousel lives here, so the layout can be nudged
# without touching the logic further down.

## Where the middle (selected) car sits, in 1280x720 screen space.
## x centres the row on the panel art; y matches the middle of the panel.
const CAROUSEL_CENTER: Vector2 = Vector2(640.0, 250.0)

## Horizontal distance between two neighbouring cars.
const SLOT_SPACING: float = 230.0

## Size of one car slot. Must stay square: the car textures are 32x32, and this
## square is what the rotation and the scaling pivot around.
const SLOT_SIZE: float = 240.0

## How much smaller and dimmer the cars either side of the middle one are.
const SIDE_SCALE: float = 0.6
const SIDE_ALPHA: float = 0.45

## Belt positions of the five slots, relative to the middle one. -1 / 0 / +1 are
## the three visible slots; the two outermost are off-screen staging slots that
## already hold the car about to slide in.
const SLOT_OFFSETS: Array[int] = [-2, -1, 0, 1, 2]

## Belt positions further out than this are out of sight.
const VISIBLE_RANGE: int = 1

## Slide animation.
const SLIDE_DURATION: float = 0.32
const SLIDE_TRANS: Tween.TransitionType = Tween.TRANS_CUBIC
const SLIDE_EASE: Tween.EaseType = Tween.EASE_IN_OUT

# --- Orientation -------------------------------------------------------------
## Which way the cars point. The car textures are drawn nose-RIGHT, so NOSE_LEFT
## (the default) turns every car a half turn to face left.
## This is the only place the carousel orientation is decided: if the cars still
## look wrong in game, change this dropdown in the Inspector (or the default
## here) - the enum values are the actual degrees.
enum Facing { NOSE_RIGHT = 0, NOSE_DOWN = 90, NOSE_LEFT = 180, NOSE_UP = 270 }

@export var car_facing: Facing = Facing.NOSE_RIGHT:
	set(value):
		car_facing = value
		_apply_facing()

var selected_car_texture: Texture2D = null
# List of available cars (texture path + display name)
var car_roster = [
	{
		"name": "TEAL SPRINTER",
		"texture": preload("res://assets/sprites/cars/player_car.png")
	},
	{
		"name": "CRIMSON RIVAL",
		"texture": preload("res://assets/sprites/cars/rival_car.png")
	},
	{
		"name": "DUST VANISHER",
		"texture": preload("res://assets/sprites/cars/new_car_1.png")
	},
	{
		"name": "GREEN GOBLIN",
		"texture": preload("res://assets/sprites/cars/new_car_2.png")
	}
]

var current_index: int = 0

# Built in _ready() from Carousel's children, in scene order: the first child is
# the leftmost belt position, the last child is the rightmost.
var _slots: Array[TextureRect] = []
var _slot_offsets: Array[int] = []
var _is_sliding: bool = false

@onready var _carousel: Control = $Carousel
@onready var car_name_label: Label = get_node_or_null("CarNameLabel")
@onready var prev_btn: Button = get_node_or_null("PrevButton")
@onready var next_btn: Button = get_node_or_null("NextButton")
@onready var select_btn: Button = get_node_or_null("SelectButton")
@onready var back_btn: Button = get_node_or_null("BackButton")

func _ready() -> void:
	# Connect Button Clicks
	prev_btn.pressed.connect(_on_prev_pressed)
	next_btn.pressed.connect(_on_next_pressed)
	select_btn.pressed.connect(_on_select_pressed)
	if back_btn:
		back_btn.pressed.connect(_on_back_pressed)

	_collect_slots()
	if _slots.size() != SLOT_OFFSETS.size():
		push_warning("Carousel needs %d CarSlot children, found %d." % [SLOT_OFFSETS.size(), _slots.size()])
		return

	_apply_facing()
	for i in _slots.size():
		_rest_slot(_slots[i], _slot_offsets[i])
	_show_current_name()

func _collect_slots() -> void:
	_slots.clear()
	_slot_offsets.clear()
	for child in _carousel.get_children():
		if child is TextureRect:
			_slots.append(child)
	for offset in SLOT_OFFSETS:
		_slot_offsets.append(offset)

func _apply_facing() -> void:
	if not is_node_ready():
		return
	for slot in _slots:
		slot.rotation_degrees = float(car_facing)

func _on_prev_pressed() -> void:
	_slide(-1)

func _on_next_pressed() -> void:
	_slide(1)

## Moves every car one belt position. `direction` is +1 for Next (cars travel
## left) and -1 for Prev (cars travel right).
func _slide(direction: int) -> void:
	if _is_sliding:
		return
	_is_sliding = true
	_set_buttons_enabled(false)

	current_index = posmod(current_index + direction, car_roster.size())

	# Because (current_index + direction) + (offset - direction) equals
	# current_index + offset, no slot has to swap its texture: the car each slot
	# already holds is still the right one. Only the slot that leaves the belt
	# gets new content, and it does so while out of sight.
	var recycled: int = -1
	var lowest: int = SLOT_OFFSETS[0]
	var highest: int = SLOT_OFFSETS[SLOT_OFFSETS.size() - 1]
	for i in _slot_offsets.size():
		_slot_offsets[i] -= direction
	for i in _slot_offsets.size():
		if _slot_offsets[i] < lowest:
			_slot_offsets[i] = highest
			recycled = i
		elif _slot_offsets[i] > highest:
			_slot_offsets[i] = lowest
			recycled = i

	_present_slots(recycled)
	_cross_fade_name()

	# Re-arm the buttons once the slide has settled.
	var timer: Tween = create_tween()
	timer.tween_interval(SLIDE_DURATION)
	timer.tween_callback(_on_slide_finished)

func _present_slots(recycled: int) -> void:
	for i in _slots.size():
		var slot: TextureRect = _slots[i]
		var offset: int = _slot_offsets[i]
		if i == recycled:
			# Recycled from one out-of-sight staging position to the other, so
			# snap it instead of flying it across the whole screen.
			_rest_slot(slot, offset)
		else:
			slot.texture = _texture_for_offset(offset)
			_tween_slot(slot, offset)

func _rest_slot(slot: TextureRect, offset: int) -> void:
	slot.texture = _texture_for_offset(offset)
	slot.position = _position_for_offset(offset)
	slot.scale = _scale_for_offset(offset)
	slot.modulate = _modulate_for_offset(offset)

func _tween_slot(slot: TextureRect, offset: int) -> void:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(slot, "position", _position_for_offset(offset), SLIDE_DURATION).set_trans(SLIDE_TRANS).set_ease(SLIDE_EASE)
	tween.tween_property(slot, "scale", _scale_for_offset(offset), SLIDE_DURATION).set_trans(SLIDE_TRANS).set_ease(SLIDE_EASE)
	tween.tween_property(slot, "modulate", _modulate_for_offset(offset), SLIDE_DURATION).set_trans(SLIDE_TRANS).set_ease(SLIDE_EASE)

func _on_slide_finished() -> void:
	_is_sliding = false
	_set_buttons_enabled(true)

func _set_buttons_enabled(enabled: bool) -> void:
	for button in [prev_btn, next_btn, select_btn]:
		if button != null:
			button.disabled = not enabled

func _position_for_offset(offset: int) -> Vector2:
	return CAROUSEL_CENTER + Vector2(offset * SLOT_SPACING, 0.0) - Vector2(SLOT_SIZE, SLOT_SIZE) * 0.5

func _scale_for_offset(offset: int) -> Vector2:
	return Vector2.ONE if offset == 0 else Vector2(SIDE_SCALE, SIDE_SCALE)

func _modulate_for_offset(offset: int) -> Color:
	if absi(offset) > VISIBLE_RANGE:
		return Color(1.0, 1.0, 1.0, 0.0)
	if offset == 0:
		return Color(1.0, 1.0, 1.0, 1.0)
	return Color(1.0, 1.0, 1.0, SIDE_ALPHA)

func _texture_for_offset(offset: int) -> Texture2D:
	return car_roster[posmod(current_index + offset, car_roster.size())]["texture"]

func _show_current_name() -> void:
	if car_name_label:
		car_name_label.text = car_roster[current_index]["name"]

## The name belongs to the car arriving in the middle, so fade the old one out
## and the new one in across the slide.
func _cross_fade_name() -> void:
	if car_name_label == null:
		_show_current_name()
		return
	var tween: Tween = create_tween()
	tween.tween_property(car_name_label, "modulate:a", 0.0, SLIDE_DURATION * 0.5)
	tween.tween_callback(_show_current_name)
	tween.tween_property(car_name_label, "modulate:a", 1.0, SLIDE_DURATION * 0.5)

func _on_select_pressed() -> void:
	# Save the chosen texture into our global GameManager
	if typeof(GameManager) != TYPE_NIL:
		GameManager.selected_car_texture = car_roster[current_index]["texture"]

	print("Car selected! Going to VS Loading Screen...")
	get_tree().change_scene_to_file("res://scenes/menu/loading_scene.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

# Parity with main_menu.gd: Escape returns to the main menu
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()