extends Node

const HOME_SCENE := "res://home.tscn"
const PROGRESS_SCENE := "res://progress.tscn"
const GAMEPLAY_SCENE := "res://main.tscn"

func go_home() -> void:
	LevelManager.stop_gameplay()
	get_tree().change_scene_to_file(HOME_SCENE)

func go_progress() -> void:
	LevelManager.stop_gameplay()
	get_tree().change_scene_to_file(PROGRESS_SCENE)

func go_gameplay(level_id: int) -> void:
	if not LevelManager.start_level(level_id):
		return
	get_tree().change_scene_to_file(GAMEPLAY_SCENE)
