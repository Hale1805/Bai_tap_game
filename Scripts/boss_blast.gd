extends Control

var elapsed := 0.0
var active := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false

func play() -> void:
	elapsed = 0.0
	active = true
	visible = true
	queue_redraw()

func _process(delta: float) -> void:
	if not active:
		return
	elapsed += delta
	queue_redraw()
	if elapsed > 1.5:
		active = false
		visible = false

func _draw() -> void:
	var center := size * 0.5
	var progress := clampf(elapsed / 1.5, 0.0, 1.0)
	var fade := 1.0 - progress
	draw_rect(Rect2(Vector2.ZERO, size), Color(1.0, 0.85, 0.55, fade * 0.55))
	draw_circle(center, 80.0 + progress * 850.0, Color(1.0, 0.2, 0.04, fade * 0.16), false, 14.0)
	draw_circle(center, 35.0 + progress * 430.0, Color(1.0, 0.75, 0.15, fade * 0.32), false, 8.0)
	for ray in 32:
		var angle := TAU * float(ray) / 32.0
		var start := center + Vector2(cos(angle), sin(angle)) * (60.0 + progress * 80.0)
		var end := center + Vector2(cos(angle), sin(angle)) * (170.0 + progress * 620.0)
		draw_line(start, end, Color(1.0, 0.5 + 0.4 * sin(float(ray)), 0.08, fade * 0.72), 3.0)
