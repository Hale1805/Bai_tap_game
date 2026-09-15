extends Area2D

@export var speed := 500.0
@export var damage := 20.0
@export var blast_radius := 0.0
@export var explosion_scene: PackedScene
var direction := Vector2.ZERO

func _ready() -> void:
	if direction != Vector2.ZERO: rotation = direction.angle()
func _process(delta: float) -> void: position += direction.normalized() * speed * delta
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if blast_radius > 0.0: _explode()
	queue_free()
func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("enemy"): return
	if blast_radius > 0.0: _explode()
	else: _damage_enemy(area); _spawn_explosion()
	queue_free()
func _explode() -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if is_instance_valid(enemy) and global_position.distance_to(enemy.global_position) <= blast_radius: _damage_enemy(enemy)
	_spawn_explosion()
	AudioManager.play_sfx(&"explosion")
func _damage_enemy(enemy: Node) -> void:
	if enemy.has_method("take_damage"): enemy.take_damage(damage)
func _spawn_explosion() -> void:
	if explosion_scene == null: return
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_parent().call_deferred("add_child", explosion)
