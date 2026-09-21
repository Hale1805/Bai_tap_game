extends Control

func _ready() -> void:
	var progress: Dictionary = ProgressStore.load_progress()
	var heading := Label.new()
	heading.text = "TIẾN TRÌNH CHIẾN DỊCH"
	heading.position = Vector2(65, 54)
	heading.add_theme_font_size_override("font_size", 34)
	add_child(heading)
	var details := Label.new()
	details.position = Vector2(70, 126)
	details.add_theme_font_size_override("font_size", 20)
	var rows: Array[String] = ["Gold tích lũy: %d" % int(progress.gold)]
	for level_id in 3:
		var key := str(level_id + 1)
		rows.append("Level %s: %s | High score: %d" % [key, "Đã hoàn thành" if progress.completed.get(key, false) else "Chưa hoàn thành", int(progress.best_scores.get(key, 0))])
	details.text = "\n".join(rows)
	add_child(details)
	var home_button := Button.new()
	home_button.text = "HOME"
	home_button.position = Vector2(70, 330)
	home_button.size = Vector2(150, 42)
	home_button.pressed.connect(SceneRouter.go_home)
	add_child(home_button)
