extends Node

signal level_started(level_id: int)
signal objective_changed(current: float, target: float)
signal level_won(level_id: int)
signal level_lost(level_id: int)

const LEVELS := {
	1: {"id": 1, "title": "Moon Patrol", "objective_kind": &"defeat", "target": 5.0, "background_mode": 0, "max_active_npcs": 4, "allowed_npcs": [&"hunter"]},
	2: {"id": 2, "title": "Meteor Storm", "objective_kind": &"survive", "target": 45.0, "defeat_target": 8.0, "background_mode": 1, "max_active_npcs": 7, "allowed_npcs": [&"hunter", &"scout"]},
	3: {"id": 3, "title": "Alien Core", "objective_kind": &"core", "target": 1.0, "background_mode": 2, "max_active_npcs": 8, "allowed_npcs": [&"hunter", &"scout", &"guardian"]},
}

var progress_store: Node
var game_state: Node
var current_level_id := 0
var objective_progress := 0.0
var survival_progress := 0.0
var gameplay_active := false
var terminal_emitted := false

func _ready() -> void:
	if progress_store == null:
		progress_store = get_node_or_null("/root/ProgressStore")
	game_state = get_node_or_null("/root/GameState")

func start_level(level_id: int) -> bool:
	if not LEVELS.has(level_id) or progress_store == null:
		push_warning("LevelManager could not start invalid or unavailable level: %d" % level_id)
		return false
	var progress: Dictionary = progress_store.load_progress()
	if level_id > int(progress.unlocked_level):
		push_warning("LevelManager blocked locked level: %d" % level_id)
		return false
	current_level_id = level_id
	objective_progress = 0.0
	survival_progress = 0.0
	terminal_emitted = false
	gameplay_active = true
	if game_state != null:
		game_state.reset()
	level_started.emit(level_id)
	return true

func register_enemy_defeat(npc_type: StringName) -> void:
	if not gameplay_active or terminal_emitted:
		return
	var definition: Dictionary = LEVELS.get(current_level_id, {})
	if definition.is_empty():
		return
	if definition.objective_kind == &"defeat":
		objective_progress += 1.0
		objective_changed.emit(objective_progress, definition.target)
		if objective_progress >= float(definition.target):
			_win_level()
	elif definition.objective_kind == &"survive":
		objective_progress += 1.0
		objective_changed.emit(objective_progress, float(definition.defeat_target))
		if objective_progress >= float(definition.defeat_target) and survival_progress >= float(definition.target):
			_win_level()
	elif definition.objective_kind == &"core" and npc_type == &"guardian":
		objective_progress = 1.0
		objective_changed.emit(objective_progress, float(definition.target))
		_win_level()

func register_survival_tick(delta: float) -> void:
	if not gameplay_active or terminal_emitted or current_level_id != 2:
		return
	survival_progress = minf(survival_progress + maxf(delta, 0.0), float(LEVELS[2].target))
	objective_changed.emit(survival_progress, float(LEVELS[2].target))
	if survival_progress >= float(LEVELS[2].target) and objective_progress >= float(LEVELS[2].defeat_target):
		_win_level()

func end_game_over() -> void:
	if not gameplay_active or terminal_emitted:
		return
	gameplay_active = false
	terminal_emitted = true
	level_lost.emit(current_level_id)

func stop_gameplay() -> void:
	gameplay_active = false

func get_current_definition() -> Dictionary:
	return LEVELS.get(current_level_id, {}).duplicate(true)

func _win_level() -> void:
	if terminal_emitted:
		return
	gameplay_active = false
	terminal_emitted = true
	var score := int(game_state.score) if game_state != null else 0
	var gold := int(game_state.gold) if game_state != null else 0
	progress_store.complete_level(current_level_id, score, gold)
	level_won.emit(current_level_id)
