extends Area2D

@export var speed := 250.0
@export var max_health := 60.0
var direction := Vector2.ZERO
var health := 0.0
var frozen_remaining := 0.0

func _ready() -> void:
	health = max_health
	position = Vector2(get_viewport_rect().size.x - 70, get_viewport_rect().size.y / 2)
	randomize_direction()

func _process(delta: float) -> void:
	var manager := get_node_or_null("/root/LevelManager") if is_inside_tree() else null
	if manager != null and not manager.gameplay_active:
		return
	if frozen_remaining > 0.0:
		frozen_remaining = maxf(frozen_remaining - delta, 0.0)
		return
	position += direction * speed * delta
	var screen_size := get_viewport_rect().size
	if position.x < -20.0 or position.x > screen_size.x + 20.0:
		position.x = screen_size.x + 20.0 if position.x < -20.0 else -20.0
		position.y = randf_range(screen_size.y / 4, screen_size.y - 30)
	if position.y < -20.0 or position.y > screen_size.y + 20.0:
		position.y = screen_size.y + 20.0 if position.y < -20.0 else -20.0
		position.x = randf_range(screen_size.x / 4, screen_size.x - 30)

func _on_timer_timeout() -> void: randomize_direction()
func randomize_direction() -> void:
	direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	if direction == Vector2.ZERO: direction = Vector2.LEFT
func take_damage(amount: float) -> bool:
	health -= maxf(amount, 0.0)
	if health <= 0.0:
		AudioManager.play_sfx(&"explosion")
		if LevelManager.gameplay_active:
			LevelManager.register_enemy_defeat(&"hunter")
		queue_free()
		return true
	return false
func freeze(duration: float) -> void: frozen_remaining = maxf(frozen_remaining, duration)
