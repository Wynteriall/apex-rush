extends CharacterBody2D

# --- Speeds & Physics ---
@export var base_speed: float = 160.0
@export var max_speed: float = 210.0
@export var acceleration: float = 300.0
@export var steering_speed: float = 4.5
@export var friction: float = 0.96
@export var traction_drift: float = 0.12
@onready var shield_effect: AnimatedSprite2D = get_node_or_null("ShieldEffect")
var is_shielded: bool = false
var shield_timer: float = 0.0
# --- AI Path Settings ---
@export var look_ahead_dist: float = 80.0     # Target distance along the track
@export var snap_angles: int = 14

# --- Car Orientation Setting ---
# Change this if your car sprite is drawn pointing UP (standard in top-down racers)
# If your car points UP in the editor, forward_angle_offset is -PI / 2 (-90 deg)
@export var forward_angle_offset: float = -PI / 2.0

const SKID_MARK_SCENE = preload("res://scenes/effects/skid_mark.tscn")
const SPARK_SCENE = preload("res://scenes/effects/impact_spark.tscn")

var current_speed: float = 0.0
var spark_cooldown: float = 0.0
var current_path_offset: float = 0.0

var path_follow: PathFollow2D = null
var path_2d: Path2D = null

# --- Oil Trap State ---
var is_slowed: bool = false

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var exhaust_smoke: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var left_tire: Marker2D = get_node_or_null("LeftTire")
@onready var right_tire: Marker2D = get_node_or_null("RightTire")

func _ready() -> void:
	path_follow = get_tree().current_scene.find_child("RivalPathFollow", true, false)
	if path_follow:
		path_2d = path_follow.get_parent() as Path2D
		# Initialize the AI's starting progress to where it is parked on the grid
		current_path_offset = path_2d.curve.get_closest_offset(global_position)
	else:
		print("Warning: RivalPathFollow not found in TrackLevel!")

	if sprite:
		sprite.top_level = false
		sprite.z_index = 5

func _process(_delta: float) -> void:
	if is_shielded:
		shield_timer -= _delta
		if shield_timer <= 0.0:
			deactivate_shield()
			
	if not sprite:
		return

	var step_size = TAU / float(snap_angles)
	var snapped_world_rot = round(global_rotation / step_size) * step_size
	sprite.rotation = snapped_world_rot - global_rotation
	
func activate_shield(duration: float = 6.0) -> void:
	is_shielded = true
	shield_timer = duration
	if shield_effect:
		shield_effect.show()
		shield_effect.play("default")

func deactivate_shield() -> void:
	is_shielded = false
	if shield_effect:
		shield_effect.stop()
		shield_effect.hide()

func _physics_process(delta: float) -> void:
	
	if is_boosting:
		boost_timer -= delta
		if boost_timer <= 0.0:
			end_nitro_boost()
	# Multiply the rival's progress speed along PathFollow2D by speed_multiplier!
	
	# Block AI until "GO!" is triggered
	if typeof(GameManager) != TYPE_NIL and not GameManager.can_race:
		velocity = Vector2.ZERO
		current_speed = 0.0
		move_and_slide()
		return

	if not path_2d or not path_follow:
		move_and_slide()
		return

	# 1. Track progress continuously FORWARD only (never allow backwards jumping)
	var nearest_offset = path_2d.curve.get_closest_offset(global_position)
	var total_len = path_2d.curve.get_baked_length()
	
	# Smoothly advance the reference offset forward
	current_path_offset = nearest_offset
	
	# Sample point ahead on the track line
	var target_offset = fmod(current_path_offset + look_ahead_dist, total_len)
	path_follow.progress = target_offset
	var target_pos: Vector2 = path_follow.global_position

	# 2. Calculate steering relative to car's actual forward direction
	var dir_to_target = (target_pos - global_position).normalized()
	var desired_world_angle = dir_to_target.angle()
	
	# Account for car graphic orientation (points UP by default)
	var current_facing_angle = rotation + forward_angle_offset
	var angle_diff = wrapf(desired_world_angle - current_facing_angle, -PI, PI)

	# Steer toward the target
	var steer_input = clamp(angle_diff * 3.0, -1.0, 1.0)
	rotation += steer_input * steering_speed * delta

	# 3. Corner braking vs straightaway acceleration
	var throttle_factor: float = 1.0
	if abs(angle_diff) > 0.6:
		throttle_factor = 0.40 # Brake hard into sharp chicane
	elif abs(angle_diff) > 0.3:
		throttle_factor = 0.70 # Ease throttle on moderate turn
	else:
		throttle_factor = 1.0  # Full speed on straightaway

	var target_speed = base_speed * throttle_factor
	current_speed = move_toward(current_speed, target_speed, acceleration * delta)

	# 4. Movement in the car's visual forward direction
	var forward_vector = Vector2.from_angle(rotation + forward_angle_offset)
	
	velocity = velocity.lerp(forward_vector * current_speed, traction_drift)
	velocity *= friction

	move_and_slide()

