extends Area2D

@export var speed := 140.0
@export var max_health := 220.0
var health := max_health
var target: Node2D
var frozen_remaining := 0.0
var defeated := false
var enraged := false

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
	var ally := _lowest_health_ally()
	if target != null:
		var direction := global_position.direction_to(target.global_position)
		var distance := global_position.distance_to(target.global_position)
		if ally != null:
			if ally.health < ally.max_health:
				ally.health = minf(ally.max_health, ally.health + 12.0 * delta)
				return
			_move_at_range(direction, distance, 180.0, speed, delta)
		else:
			enraged = true
			modulate = Color(1.0, 0.42, 0.42)
			_move_at_range(direction, distance, 110.0, speed * 1.25, delta)
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
		audio.play_sfx(&"boss_explosion")
	var manager := get_node_or_null("/root/LevelManager")
	if manager != null:
		manager.register_enemy_defeat(&"guardian")
	queue_free()
	return true

func freeze(duration: float) -> void:
	frozen_remaining = maxf(frozen_remaining, duration)

func collision_damage() -> float:
	return 24.0 if enraged else 16.0

func push_from(source_position: Vector2) -> void:
	var away := source_position.direction_to(global_position)
	global_position += (away if away != Vector2.ZERO else Vector2.RIGHT) * 100.0

func _move_at_range(direction: Vector2, distance: float, desired_range: float, move_speed: float, delta: float) -> void:
	if distance > desired_range + 18.0:
		global_position += direction * move_speed * delta
	elif distance < desired_range - 18.0:
		global_position -= direction * move_speed * delta
	else:
		global_position += direction.rotated(PI * 0.5) * move_speed * 0.55 * delta

func _lowest_health_ally() -> Node:
	var lowest: Node
	for ally in get_tree().get_nodes_in_group("enemy"):
		if ally != self and "health" in ally and "max_health" in ally:
			if lowest == null or ally.health < lowest.health:
				lowest = ally
	return lowest
