extends SceneTree

var failures := 0

func _init() -> void:
	var script_source := FileAccess.get_file_as_string("res://Scripts/end_screen.gd")
	_expect(script_source.contains("const RESULT_BUTTON_Y := 530.0"), "The Progress/Next button must use a safe y-coordinate")
	_expect(script_source.contains("var is_game_complete := false"), "EndScreen must track the campaign-complete state separately")
	_expect(script_source.contains("var is_game_over := false"), "EndScreen must track the game-over state separately")
	_expect(script_source.contains("if is_game_complete or is_game_over:\n\t\tSceneRouter.go_progress()\n\t\treturn"), "Game-over Progress button must route directly to Progress")
	_finish()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _finish() -> void:
	if failures == 0:
		print("end_screen_layout_test: PASS")
	quit(0 if failures == 0 else 1)
