extends AnimatedSprite2D

func _ready():
	# Kết nối tín hiệu chạy xong animation thẳng vào lệnh tự hủy
	animation_finished.connect(queue_free)
