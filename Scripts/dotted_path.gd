@tool
extends Node2D
class_name DottedPath
## Static dotted, gently curved path that fades out, styled like the in-game
## launch preview (TrajectoryPreview). Used for the How To Play illustrations.

## Where the path ends, relative to this node.
@export var end_point: Vector2 = Vector2(100, -60):
	set(v):
		end_point = v
		queue_redraw()
## Sideways bend of the curve, in pixels.
@export var bend: float = 12.0:
	set(v):
		bend = v
		queue_redraw()
@export var dots: int = 10:
	set(v):
		dots = maxi(v, 2)
		queue_redraw()
@export var dot_radius: float = 2.5
@export var color: Color = Color(0.373, 0.804, 0.894)


func _draw() -> void:
	var mid := end_point / 2.0 + end_point.orthogonal().normalized() * bend
	for i in dots:
		var t := float(i + 1) / dots
		# Quadratic curve from the start, through the bend, to the end.
		var p := (1.0 - t) * (1.0 - t) * Vector2.ZERO + 2.0 * (1.0 - t) * t * mid + t * t * end_point
		var c := color
		c.a = 1.0 - t * 0.85
		draw_circle(p, dot_radius, c)
