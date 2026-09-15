extends SceneTree

# These assertions must fail if damage stops consuming armor before health,
# if an active shield no longer absorbs damage, or if reward values regress.
const GameStateScript = preload("res://Scripts/game_state.gd")

func _init() -> void:
	var state = GameStateScript.new()
	state.reset()

	var damage_result = state.apply_damage(60.0)
	_expect(damage_result.armor_lost == 50.0, "60 damage must remove all 50 armor")
	_expect(damage_result.health_lost == 10.0, "60 damage must remove remaining 10 health")
	_expect(state.health == 90.0, "health must be 90 after armor-first damage")

	state.reset()
	state.set_shield(true)
	var shield_result = state.apply_damage(999.0)
	_expect(shield_result.absorbed_by_shield, "shield must absorb incoming damage")
	_expect(state.health == 100.0 and state.armor == 50.0, "shielded state must not lose health or armor")

	state.reset()
	state.add_reward(5, 10, 100.0)
	_expect(state.gold == 5 and state.score == 10, "reward must increase gold and score")
	_expect(state.armor == state.max_armor, "armor reward must clamp to max armor")

	state.reset()
	state.apply_damage(150.0)
	_expect(state.is_game_over, "lethal damage must set game-over state")

	state.reset()
	state.apply_debuff("SLOW", 3.0)
	_expect(state.debuffs.has("SLOW"), "applying a debuff must make it visible to the HUD")
	state.apply_buff("SPEED UP", 3.0)
	_expect(state.buffs.has("SPEED UP"), "applying a buff must make it visible to the HUD")

	print("game_state_test: PASS")
	quit(0)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		quit(1)
