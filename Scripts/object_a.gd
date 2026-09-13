extends Area2D

@export var speed: float = 350.0
@export var bullet_scenes: Array[PackedScene]
# Biến để ghi nhớ đang chọn loại đạn số mấy (bắt đầu từ 0)
var current_bullet_index: int = 0
var last_direction: Vector2 = Vector2.RIGHT #Biến ghi nhớ hướng của mũi phi thuyền, mặc định là hướng sang phải

func _ready():
	# Lấy kích thước màn hình game
	var screen_size = get_viewport_rect().size
	# Vị trí xuất hiện: Chính giữa biên trái (x = 50 để không bị lẹm hình, y = một nửa chiều cao)
	position = Vector2(50, screen_size.y / 2)
	rotation = last_direction.angle()

func _process(delta):
	# Logic di chuyển linh hoạt (Dùng phím mũi tên hoặc WASD để test trên PC)
	var velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if velocity.length() > 0:
		position += velocity * speed * delta
		last_direction = velocity #Ghi nhớ hướng vừa đi
		rotation = velocity.angle() #Xoay thân tàu

func _input(event):
	# Bắt sự kiện chạm màn hình 
	if event is InputEventScreenTouch and event.pressed:
		shoot()
	# Thêm nút để đổi loại đạn (Ví dụ: Nhấn phím Space)
	if event.is_action_pressed("ui_accept"):
		switch_weapon()

# Hàm xử lý đổi đạn
func switch_weapon():
	# Kiểm tra xem bạn có bỏ đạn vào mảng chưa
	if bullet_scenes.size() > 0:
		# Tăng index lên 1. Nếu vượt quá số lượng đạn thì quay vòng về 0
		current_bullet_index = (current_bullet_index + 1) % bullet_scenes.size()
		print("Đang dùng đạn số: ", current_bullet_index)
		
func shoot():
	# Lấy ra loại đạn hiện tại đang được chọn
	if bullet_scenes.size() > 0 and bullet_scenes[current_bullet_index] != null:
		var bullet = bullet_scenes[current_bullet_index].instantiate()  #Khởi tạo ra object C
		bullet.position = position  #Truyền vị trí
		bullet.direction = last_direction  #Truyền hướng
		get_parent().add_child(bullet)     #Đưa obj C ra màn hình
