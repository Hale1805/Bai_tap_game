extends Area2D

@export var speed: float = 500.0
var direction: Vector2 = Vector2.ZERO # Mặc định đạn bắn sang phải
@export var explosion_scene: PackedScene #Load scene vụ nổ

func _ready():
	if direction != Vector2.ZERO:
	#Xoay viên đạn trực tiếp theo hướng được truyền từ A
		rotation = direction.angle()

func _process(delta):
	# Di chuyển đối tượng C theo hướng và tốc độ
	position += direction.normalized() * speed * delta

# Tùy chọn: Tự hủy đạn khi bay ra khỏi màn hình để tối ưu hiệu năng
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		#Nếu đạn chạm phải vật thuộc nhóm enemy thì tạo vụ nổ
		if explosion_scene != null:
			var explosion = explosion_scene.instantiate()
			
			#Đặt vụ nổ tại vị trí viên đạn đang đứng
			explosion.global_position = global_position
			get_parent().call_deferred("add_child", explosion)
		
		#Viên đạn tự biến mất
		queue_free()
