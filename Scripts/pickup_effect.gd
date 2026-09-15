extends Area2D

@export_enum("gold", "armor", "trap") var effect := "gold"
@export var amount := 10
var base_y := 0.0
var float_time := 0.0

func _ready() -> void:
	base_y = position.y

func _process(delta: float) -> void:
	float_time += delta
	position.y = base_y + sin(float_time * 2.4) * 5.0

func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("player"): return
	match effect:
		"gold": GameState.add_reward(amount, amount * 10); AudioManager.play_sfx(&"shield")
		"armor":
			GameState.add_reward(0, 0, amount)
			GameState.apply_buff("ARMOR +%d" % amount, 2.0)
			GameState.apply_buff("SPEED UP", 3.0)
			area.apply_speed_modifier(1.4, 3.0)
			AudioManager.play_sfx(&"shield")
		"trap":
			GameState.apply_damage(amount)
			GameState.set_shield(false)
			GameState.apply_debuff("SLOW", 3.0)
			GameState.apply_debuff("SHIELD BREAK", 2.0)
			GameState.apply_debuff("DAMAGE -%d" % amount, 1.5)
			area.apply_speed_modifier(0.55, 3.0)
			AudioManager.play_sfx(&"hit")
	# Keep the level populated: a collected item/trap reappears elsewhere.
	monitoring = false
	monitorable = false
	visible = false
	await get_tree().create_timer(3.0).timeout
	var screen_size := get_viewport_rect().size
	global_position = Vector2(randf_range(260.0, screen_size.x - 80.0), randf_range(120.0, screen_size.y - 80.0))
	base_y = position.y
	visible = true
	monitorable = true
	monitoring = true
