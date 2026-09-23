extends Area2D

@export var speed := 460.0
@export var damage := 12.0
var direction := Vector2.LEFT

func _ready() -> void:
	rotation = direction.angle()

func _process(delta: float) -> void:
	global_position += direction.normalized() * speed * delta
	var bounds := get_viewport_rect().grow(90.0)
	if not bounds.has_point(global_position):
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("player"):
		return
	var game_state := get_node_or_null("/root/GameState")
	if game_state != null:
		game_state.apply_damage(damage)
	var audio := get_node_or_null("/root/AudioManager")
	if audio != null:
		audio.play_sfx(&"hit")
	queue_free()
