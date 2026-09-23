extends Node

const SAVE_PATH := "user://campaign_progress.cfg"
const MIN_LEVEL := 1
const MAX_LEVEL := 3

var storage_path := SAVE_PATH

func load_progress() -> Dictionary:
	var config := ConfigFile.new()
	var load_result := config.load(storage_path)
	if load_result != OK:
		return _default_progress()
	return _sanitize_progress({
		"unlocked_level": config.get_value("campaign", "unlocked_level", MIN_LEVEL),
		"completed": config.get_value("campaign", "completed", {}),
		"best_scores": config.get_value("campaign", "best_scores", {}),
		"gold": config.get_value("campaign", "gold", 0),
		"checkpoint": config.get_value("campaign", "checkpoint", {}),
	})

func complete_level(level_id: int, score: int, gold: int) -> void:
	if level_id < MIN_LEVEL or level_id > MAX_LEVEL:
		push_warning("ProgressStore ignored invalid level id: %d" % level_id)
		return
	var progress := load_progress()
	var level_key := str(level_id)
	progress.completed[level_key] = true
	progress.best_scores[level_key] = maxi(int(progress.best_scores.get(level_key, 0)), maxi(score, 0))
	progress.gold = maxi(int(progress.gold) + gold, 0)
	progress.unlocked_level = mini(MAX_LEVEL, maxi(int(progress.unlocked_level), level_id + 1))
	_save_progress(progress)

func record_score(level_id: int, score: int) -> void:
	if level_id < MIN_LEVEL or level_id > MAX_LEVEL:
		push_warning("ProgressStore ignored score for invalid level id: %d" % level_id)
		return
	var progress := load_progress()
	var level_key := str(level_id)
	progress.best_scores[level_key] = maxi(int(progress.best_scores.get(level_key, 0)), maxi(score, 0))
	_save_progress(progress)

func reset_progress(keep_best_scores: bool = false) -> void:
	var reset_data := _default_progress()
	if keep_best_scores:
		reset_data.best_scores = load_progress().best_scores.duplicate(true)
	_save_progress(reset_data)

func save_checkpoint(level_id: int, score: int, gold: int, objective: float, survival: float) -> void:
	if level_id < MIN_LEVEL or level_id > MAX_LEVEL:
		push_warning("ProgressStore ignored checkpoint for invalid level: %d" % level_id)
		return
	var progress := load_progress()
	progress.checkpoint = {
		"level_id": level_id,
		"score": maxi(score, 0),
		"gold": maxi(gold, 0),
		"objective": maxf(objective, 0.0),
		"survival": maxf(survival, 0.0),
	}
	_save_progress(progress)

func _default_progress() -> Dictionary:
	return {
		"unlocked_level": MIN_LEVEL,
		"completed": {},
		"best_scores": {},
		"gold": 0,
		"checkpoint": {},
	}

func _sanitize_progress(progress: Dictionary) -> Dictionary:
	var completed = progress.get("completed", {})
	var best_scores = progress.get("best_scores", {})
	var checkpoint = progress.get("checkpoint", {})
	return {
		"unlocked_level": clampi(int(progress.get("unlocked_level", MIN_LEVEL)), MIN_LEVEL, MAX_LEVEL),
		"completed": completed if completed is Dictionary else {},
		"best_scores": best_scores if best_scores is Dictionary else {},
		"gold": maxi(int(progress.get("gold", 0)), 0),
		"checkpoint": checkpoint if checkpoint is Dictionary else {},
	}

func _save_progress(progress: Dictionary) -> void:
	var config := ConfigFile.new()
	config.set_value("campaign", "unlocked_level", progress.unlocked_level)
	config.set_value("campaign", "completed", progress.completed)
	config.set_value("campaign", "best_scores", progress.best_scores)
	config.set_value("campaign", "gold", progress.gold)
	config.set_value("campaign", "checkpoint", progress.checkpoint)
	var save_result := config.save(storage_path)
	if save_result != OK:
		push_warning("ProgressStore could not save campaign progress: %s" % storage_path)
