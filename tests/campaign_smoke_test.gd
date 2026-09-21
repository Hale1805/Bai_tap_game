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
	manager.register_enemy_defeat(&"guardian")
	_expect(store.load_progress().completed.get("3", false), "Guardian defeat must complete level 3")
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
