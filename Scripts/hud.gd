extends CanvasLayer

var status_label: Label
var weapon_label: Label
var debuff_label: Label
var buff_label: Label
var objective_label: Label
var sound_toggle: Button
var music_toggle: Button
var end_overlay: ColorRect
var end_label: Label

func _ready() -> void:
	add_to_group("hud")
	var panel := ColorRect.new()
	panel.color = Color(0.02, 0.05, 0.12, 0.8)
	panel.position = Vector2(12, 12)
	panel.size = Vector2(430, 164)
	add_child(panel)
	status_label = Label.new()
	status_label.position = Vector2(24, 20)
	status_label.add_theme_font_size_override("font_size", 18)
	add_child(status_label)
	weapon_label = Label.new()
	weapon_label.position = Vector2(24, 82)
	add_child(weapon_label)
	debuff_label = Label.new()
	debuff_label.position = Vector2(24, 112)
	debuff_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.25))
	debuff_label.add_theme_font_size_override("font_size", 16)
	add_child(debuff_label)
	buff_label = Label.new()
	buff_label.position = Vector2(24, 136)
	buff_label.add_theme_color_override("font_color", Color(0.25, 0.95, 0.65))
	buff_label.add_theme_font_size_override("font_size", 16)
	add_child(buff_label)
	objective_label = Label.new()
	objective_label.position = Vector2(570, 20)
	objective_label.add_theme_font_size_override("font_size", 18)
	objective_label.add_theme_color_override("font_color", Color(0.85, 0.95, 1.0))
	add_child(objective_label)
	_add_action_button("Đạn [1]", Vector2(18, 192), func(): _player().try_attack(GameState.AttackType.BULLET))
	_add_action_button("Tên lửa [2]", Vector2(118, 192), func(): _player().try_attack(GameState.AttackType.MISSILE))
	_add_action_button("Bom [3]", Vector2(238, 192), func(): _player().try_attack(GameState.AttackType.BOMB))
	_add_action_button("Khiên [Q]", Vector2(18, 238), func(): _player().activate_shield())
	_add_action_button("Đóng băng [E]", Vector2(118, 238), func(): _player().activate_freeze())
	sound_toggle = _add_action_button("SoundOff", Vector2(430, 18), _toggle_sfx)
	music_toggle = _add_action_button("MusicOn", Vector2(430, 62), _toggle_music)
	GameState.state_changed.connect(refresh)
	LevelManager.objective_changed.connect(func(_current: float, _target: float): refresh())
	_create_end_overlay()
	refresh()
func _add_action_button(text: String, position_value: Vector2, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = position_value
	button.size = Vector2(105, 38)
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(action)
	add_child(button)
	return button
func _player() -> Node:
	return get_tree().get_first_node_in_group("player")
func _toggle_sfx() -> void:
	AudioManager.set_sfx_enabled(not AudioManager.sfx_enabled)
	sound_toggle.text = "SoundOff" if AudioManager.sfx_enabled else "SoundOn"
func _toggle_music() -> void:
	AudioManager.set_music_enabled(not AudioManager.music_enabled)
	music_toggle.text = "MusicOff" if AudioManager.music_enabled else "MusicOn"
func refresh() -> void:
	status_label.text = "HP: %d / %d    Armor: %d / %d\nGold: %d    Score: %d" % [GameState.health, GameState.max_health, GameState.armor, GameState.max_armor, GameState.gold, GameState.score]
	var names := ["Đạn", "Tên lửa", "Bom"]
	weapon_label.text = "Vũ khí: %s    Khiên: %s" % [names[int(GameState.selected_attack)], "BẬT" if GameState.shield_active else "TẮT"]
	if GameState.debuffs.is_empty():
		debuff_label.text = ""
	else:
		var active := []
		for effect_name in GameState.debuffs:
			active.append("%s %.1fs" % [effect_name, GameState.debuffs[effect_name]])
		debuff_label.text = "DEBUFF: " + " | ".join(active)
	if GameState.buffs.is_empty():
		buff_label.text = ""
	else:
		var active_buffs := []
		for effect_name in GameState.buffs:
			active_buffs.append("%s %.1fs" % [effect_name, GameState.buffs[effect_name]])
		buff_label.text = "BUFF: " + " | ".join(active_buffs)
	var definition := LevelManager.get_current_definition()
	if definition.is_empty():
		objective_label.text = ""
	else:
		var objective := "Tiêu diệt %d / %d" % [int(LevelManager.objective_progress), int(definition.target)]
		if int(definition.id) == 2:
			objective = "Sống sót %d / %ds | Hạ %d / %d" % [int(LevelManager.survival_progress), int(definition.target), int(LevelManager.objective_progress), int(definition.defeat_target)]
		objective_label.text = "%s\n%s" % [definition.title, objective]

func _create_end_overlay() -> void:
	end_overlay = ColorRect.new()
	end_overlay.color = Color(0.05, 0.0, 0.0, 0.78)
	end_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	end_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	end_label = Label.new()
	end_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	end_label.size = Vector2(460, 150)
	end_label.position -= end_label.size / 2.0
	end_label.add_theme_font_size_override("font_size", 46)
	end_overlay.add_child(end_label)
	end_overlay.visible = false
	add_child(end_overlay)

func show_game_over() -> void:
	end_label.text = "GAME OVER\nA ĐÃ BỊ PHÁ HỦY"
	end_overlay.visible = true
