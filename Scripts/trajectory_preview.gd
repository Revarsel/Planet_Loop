extends Node2D
class_name TrajectoryPreview
## Dotted path showing where the satellite will fly if launched right now.
## It replays the game's own physics step by step: the one-frame launch force,
## every planet's pull (planet.gd gravity_force_at) and the body's damping.

## How far ahead to predict, in game seconds. Longer = easier game.
@export var preview_seconds: float = 2.5
## Draw a dot every N physics steps.
@export var dot_every: int = 3
@export var dot_radius: float = 2.5
@export var color: Color = Color(0.373, 0.804, 0.894)

## Planet collision radius (planet.tscn) + player collision radius (player.tscn).
const CRASH_DISTANCE := 75.66 + 10.0

var points := PackedVector2Array()


func _ready() -> void:
	top_level = true # draw in world space, unaffected by the player's transform
	global_position = Vector2.ZERO


## Recompute the path for a launch of `launch_force` (the force player.gd applies
## for one physics step) from `body`'s current position.
func update_path(body: RigidBody2D, launch_force: Vector2) -> void:
	var dt := get_physics_process_delta_time() # already scaled by Engine.time_scale
	var planets: Array[Node] = []
	for p in get_tree().get_nodes_in_group("planet"):
		if not p.is_queued_for_deletion():
			planets.append(p)
	# Called every frame while aiming; skip the work if nothing changed.
	var key := [body.global_position, launch_force, planets.size(), dt]
	if key == _last_key:
		return
	_last_key = key

	var damp_factor: float = maxf(1.0 - dt * _total_linear_damp(body), 0.0)
	var centers := PackedVector2Array()
	for p in planets:
		centers.append(p.global_position)
	var crash_sq := CRASH_DISTANCE * CRASH_DISTANCE

	var pos := body.global_position
	var vel := Vector2.ZERO
	var force := launch_force
	points.clear()
	for i in ceili(preview_seconds / dt):
		for p in planets:
			force += p.gravity_force_at(pos)
		# Same order as Godot's 2D body integration: damp, add force, move.
		vel = vel * damp_factor + force / body.mass * dt
		pos += vel * dt
		points.append(pos)
		force = Vector2.ZERO
		var crashed := false
		for c in centers:
			if c.distance_squared_to(pos) < crash_sq:
				crashed = true
				break
		if crashed:
			break
	queue_redraw()


var _last_key: Array = []


func _total_linear_damp(body: RigidBody2D) -> float:
	if body.linear_damp_mode == RigidBody2D.DAMP_MODE_REPLACE:
		return body.linear_damp
	return body.linear_damp + float(ProjectSettings.get_setting("physics/2d/default_linear_damp", 0.1))


func _draw() -> void:
	var n := points.size()
	for i in range(dot_every - 1, n, dot_every):
		var c := color
		c.a = 1.0 - float(i) / n # fade out along the path
		draw_circle(points[i], dot_radius, c)
