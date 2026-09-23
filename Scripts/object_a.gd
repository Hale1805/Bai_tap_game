extends Area2D

@export var speed := 350.0
@export var bullet_scenes: Array[PackedScene]
var current_bullet_index := 0
var last_direction := Vector2.RIGHT
var speed_multiplier := 1.0
var attack_cooldowns := [0.0, 0.0, 0.0]
var shield_cooldown := 0.0
var shield_remaining := 0.0
var freeze_cooldown := 0.0
var contact_cooldown := 0.0
const ATTACK_COOLDOWNS := [0.25, 0.8, 1.4]

func _ready() -> void:
	position = Vector2(50, get_viewport_rect().size.y / 2)
	rotation = last_direction.angle()
	GameState.reset()

func _process(delta: float) -> void:
	if GameState.is_game_over:
		return
	var velocity := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if velocity != Vector2.ZERO:
		position += velocity * speed * speed_multiplier * delta
		last_direction = velocity.normalized()
		rotation = last_direction.angle()
	position.x = clampf(position.x, 50.0, get_viewport_rect().size.x - 50.0)
	position.y = clampf(position.y, 50.0, get_viewport_rect().size.y - 50.0)
	for index in attack_cooldowns.size(): attack_cooldowns[index] = maxf(attack_cooldowns[index] - delta, 0.0)
	shield_cooldown = maxf(shield_cooldown - delta, 0.0)
	freeze_cooldown = maxf(freeze_cooldown - delta, 0.0)
	contact_cooldown = maxf(contact_cooldown - delta, 0.0)
	if shield_remaining > 0.0:
		shield_remaining -= delta
		if shield_remaining <= 0.0: GameState.set_shield(false)
	if Input.is_action_just_pressed("attack_bullet"): try_attack(GameState.AttackType.BULLET)
	if Input.is_action_just_pressed("attack_missile"): try_attack(GameState.AttackType.MISSILE)
	if Input.is_action_just_pressed("attack_bomb"): try_attack(GameState.AttackType.BOMB)
	if Input.is_action_just_pressed("activate_shield"): activate_shield()
	if Input.is_action_just_pressed("activate_freeze"): activate_freeze()

func _unhandled_input(event: InputEvent) -> void:
	if GameState.is_game_over:
		return
	if event is InputEventScreenTouch and event.pressed: try_attack(GameState.selected_attack)
	if event.is_action_pressed("ui_accept"): switch_weapon()

func switch_weapon() -> void:
	if bullet_scenes.size() >= 3:
		current_bullet_index = (current_bullet_index + 1) % 3
		GameState.select_attack(current_bullet_index as GameState.AttackType)

func try_attack(attack_type: GameState.AttackType) -> bool:
	var index := int(attack_type)
	if index >= bullet_scenes.size() or attack_cooldowns[index] > 0.0 or bullet_scenes[index] == null: return false
	var projectile = bullet_scenes[index].instantiate()
	projectile.global_position = global_position + last_direction * 55.0
	projectile.direction = last_direction
	get_parent().add_child(projectile)
	attack_cooldowns[index] = ATTACK_COOLDOWNS[index]
	GameState.select_attack(attack_type)
	current_bullet_index = index #add thêm chỗ này
	AudioManager.play_sfx(&"shoot")
	return true

func activate_shield() -> bool:
	if shield_cooldown > 0.0: return false
	shield_cooldown = 8.0
	shield_remaining = 3.0
	GameState.set_shield(true)
	GameState.apply_buff("SHIELD", shield_remaining)
	AudioManager.play_sfx(&"shield")
	return true

func activate_freeze() -> bool:
	if freeze_cooldown > 0.0: return false
	freeze_cooldown = 9.0
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.has_method("freeze"): enemy.freeze(2.5)
	AudioManager.play_sfx(&"freeze")
	return true

func apply_speed_modifier(multiplier: float, duration: float) -> void:
	speed_multiplier = multiplier
	get_tree().create_timer(duration).timeout.connect(func(): speed_multiplier = 1.0)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") and contact_cooldown <= 0.0:
		var away := area.global_position.direction_to(global_position)
		if away == Vector2.ZERO:
			away = Vector2.LEFT
		var incoming_damage: float = float(area.collision_damage()) if area.has_method("collision_damage") else 15.0
		GameState.apply_damage(incoming_damage)
		if area.has_method("take_damage"):
			area.take_damage(10.0)
		if is_instance_valid(area) and area.has_method("push_from"):
			area.push_from(global_position)
		global_position += away * 45.0
		contact_cooldown = 0.8
		AudioManager.play_sfx(&"hit")
