extends Area2D

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var anim_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_play_expand_animation()

func _play_expand_animation() -> void:
	if anim_sprite:
		anim_sprite.play("default")
	elif sprite and sprite.hframes > 1:
		sprite.frame = 0
		for i in range(1, sprite.hframes):
			await get_tree().create_timer(0.06).timeout
			if not is_instance_valid(sprite):
				return
			sprite.frame = i

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "PlayerCar":
		return

	var target = body
	if not target.has_method("apply_oil_slowdown") and target.get_parent():
		target = target.get_parent()

	# If the target has an active Bumper Shield, absorb the trap without slowing down!
	if "is_shielded" in target and target.is_shielded:
		print(target.name, " hit oil, but their Bumper Shield protected them!")
		queue_free()
		return

	if target.has_method("apply_oil_slowdown"):
		target.apply_oil_slowdown(3.0)
		queue_free()
