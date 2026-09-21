extends SceneTree

const HunterScript = preload("res://Scripts/npc_hunter.gd")
const ScoutScript = preload("res://Scripts/npc_scout.gd")
const GuardianScript = preload("res://Scripts/npc_guardian.gd")

var failures := 0

func _init() -> void:
	var target := Node2D.new()
	target.global_position = Vector2.ZERO
	root.add_child(target)
	var hunter = HunterScript.new()
	hunter.global_position = Vector2(400, 0)
	hunter.configure(target, 1)
	root.add_child(hunter)
	var hunter_before: float = hunter.global_position.distance_to(target.global_position)
	hunter._process(0.5)
	_expect(hunter.global_position.distance_to(target.global_position) < hunter_before, "Hunter must move closer to A")
	hunter.freeze(2.0)
	var frozen_position: Vector2 = hunter.global_position
	hunter._process(0.5)
	_expect(hunter.global_position == frozen_position, "freeze must stop Hunter")

	var scout = ScoutScript.new()
	scout.global_position = Vector2(80, 0)
	scout.configure(target, 2)
	root.add_child(scout)
	scout._process(1.0)
	_expect(scout.global_position.distance_to(target.global_position) > 80.0, "Scout must retreat when too close")

	var guardian = GuardianScript.new()
	guardian.configure(target, 3)
	root.add_child(guardian)
	_expect(guardian.has_method("take_damage") and guardian.has_method("freeze"), "Guardian must follow NPC combat contract")
	hunter.queue_free()
	scout.queue_free()
	guardian.queue_free()
	target.queue_free()
	_finish()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _finish() -> void:
	if failures == 0:
		print("npc_behavior_test: PASS")
	quit(0 if failures == 0 else 1)
