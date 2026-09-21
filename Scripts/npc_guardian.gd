extends Area2D

@export var speed := 240.0
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
	if ally != null and ally.health < ally.max_health:
		ally.health = minf(ally.max_health, ally.health + 12.0 * delta)
		return
	if target != null:
		enraged = true
		modulate = Color(1.0, 0.42, 0.42)
		var direction := global_position.direction_to(target.global_position)
		global_position += direction * speed * 1.25 * delta
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

func _lowest_health_ally() -> Node:
	var lowest: Node
	for ally in get_tree().get_nodes_in_group("enemy"):
		if ally != self and "health" in ally and "max_health" in ally:
			if lowest == null or ally.health < lowest.health:
				lowest = ally
	return lowest
