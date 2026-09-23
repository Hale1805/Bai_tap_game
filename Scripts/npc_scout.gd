extends Area2D

const ENEMY_BOLT_SCENE = preload("res://enemy_bolt.tscn")

@export var speed := 160.0
@export var preferred_range := 300.0
@export var max_health := 45.0
var health := max_health
var target: Node2D
var frozen_remaining := 0.0
var defeated := false
var shoot_cooldown := 0.8

func configure(target_node: Node2D, _level_id: int) -> void:
	target = target_node

func _ready() -> void:
	if target == null:
		target = get_tree().get_first_node_in_group("player") as Node2D

func _process(delta: float) -> void:
	var manager := get_node_or_null("/root/LevelManager") if is_inside_tree() else null
	if manager != null and not manager.gameplay_active:
		return
	if frozen_remaining > 0.0:
		frozen_remaining = maxf(frozen_remaining - delta, 0.0)
		return
	if target == null:
		return
	shoot_cooldown = maxf(shoot_cooldown - delta, 0.0)
	var distance := global_position.distance_to(target.global_position)
	var radial := global_position.direction_to(target.global_position)
	var movement := radial.rotated(PI * 0.5)
	if distance < preferred_range * 0.75:
		movement = -radial
	elif distance > preferred_range * 1.2:
		movement = radial
	global_position += movement * speed * delta
	rotation = movement.angle()
	if distance >= preferred_range * 0.75 and distance <= preferred_range * 1.2 and shoot_cooldown <= 0.0:
		shoot_at_target()

func take_damage(amount: float) -> bool:
	if defeated:
		return false
	health -= maxf(amount, 0.0)
	if health > 0.0:
		return false
	defeated = true
	var audio := get_node_or_null("/root/AudioManager")
	if audio != null:
		audio.play_sfx(&"explosion")
	var manager := get_node_or_null("/root/LevelManager")
	if manager != null:
		manager.register_enemy_defeat(&"scout")
	queue_free()
	return true

func freeze(duration: float) -> void:
	frozen_remaining = maxf(frozen_remaining, duration)

func collision_damage() -> float:
	return 8.0

func push_from(source_position: Vector2) -> void:
	var away := source_position.direction_to(global_position)
	global_position += (away if away != Vector2.ZERO else Vector2.RIGHT) * 70.0

func shoot_at_target() -> bool:
	if target == null or get_parent() == null:
		return false
	var bolt = ENEMY_BOLT_SCENE.instantiate()
	bolt.global_position = global_position + global_position.direction_to(target.global_position) * 34.0
	bolt.direction = global_position.direction_to(target.global_position)
	get_parent().add_child(bolt)
	shoot_cooldown = 1.6
	var audio := get_node_or_null("/root/AudioManager") if is_inside_tree() else null
	if audio != null:
		audio.play_sfx(&"shoot")
	return true
