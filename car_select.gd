extends Control

var selected_car_texture: Texture2D = null
# List of available cars (texture path + display name)
var car_roster = [
	{
		"name": "TEAL SPRINTER",
		"texture": preload("res://playerr.png") # Update with your exact teal car path!
	},
	{
		"name": "CRIMSON RIVAL",
		"texture": preload("res://Rival_Car.png") # Update with your exact red car path!
	},	
	{
		"name": "DUST VANISHER",
		"texture": preload("res://NewCar1.png") # Update with your exact red car path!
	},
	{
		"name": "GREEN GOBLIN",
		"texture": preload("res://NewCar2.png") # Update with your exact red car path!
	}
]

var current_index: int = 0

@onready var car_display: TextureRect = $CarDisplay
@onready var car_name_label: Label = get_node_or_null("CarNameLabel")
@onready var prev_btn: Button = get_node_or_null("PrevButton")
@onready var next_btn: Button = get_node_or_null("NextButton")
@onready var select_btn: Button = get_node_or_null("SelectButton")

func _ready() -> void:
	# Connect Button Clicks
	prev_btn.pressed.connect(_on_prev_pressed)
	next_btn.pressed.connect(_on_next_pressed)
	select_btn.pressed.connect(_on_select_pressed)
	
	_update_car_view()

func _update_car_view() -> void:
	var car_data = car_roster[current_index]
	car_display.texture = car_data["texture"]
	if car_name_label:
		car_name_label.text = car_data["name"]

func _on_prev_pressed() -> void:
	current_index -= 1
	if current_index < 0:
		current_index = car_roster.size() - 1 # Loops back to the last car
	_update_car_view()

func _on_next_pressed() -> void:
	current_index += 1
	if current_index >= car_roster.size():
		current_index = 0 # Loops back to the first car
	_update_car_view()

func _on_select_pressed() -> void:
	# Save the chosen texture into our global GameManager
	if typeof(GameManager) != TYPE_NIL:
		GameManager.selected_car_texture = car_roster[current_index]["texture"]
	
	print("Car selected! Going to VS Loading Screen...")
	get_tree().change_scene_to_file("res://loading_scene.tscn")
