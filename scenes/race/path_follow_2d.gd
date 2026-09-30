extends PathFollow2D

@export var lap_speed: float = 60.0

func _process(delta: float) -> void:
	progress += lap_speed * delta
	print("Pos: ", global_position, " | Progress: ", progress)
