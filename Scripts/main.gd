extends Node2D

const ENEMY_SCENE = preload("res://object_b.tscn")
const NPC_SCENES := {
	&"hunter": preload("res://npc_hunter.tscn"),
	&"scout": preload("res://npc_scout.tscn"),
	&"guardian": preload("res://npc_guardian.tscn"),
}

@onready var layer1 = $Layer1
@onready var layer2 = $Layer2

var is_layer1_active: bool = true
var crossfade_time: float = 3.0 # Thời gian chuyển cảnh (3 giây)

func _ready():
	LevelManager.level_won.connect(_on_level_won)
	LevelManager.level_lost.connect(_on_level_lost)
	GameState.game_over.connect(LevelManager.end_game_over)
	_configure_level(LevelManager.get_current_definition())
	# Đảm bảo ảnh 2 hoàn toàn trong suốt lúc game mới bắt đầu
	layer2.modulate.a = 0.0
	_watch_enemy($Object_B)

# Hàm này kích hoạt mỗi 30 giây
func _on_timer_timeout():
	# Tạo một Tween mới
	var tween = create_tween()
	
	# Lệnh này ép các hiệu ứng bên dưới chạy ĐỒNG THỜI cùng lúc
	tween.set_parallel(true)
	
	if is_layer1_active:
		# Ảnh 1 mờ dần về 0, Ảnh 2 rõ dần lên 1
		tween.tween_property(layer1, "modulate:a", 0.0, crossfade_time)
		tween.tween_property(layer2, "modulate:a", 1.0, crossfade_time)
	else:
		# Đảo ngược lại quá trình trên
		tween.tween_property(layer1, "modulate:a", 1.0, crossfade_time)
		tween.tween_property(layer2, "modulate:a", 0.0, crossfade_time)
		
	# Lật trạng thái để chuẩn bị cho chu kỳ 30 giây tiếp theo
	is_layer1_active = !is_layer1_active

func _on_danger_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		AudioManager.play_danger_warning(randi_range(3, 6))

func _respawn_enemy() -> void:
	if not is_inside_tree() or not LevelManager.gameplay_active:
		return
	await get_tree().create_timer(2.0).timeout
	if not is_inside_tree():
		return
	if not LevelManager.gameplay_active:
		return
	var enemy = _choose_enemy_scene().instantiate()
	enemy.position = Vector2(get_viewport_rect().size.x + 70.0, randf_range(100.0, get_viewport_rect().size.y - 100.0))
	add_child(enemy)
	if enemy.has_method("configure"):
		enemy.configure($Object_A, LevelManager.current_level_id)
	_watch_enemy(enemy)

func _watch_enemy(enemy: Node) -> void:
	enemy.tree_exited.connect(_respawn_enemy)

func _process(delta: float) -> void:
	LevelManager.register_survival_tick(delta)

func _configure_level(definition: Dictionary) -> void:
	if definition.is_empty():
		return
	var mode := int(definition.get("background_mode", 0))
	layer1.modulate = [Color.WHITE, Color(0.55, 0.72, 1.0), Color(0.85, 0.45, 1.0)][mode]
	layer2.modulate.a = 0.0

func _on_level_won(level_id: int) -> void:
	$EndScreen.show_win(level_id)

func _on_level_lost(level_id: int) -> void:
	$EndScreen.show_loss(level_id)

func _choose_enemy_scene() -> PackedScene:
	var definition := LevelManager.get_current_definition()
	var allowed: Array = definition.get("allowed_npcs", [&"hunter"])
	var npc_type: StringName = allowed.pick_random()
	return NPC_SCENES.get(npc_type, ENEMY_SCENE)
