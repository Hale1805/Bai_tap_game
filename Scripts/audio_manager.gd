extends Node

var sfx_enabled := true
var music_enabled := false
var sfx_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var sfx_playback: AudioStreamGeneratorPlayback
var music_playback: AudioStreamGeneratorPlayback
var sfx_time := 0.0
var sfx_duration := 0.12
var sfx_phase := 0.0
var sfx_frequency := 440.0
var is_explosion := false
var sfx_effect: StringName = &""
var victory_delay := -1.0
var music_phase := 0.0
var music_time := 0.0
var warning_left := 0
var warning_delay := 0.0

func _ready() -> void:
	GameState.game_over.connect(func(): play_sfx(&"explosion"))
	sfx_player = _new_generator_player(0.15)
	music_player = _new_generator_player(0.4)
	sfx_player.play()
	music_player.play()
	sfx_playback = sfx_player.get_stream_playback()
	music_playback = music_player.get_stream_playback()

func _process(delta: float) -> void:
	sfx_time = maxf(sfx_time - delta, 0.0)
	if victory_delay >= 0.0:
		victory_delay -= delta
		if victory_delay <= 0.0:
			play_sfx(&"game_win")
	if warning_left > 0:
		warning_delay -= delta
		if warning_delay <= 0.0:
			play_sfx(&"warning")
			warning_left -= 1
			warning_delay = 0.32
	_fill_sfx()
	_fill_music()

func set_sfx_enabled(enabled: bool) -> void:
	sfx_enabled = enabled
	if not enabled: sfx_time = 0.0
func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
func play_sfx(effect: StringName) -> void:
	if not sfx_enabled: return
	var tones := {&"shoot": 760.0, &"hit": 180.0, &"shield": 520.0, &"freeze": 320.0, &"explosion": 110.0, &"boss_explosion": 76.0, &"warning": 920.0, &"win": 660.0, &"game_win": 523.0}
	sfx_effect = effect
	sfx_frequency = tones.get(effect, 440.0)
	is_explosion = effect == &"explosion" or effect == &"hit"
	sfx_duration = 1.35 if effect == &"boss_explosion" else (0.58 if is_explosion else (1.75 if effect == &"game_win" else (0.34 if effect == &"win" else 0.12)))
	sfx_time = sfx_duration

func queue_game_victory() -> void:
	victory_delay = 1.15
func play_danger_warning(repetitions: int) -> void:
	if not sfx_enabled: return
	warning_left = clampi(repetitions, 3, 6)
	warning_delay = 0.0
func _new_generator_player(buffer_length: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = buffer_length
	player.stream = stream
	add_child(player)
	return player
func _fill_sfx() -> void:
	if sfx_playback == null: return
	for frame in sfx_playback.get_frames_available():
		var sample := 0.0
		if sfx_time > 0.0 and sfx_enabled:
			var progress := 1.0 - sfx_time / sfx_duration
			if sfx_effect == &"boss_explosion":
				var boss_frequency := lerpf(76.0, 22.0, progress)
				var boss_envelope := pow(1.0 - progress, 1.35)
				var rumble := sin(sfx_phase) * 0.42 + sin(sfx_phase * 0.47) * 0.28
				var debris := randf_range(-0.38, 0.38) * (1.0 - progress)
				var shockwave := sin(sfx_phase * 0.13) * 0.18 * pow(1.0 - progress, 2.0)
				sample = (rumble + debris + shockwave) * boss_envelope
				sfx_phase += TAU * boss_frequency / 22050.0
			elif sfx_effect == &"game_win":
				var notes := [523.25, 659.25, 783.99, 1046.5]
				var note_index := mini(int(progress * 4.0), notes.size() - 1)
				var win_frequency: float = notes[note_index]
				var win_envelope := minf(progress * 7.0, 1.0) * pow(1.0 - progress, 0.45)
				sample = (sin(sfx_phase) * 0.24 + sin(sfx_phase * 0.5) * 0.10) * win_envelope
				sfx_phase += TAU * win_frequency / 22050.0
			elif is_explosion:
				var boom_frequency := lerpf(sfx_frequency, 38.0, progress)
				var envelope := pow(1.0 - progress, 1.7)
				sample = (sin(sfx_phase) * 0.45 + sin(sfx_phase * 0.47) * 0.3 + randf_range(-0.22, 0.22)) * envelope
				sfx_phase += TAU * boom_frequency / 22050.0
			else:
				sample = sin(sfx_phase) * 0.22
				sfx_phase += TAU * sfx_frequency / 22050.0
		sfx_playback.push_frame(Vector2(sample, sample))

func _fill_music() -> void:
	if music_playback == null:
		return
	for frame in music_playback.get_frames_available():
		var sample := 0.0
		if music_enabled:
			var drone_frequency := 42.0 + sin(music_time * 0.07) * 3.0
			var drone := sin(TAU * drone_frequency * music_time) * 0.045
			var pad := sin(TAU * drone_frequency * 1.498 * music_time + sin(music_time * 0.13)) * 0.032
			var step := int(music_time * 2.0) % 4
			var arp_frequency: float = [110.0, 138.59, 164.81, 207.65][step]
			var arp_phase := fmod(music_time * 2.0, 1.0)
			var arpeggio := sin(TAU * arp_frequency * music_time) * 0.030 * pow(1.0 - arp_phase, 1.5)
			var shimmer := sin(TAU * 880.0 * music_time + sin(music_time * 0.6) * 2.0) * 0.009
			sample = drone + pad + arpeggio + shimmer
		music_time += 1.0 / 22050.0
		music_playback.push_frame(Vector2(sample, sample))
