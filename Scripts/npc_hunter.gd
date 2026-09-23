extends Area2D

@export var speed := 180.0
@export var max_health := 70.0
var health := max_health
var target: Node2D
var frozen_remaining := 0.0
var defeated := false
var dash_cooldown := 1.5
var dash_remaining := 0.0

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
	if target != null:
		var direction := global_position.direction_to(target.global_position)
		var distance := global_position.distance_to(target.global_position)
		dash_cooldown = maxf(dash_cooldown - delta, 0.0)
		dash_remaining = maxf(dash_remaining - delta, 0.0)
		if distance > 105.0:
			global_position += direction * speed * delta
		elif dash_remaining > 0.0:
			global_position += direction * speed * 1.7 * delta
		elif dash_cooldown <= 0.0:
			dash_remaining = 0.22
			dash_cooldown = 2.8
		else:
			var tangent := direction.rotated(PI * 0.5)
			var retreat := -direction * 0.7 if distance < 85.0 else Vector2.ZERO
			global_position += (tangent + retreat).normalized() * speed * delta
		rotation = direction.angle()

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
		manager.register_enemy_defeat(&"hunter")
	queue_free()
	return true

func freeze(duration: float) -> void:
	frozen_remaining = maxf(frozen_remaining, duration)

func collision_damage() -> float:
	return 22.0 if dash_remaining > 0.0 else 10.0

func push_from(source_position: Vector2) -> void:
	var away := source_position.direction_to(global_position)
	global_position += (away if away != Vector2.ZERO else Vector2.RIGHT) * 80.0
