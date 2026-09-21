extends Control

func _ready() -> void:
	var title := Label.new()
	title.text = "SPACE CAMPAIGN"
	title.position = Vector2(70, 54)
	title.add_theme_font_size_override("font_size", 42)
	add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Chọn nhiệm vụ"
	subtitle.position = Vector2(75, 118)
	subtitle.add_theme_font_size_override("font_size", 20)
	add_child(subtitle)
	var progress: Dictionary = ProgressStore.load_progress()
	for level_id in 3:
		var button := Button.new()
		var id := level_id + 1
		button.text = "LEVEL %d  %s" % [id, LevelManager.LEVELS[id].title]
		button.position = Vector2(75, 170 + level_id * 58)
		button.size = Vector2(360, 44)
		button.disabled = id > int(progress.unlocked_level)
		button.pressed.connect(func(): SceneRouter.go_gameplay(id))
		add_child(button)
	var progress_button := Button.new()
	progress_button.text = "TIẾN TRÌNH"
	progress_button.position = Vector2(75, 365)
	progress_button.size = Vector2(170, 42)
	progress_button.pressed.connect(SceneRouter.go_progress)
	add_child(progress_button)
