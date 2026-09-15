extends Node2D

const ENEMY_SCENE = preload("res://object_b.tscn")

@onready var layer1 = $Layer1
@onready var layer2 = $Layer2

var is_layer1_active: bool = true
var crossfade_time: float = 3.0 # Thời gian chuyển cảnh (3 giây)

func _ready():
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
	if not is_inside_tree():
		return
	await get_tree().create_timer(2.0).timeout
	if not is_inside_tree():
		return
	var enemy = ENEMY_SCENE.instantiate()
	add_child(enemy)
	_watch_enemy(enemy)

func _watch_enemy(enemy: Node) -> void:
	enemy.tree_exited.connect(_respawn_enemy)
