extends CanvasLayer

var panel: ColorRect
var title: Label
var current_level_id := 1

func _ready() -> void:
	panel = ColorRect.new()
	panel.color = Color(0.03, 0.02, 0.10, 0.92)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)
	title = Label.new()
	title.position = Vector2(0, 150)
	title.size = Vector2(1152, 130)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 46)
	panel.add_child(title)
	_add_button("CHƠI LẠI", 370, func(): SceneRouter.go_gameplay(current_level_id))
	_add_button("HOME", 490, SceneRouter.go_home)
	_add_button("TIẾN TRÌNH", 610, SceneRouter.go_progress)
	visible = false

func show_win(level_id: int) -> void:
	current_level_id = level_id
	title.text = "MISSION COMPLETE!\nLEVEL %d ĐÃ HOÀN THÀNH" % level_id
	panel.color = Color(0.02, 0.13, 0.10, 0.92)
	visible = true
	AudioManager.play_sfx(&"win")

func show_loss(level_id: int) -> void:
	current_level_id = level_id
	title.text = "GAME OVER\nTÀU CỦA BẠN ĐÃ BỊ PHÁ HỦY"
	panel.color = Color(0.16, 0.02, 0.04, 0.92)
	visible = true
	AudioManager.play_sfx(&"explosion")

func _add_button(text_value: String, y: float, action: Callable) -> void:
	var button := Button.new()
	button.text = text_value
	button.position = Vector2(460, y)
	button.size = Vector2(230, 48)
	button.add_theme_font_size_override("font_size", 18)
	button.pressed.connect(action)
	panel.add_child(button)
