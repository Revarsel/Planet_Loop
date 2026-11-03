extends Node2D
class_name Shockwave
## Expanding ring that fades out, spawned when a planet is destroyed.
## Frees itself when done.

@export var color: Color = Color(0.6, 0.9, 1.0)
@export var start_radius: float = 80.0
@export var end_radius: float = 420.0
@export var start_width: float = 10.0
## Game seconds; world.gd runs at time_scale 2, so this is half in real time.
@export var duration: float = 1.2

var _t: float = 0.0


func _process(delta: float) -> void:
	_t += delta
	if _t >= duration:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var k := clampf(_t / duration, 0.0, 1.0)
	var ease_out := 1.0 - pow(1.0 - k, 3.0)
	var c := color
	c.a = 1.0 - k
	draw_arc(Vector2.ZERO, lerpf(start_radius, end_radius, ease_out), 0.0, TAU, 96, c,
		lerpf(start_width, 1.0, k), true)
