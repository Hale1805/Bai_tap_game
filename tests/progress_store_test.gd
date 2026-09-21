extends SceneTree

const PROGRESS_STORE_PATH := "res://Scripts/progress_store.gd"
const TEST_SAVE_PATH := "res://tests/campaign_progress_test.cfg"

var failures := 0

func _init() -> void:
	var progress_store_script = load(PROGRESS_STORE_PATH)
	_expect(progress_store_script != null, "ProgressStore script must exist")
	if progress_store_script == null:
		_finish()
		return
	var store = progress_store_script.new()
	store.storage_path = TEST_SAVE_PATH
	store.reset_progress()

	var defaults: Dictionary = store.load_progress()
	_expect(defaults.unlocked_level == 1, "new progress must unlock only level 1")
	_expect(defaults.gold == 0, "new progress must start with zero gold")

	store.complete_level(1, 50, 10)
	var completed_once: Dictionary = store.load_progress()
	_expect(completed_once.unlocked_level == 2, "completing level 1 must unlock level 2")
	_expect(completed_once.completed.get("1", false), "level 1 must be marked complete")
	_expect(completed_once.best_scores.get("1", 0) == 50, "first score must be stored")
	_expect(completed_once.gold == 10, "completion gold must be persisted")

	store.complete_level(1, 20, 0)
	var lower_score: Dictionary = store.load_progress()
	_expect(lower_score.best_scores.get("1", 0) == 50, "lower score must not replace the best score")
	_expect(store.has_method("save_checkpoint"), "ProgressStore must expose checkpoint saving for Pause")
	if store.has_method("save_checkpoint"):
		store.save_checkpoint(1, 120, 7, 3.0, 0.0)
		var checkpoint_progress: Dictionary = store.load_progress()
		_expect(checkpoint_progress.checkpoint.get("level_id", 0) == 1, "pause checkpoint must retain level id")
		_expect(checkpoint_progress.checkpoint.get("score", 0) == 120, "pause checkpoint must retain score")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
	_finish()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _finish() -> void:
	if failures == 0:
		print("progress_store_test: PASS")
	quit(0 if failures == 0 else 1)
