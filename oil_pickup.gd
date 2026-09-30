extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

var initial_y: float = 0.0
var hover_time: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	initial_y = sprite.position.y

func _process(delta: float) -> void:
	# Subtle floating / bobbing animation on the road
	hover_time += delta * 4.0
	sprite.position.y = initial_y + sin(hover_time) * 3.0

func _on_body_entered(body: Node2D) -> void:
	# Check if it was the player who drove over it
	if body.is_in_group("player") or body.name == "PlayerCar":
		# Notify the track level or player to store the item
		var track = get_tree().current_scene
		if track.has_method("collect_powerup"):
			track.collect_powerup("oil")
		
		# Quick collect feedback scale down and remove
		set_deferred("monitoring", false)
		var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_property(sprite, "scale", Vector2.ZERO, 0.15)
		await tween.finished
		queue_free()
