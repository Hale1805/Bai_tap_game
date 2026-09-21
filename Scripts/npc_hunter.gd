extends Area2D

@export var speed := 210.0
@export var max_health := 70.0
var health := max_health
var target: Node2D
var frozen_remaining := 0.0
var defeated := false

func configure(target_node: Node2D, _level_id: int) -> void:
	target = target_node

func _ready() -> void:
	if target == null:
		target = get_tree().get_first_node_in_group("player") as Node2D

func _process(delta: float) -> void:
	if frozen_remaining > 0.0:
		frozen_remaining = maxf(frozen_remaining - delta, 0.0)
		return
	if target != null:
		var direction := global_position.direction_to(target.global_position)
		global_position += direction * speed * delta
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
