extends Camera2D

# Drag your car or PathFollow2D node into this slot in the Inspector
@export var target: Node2D

func _process(_delta: float) -> void:
	if target:
		global_position = target.global_position
