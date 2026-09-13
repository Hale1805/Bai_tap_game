extends Area2D

@export var speed: float = 250.0
var direction: Vector2

func _ready():
	var screen_size = get_viewport_rect().size
	# Vị trí xuất hiện: Chính giữa biên phải, đối diện A
	position = Vector2(screen_size.x - 70, screen_size.y / 2)
	randomize_direction()

func _process(delta):
	position += direction.normalized() * speed * delta
	var screen_size = get_viewport_rect().size

	# Chạm biên trái -> xuất hiện ngẫu nhiên biên phải
	if position.x < -20:
		position.x = screen_size.x + 20
		position.y = randf_range(screen_size.y / 4, screen_size.y - 30)
	# Chạm biên phải -> xuất hiện ngẫu nhiên bên trái
	elif position.x > screen_size.x + 20:
		position.x = -20
		position.y = randf_range(screen_size.y / 4, screen_size.y - 30)
		
	# Chạm biên trên -> xuất hiện ngẫu nhiên biên dưới
	if position.y < -20:
		position.y = screen_size.y + 20
		position.x = randf_range(screen_size.x / 4, screen_size.x - 30)
		
	# Chạm biên dưới -> xuất hiện ngẫu nhiên biên trên
	elif position.y > screen_size.y + 20:
		position.y = -20
		position.x = randf_range(screen_size.x / 4, screen_size.x - 30)


func _on_timer_timeout() -> void:
	randomize_direction()
	
func randomize_direction():
	#Luôn tiến về bên trái (x âm), trục y ngẫu nhiên đổi hướng
	direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	#Phòng trường hợp cả x và y random ra đúng số 0, 0
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT #Gán tạm một hướng để tàu tiếp tục di chuyển
