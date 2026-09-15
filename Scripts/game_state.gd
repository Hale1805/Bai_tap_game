extends Node

signal state_changed
signal game_over

enum AttackType {
	BULLET,
	MISSILE,
	BOMB,
}

class DamageResult:
	var absorbed_by_shield: bool = false
	var armor_lost: float = 0.0
	var health_lost: float = 0.0
	var defeated: bool = false

var max_health: float = 100.0
var max_armor: float = 50.0
var health: float = max_health
var armor: float = max_armor
var gold: int = 0
var coins: int = 0
var score: int = 0
var shield_active: bool = false
var is_game_over: bool = false
var debuffs: Dictionary = {}
var buffs: Dictionary = {}
var selected_attack: AttackType = AttackType.BULLET

func reset() -> void:
	health = max_health
	armor = max_armor
	gold = 0
	coins = 0
	score = 0
	shield_active = false
	is_game_over = false
	debuffs.clear()
	buffs.clear()
	selected_attack = AttackType.BULLET
	state_changed.emit()

func apply_damage(amount: float) -> DamageResult:
	var result := DamageResult.new()
	var remaining_damage := maxf(amount, 0.0)
	if shield_active:
		result.absorbed_by_shield = remaining_damage > 0.0
		return result

	result.armor_lost = minf(armor, remaining_damage)
	armor -= result.armor_lost
	remaining_damage -= result.armor_lost
	result.health_lost = minf(health, remaining_damage)
	health -= result.health_lost
	result.defeated = health <= 0.0
	state_changed.emit()
	if result.defeated and not is_game_over:
		is_game_over = true
		game_over.emit()
	return result

func add_reward(gold_amount: int, score_amount: int, armor_amount: float = 0.0) -> void:
	gold += maxi(gold_amount, 0)
	score += maxi(score_amount, 0)
	armor = minf(max_armor, armor + maxf(armor_amount, 0.0))
	state_changed.emit()

func set_shield(active: bool) -> void:
	shield_active = active
	state_changed.emit()

func select_attack(attack: AttackType) -> void:
	selected_attack = attack
	state_changed.emit()

func apply_debuff(name: String, duration: float) -> void:
	debuffs[name] = maxf(debuffs.get(name, 0.0), duration)
	state_changed.emit()

func apply_buff(name: String, duration: float) -> void:
	buffs[name] = maxf(buffs.get(name, 0.0), duration)
	state_changed.emit()

func _process(delta: float) -> void:
	var changed := false
	for name in debuffs.keys():
		debuffs[name] = maxf(debuffs[name] - delta, 0.0)
		if debuffs[name] <= 0.0:
			debuffs.erase(name)
		changed = true
	for name in buffs.keys():
		buffs[name] = maxf(buffs[name] - delta, 0.0)
		if buffs[name] <= 0.0:
			buffs.erase(name)
		changed = true
	if changed:
		state_changed.emit()
