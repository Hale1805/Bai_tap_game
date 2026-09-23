extends SceneTree

const LEVEL_MANAGER_PATH := "res://Scripts/level_manager.gd"
const ProgressStoreScript = preload("res://Scripts/progress_store.gd")
const GameStateScript = preload("res://Scripts/game_state.gd")

var failures := 0

func _init() -> void:
	var manager_script = load(LEVEL_MANAGER_PATH)
	_expect(manager_script != null, "LevelManager script must exist")
	if manager_script == null:
		_finish()
		return
	var manager = manager_script.new()
	root.add_child(manager)
	var game_state = GameStateScript.new()
	game_state.reset()
	manager.game_state = game_state
	var store = ProgressStoreScript.new()
	store.storage_path = "res://tests/level_manager_progress_test.cfg"
	store.reset_progress()
	manager.progress_store = store
	_expect(not manager.start_level(2), "locked level 2 must not start")
	var wins: Array[int] = []
	manager.level_won.connect(func(level_id: int): wins.append(level_id))
	_expect(manager.start_level(1), "unlocked level 1 must start")
	_expect(manager.has_method("complete_current_level_for_demo"), "LevelManager must expose demo completion")
	if manager.has_method("complete_current_level_for_demo"):
		manager.complete_current_level_for_demo()
		_expect(wins.size() == 1, "demo completion must win the active level")
		_expect(manager.start_level(1), "level 1 must be replayable after demo completion")
	for index in 5:
		manager.register_enemy_defeat(&"hunter")
	_expect(wins.size() == 2, "level 1 must emit exactly one additional win after five defeats")
	_expect(game_state.score == 500, "destroying five Hunters must award 500 score without awarding Gold")
	_expect(manager.start_level(1), "level 1 must be replayable before testing a game-over score")
	game_state.add_reward(0, 700)
	manager.end_game_over()
	_expect(store.load_progress().best_scores.get("1", 0) == 700, "game over must persist the current score as a high score")
	var objective_before: float = manager.objective_progress
	manager.register_survival_tick(10.0)
	_expect(manager.objective_progress == objective_before, "game over must stop objective progression")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(store.storage_path))
	manager.queue_free()
	_finish()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _finish() -> void:
	if failures == 0:
		print("level_manager_test: PASS")
	quit(0 if failures == 0 else 1)
