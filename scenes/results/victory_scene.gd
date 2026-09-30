extends Control

@onready var play_again_btn: Button = $PlayAgainButton
@onready var main_menu_btn: Button = $MainMenuButton

@onready var winner_label: Label = $WinnerLabel
@onready var total_time_label: Label = $TotalTimeLabel
@onready var best_lap_label: Label = $BestLapLabel

func _ready() -> void:
	play_again_btn.pressed.connect(_on_play_again_pressed)
	main_menu_btn.pressed.connect(_on_main_menu_pressed)

	# Populate stats from GameManager
	if typeof(GameManager) != TYPE_NIL:
		if winner_label:
			winner_label.text = GameManager.race_winner
		if total_time_label:
			total_time_label.text = GameManager.format_time(GameManager.total_race_time)
		if best_lap_label:
			best_lap_label.text = GameManager.format_time(GameManager.best_lap_time)

func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/car_select.tscn")

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
