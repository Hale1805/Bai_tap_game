extends SceneTree

const LevelManagerScript = preload("res://Scripts/level_manager.gd")
const ProgressStoreScript = preload("res://Scripts/progress_store.gd")

var failures := 0

func _init() -> void:
	var store = ProgressStoreScript.new()
	store.storage_path = "res://tests/campaign_smoke_progress.cfg"
	store.reset_progress()
	var manager = LevelManagerScript.new()
	manager.progress_store = store
	root.add_child(manager)
	_expect(manager.start_level(1), "campaign must start at level 1")
	for index in 5:
		manager.register_enemy_defeat(&"hunter")
	_expect(store.load_progress().unlocked_level == 2, "level 1 win must unlock level 2")
	_expect(manager.start_level(2), "level 2 must start after level 1 win")
	manager.register_survival_tick(45.0)
	for index in 8:
		manager.register_enemy_defeat(&"scout")
	_expect(store.load_progress().unlocked_level == 3, "level 2 win must unlock level 3")
	_expect(manager.start_level(3), "level 3 must start after level 2 win")
	var level_three: Dictionary = manager.get_current_definition()
	_expect(int(level_three.get("escort_count", 0)) == 3, "level 3 must start with three Guardian escorts")
	_expect(level_three.get("allowed_npcs", []).has(&"guardian"), "level 3 must include the Guardian boss")
	store.record_score(1, 777)
	manager.register_enemy_defeat(&"guardian")
	var reset_progress: Dictionary = store.load_progress()
	_expect(reset_progress.unlocked_level == 1, "Guardian defeat must reset campaign to level 1")
	_expect(reset_progress.completed.is_empty(), "Guardian defeat must clear completed campaign levels")
	_expect(reset_progress.best_scores.get("1", 0) == 777, "Guardian defeat must keep high scores after the campaign reset")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(store.storage_path))
	manager.queue_free()
	_finish()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _finish() -> void:
	if failures == 0:
		print("campaign_smoke_test: PASS")
	quit(0 if failures == 0 else 1)
