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
	if warning_left > 0:
		warning_delay -= delta
		if warning_delay <= 0.0:
			play_sfx(&"warning")
			warning_left -= 1
			warning_delay = 0.32
	_fill_sfx()
	_fill_music(delta)

func set_sfx_enabled(enabled: bool) -> void:
	sfx_enabled = enabled
	if not enabled: sfx_time = 0.0
func set_music_enabled(enabled: bool) -> void: music_enabled = enabled
func play_sfx(effect: StringName) -> void:
	if not sfx_enabled: return
	var tones := {&"shoot": 760.0, &"hit": 180.0, &"shield": 520.0, &"freeze": 320.0, &"explosion": 110.0, &"warning": 920.0}
	sfx_frequency = tones.get(effect, 440.0)
	is_explosion = effect == &"explosion" or effect == &"hit"
	sfx_duration = 0.58 if is_explosion else 0.12
	sfx_time = sfx_duration
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
			if is_explosion:
				var boom_frequency := lerpf(sfx_frequency, 38.0, progress)
				var envelope := pow(1.0 - progress, 1.7)
				sample = (sin(sfx_phase) * 0.45 + sin(sfx_phase * 0.47) * 0.3 + randf_range(-0.22, 0.22)) * envelope
				sfx_phase += TAU * boom_frequency / 22050.0
			else:
				sample = sin(sfx_phase) * 0.22
				sfx_phase += TAU * sfx_frequency / 22050.0
		sfx_playback.push_frame(Vector2(sample, sample))
func _fill_music(delta: float) -> void:
	if music_playback == null: return
	for frame in music_playback.get_frames_available():
		var drone_frequency := 48.0 + sin(music_time * 0.10) * 4.0
		var pad := sin(music_phase) * 0.075
		pad += sin(music_phase * 1.498 + sin(music_time * 0.17)) * 0.045
		pad += sin(music_phase * 2.01 + 1.4) * 0.018
		var shimmer := sin(music_phase * 8.2 + sin(music_time * 0.6) * 2.0) * 0.010
		var air := randf_range(-0.004, 0.004) * (0.5 + sin(music_time * 0.08) * 0.5)
		var sample := (pad + shimmer + air) * (0.9 if music_enabled else 0.0)
		music_phase += TAU * drone_frequency / 22050.0
		music_time += 1.0 / 22050.0
		music_playback.push_frame(Vector2(sample, sample))
