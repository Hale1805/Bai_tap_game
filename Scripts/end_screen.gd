extends CanvasLayer

const BOSS_BLAST_SCENE = preload("res://Scripts/boss_blast.gd")

var panel: ColorRect
var title: Label
var current_level_id := 1
var replay_button: Button
var next_or_progress_button: Button
var boss_blast: Control

func _ready() -> void:
	panel = ColorRect.new()
	panel.color = Color(0.03, 0.02, 0.10, 0.92)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)
	boss_blast = BOSS_BLAST_SCENE.new()
	panel.add_child(boss_blast)
	title = Label.new()
	title.position = Vector2(0, 150)
	title.size = Vector2(1152, 130)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 46)
	panel.add_child(title)
	replay_button = _add_button("CHƠI LẠI", 370, func(): SceneRouter.go_gameplay(current_level_id))
	_add_button("HOME", 490, SceneRouter.go_home)
	next_or_progress_button = _add_button("TIẾN TRÌNH", 610, _on_next_or_progress_pressed)
	visible = false

func show_win(level_id: int) -> void:
	current_level_id = level_id
	replay_button.text = "CHƠI LẠI"
	next_or_progress_button.text = "MÀN TIẾP THEO" if level_id < 3 else "TIẾN TRÌNH"
	title.text = "MISSION COMPLETE!\nLEVEL %d ĐÃ HOÀN THÀNH" % level_id
	panel.color = Color(0.02, 0.13, 0.10, 0.92)
	visible = true
	AudioManager.play_sfx(&"win")

func show_loss(level_id: int) -> void:
	current_level_id = level_id
	replay_button.text = "CHƠI LẠI"
	next_or_progress_button.text = "TIẾN TRÌNH"
	title.text = "GAME OVER\nTÀU CỦA BẠN ĐÃ BỊ PHÁ HỦY"
	panel.color = Color(0.16, 0.02, 0.04, 0.92)
	visible = true
	AudioManager.play_sfx(&"explosion")

func show_game_complete() -> void:
	current_level_id = 1
	replay_button.text = "BẮT ĐẦU LẠI"
	next_or_progress_button.text = "TIẾN TRÌNH"
	title.text = "GAME COMPLETE!\nALIEN CORE DESTROYED"
	panel.color = Color(0.03, 0.12, 0.16, 0.92)
	visible = true
	boss_blast.play()
	AudioManager.queue_game_victory()

func _add_button(text_value: String, y: float, action: Callable) -> Button:
	var button := Button.new()
	button.text = text_value
	button.position = Vector2(460, y)
	button.size = Vector2(230, 48)
	button.add_theme_font_size_override("font_size", 18)
	button.pressed.connect(action)
	panel.add_child(button)
	return button

func _on_next_or_progress_pressed() -> void:
	if current_level_id < 3:
		SceneRouter.go_gameplay(current_level_id + 1)
	else:
		SceneRouter.go_progress()
