extends Control

# --- Texture References ---
# Default fallback rival texture (adjust path to your rival car sprite)
@export var default_rival_texture: Texture2D = preload("res://rival_car.png")

# --- Node References ---
@onready var player_display: TextureRect = $PlayerCarDisplay
@onready var rival_display: TextureRect = $RivalCarDisplay
@onready var progress_bar: ProgressBar = $ProgressBar

var target_scene_path: String = "res://track_level.tscn"
var progress: Array = []
var load_status: int = 0

func _ready() -> void:
	progress_bar.value = 0.0

	# 1. Display Selected Player Car
	if typeof(GameManager) != TYPE_NIL and GameManager.selected_car_texture != null:
		player_display.texture = GameManager.selected_car_texture
	else:
		# Fallback if launched directly for testing
		player_display.texture = preload("res://player_car.png")

	# 2. Display Rival Car
	rival_display.texture = default_rival_texture

	# 3. Check target scene from GameManager
	if typeof(GameManager) != TYPE_NIL and "target_scene_path" in GameManager and GameManager.target_scene_path != "":
		target_scene_path = GameManager.target_scene_path

	# 4. Start background thread loading
	ResourceLoader.load_threaded_request(target_scene_path)

func _process(delta: float) -> void:
	load_status = ResourceLoader.load_threaded_get_status(target_scene_path, progress)

	# Smoothly advance progress bar
	if progress.size() > 0:
		var target_val = progress[0] * 100.0
		progress_bar.value = move_toward(progress_bar.value, target_val, 150.0 * delta)

	# When track is fully loaded
	if load_status == ResourceLoader.THREAD_LOAD_LOADED and progress_bar.value >= 99.0:
		set_process(false)
		# Brief pause so the player gets to appreciate the VS screen
		await get_tree().create_timer(0.6).timeout
		
		var packed_scene = ResourceLoader.load_threaded_get(target_scene_path)
		get_tree().change_scene_to_packed(packed_scene)

	elif load_status == ResourceLoader.THREAD_LOAD_FAILED:
		print("Error: Failed to load track scene at ", target_scene_path)
		set_process(false)