# --- Oil Hazard Effect ---
func apply_oil_slowdown(duration: float = 3.0) -> void:
	if is_slowed:
		return

	is_slowed = true
	print(name, " slipped on oil!")

	# 1. Visual flash
	modulate = Color(0.45, 0.45, 0.45)

	# 2. Spin out animation (one quick 360 degree spin)
	var spin_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	spin_tween.tween_property(self, "rotation", rotation + TAU, 0.6)

	# 3. Cut speed drastically
	var original_base_speed = base_speed
	base_speed = base_speed * 0.35
	current_speed = current_speed * 0.35

	# Wait for penalty duration
	await get_tree().create_timer(duration).timeout

	# 4. Recover
	base_speed = original_base_speed
	modulate = Color.WHITE
	is_slowed = false

func _on_body_entered(body: Node2D) -> void:
	print("MAY TUMAMA SA OIL: ", body.name)
	
	# Huwag pabagalin ang player na naghulog
	if body.is_in_group("player") or body.name == "PlayerCar":
		return
		
	# Kung ang tumama ay si RivalCar o may apply_oil_slowdown
	if body.has_method("apply_oil_slowdown"):
		print("Pinapabagal si: ", body.name)
		body.apply_oil_slowdown(3.0)
		queue_free()
	elif body.get_parent() and body.get_parent().has_method("apply_oil_slowdown"):
		print("Pinapabagal ang parent: ", body.get_parent().name)
		body.get_parent().apply_oil_slowdown(3.0)
		queue_free()
		
		
var stored_powerup: String = ""

func has_stored_powerup() -> bool:
	return stored_powerup != ""

func store_powerup(item_name: String) -> void:
	stored_powerup = item_name
	print("Rival stored powerup: ", item_name)
	
	# AI behavior: after 1.5 to 3 seconds, the rival activates its shield!
	await get_tree().create_timer(randf_range(1.5, 3.0)).timeout
	_ai_use_powerup()

func _ai_use_powerup() -> void:
	if stored_powerup == "shield":
		if has_method("activate_shield"):
			activate_shield(6.0)
	elif stored_powerup == "nitro":
		if has_method("activate_nitro_boost"):
			activate_nitro_boost(2.5, 1.6)
	stored_powerup = ""
		
@onready var boost_effect: AnimatedSprite2D = get_node_or_null("BoostEffect")

var is_boosting: bool = false
var boost_timer: float = 0.0
var speed_multiplier: float = 1.0

func activate_nitro_boost(duration: float = 2.5, speed_buff: float = 1.6) -> void:
	is_boosting = true
	boost_timer = duration
	speed_multiplier = speed_buff
	if boost_effect:
		boost_effect.show()
		boost_effect.play("default")

func end_nitro_boost() -> void:
	is_boosting = false
	speed_multiplier = 1.0
	if boost_effect:
		boost_effect.stop()
		boost_effect.hide()
