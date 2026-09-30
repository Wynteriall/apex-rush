extends Node

var selected_car_texture: Texture2D = null
var target_scene_path: String = "res://scenes/race/track_level.tscn"
var can_race: bool = false

# --- Race Results Data ---
var race_winner: String = "PLAYER"
var total_race_time: float = 0.0
var best_lap_time: float = 0.0

# Helper function to format seconds into MM:SS.ms (e.g. 01:23.45)
func format_time(seconds: float) -> String:
	if seconds <= 0.0:
		return "--:--.--"
	var mins = int(seconds / 60.0)
	var secs = int(fmod(seconds, 60.0))
	var msecs = int(fmod(seconds, 1.0) * 100.0)
	return "%02d:%02d.%02d" % [mins, secs, msecs]
