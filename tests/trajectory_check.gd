extends SceneTree
## Checks that the launch preview (TrajectoryPreview) matches the real flight.
## For several launches it records the predicted path, fires the real player with
## the same force, and compares positions step by step.
##
## Usage:
##   godot --headless --fixed-fps 60 --path . --script res://tests/trajectory_check.gd
## Exit code 0 = every launch stayed within MAX_ERROR pixels of the preview.

const LEVEL := "res://Scenes/Level7.tscn"
const MAX_ERROR := 2.0
# [angle in degrees, strength 0..1]
const SHOTS := [[208.0, 1.0], [0.0, 0.5], [90.0, 0.25], [300.0, 0.75], [150.0, 0.9], [45.0, 0.1]]

var player_scene: PackedScene
var level_scene: PackedScene
var world: Node2D


func _initialize() -> void:
	Engine.time_scale = 2.0 # same as world.gd
	_main.call_deferred()


func _main() -> void:
	for n in ["Signals", "States"]:
		if root.get_node_or_null(n) == null:
			var node: Node = load("res://Scripts/%s.gd" % n).new()
			node.name = n
			root.add_child(node)
	root.get_node("States").curr_state = 1 # Level
	world = Node2D.new()
	world.name = "World"
	root.add_child(world)
	var particles := Node2D.new()
	particles.name = "Particles"
	world.add_child(particles)
	player_scene = load("res://Scenes/player.tscn")
	level_scene = load(LEVEL)

	var worst := 0.0
	for s in SHOTS:
		var err: float = await _check_shot(s[0], s[1])
		worst = maxf(worst, err)
	var refreeze := await _check_refreeze()
	var visibility := await _check_visibility()
	var ok := worst <= MAX_ERROR and refreeze < 0.001 and visibility.values().all(func(v): return v)
	print("RESULT ", JSON.stringify({"ok": ok, "worst_error_px": worst,
		"velocity_after_refreeze": refreeze, "visibility": visibility}))
	quit(0 if ok else 1)


## Path visible and aim line hidden while aiming; a real left click launches
## and hides the path.
func _check_visibility() -> Dictionary:
	var spawned: Array = await _spawn()
	var player: RigidBody2D = spawned[1]
	await process_frame
	var out := {
		"path_shown_while_aiming": player.preview.visible and player.preview.points.size() > 0,
		"aim_line_hidden": not player.line.visible and not player.line1.visible,
	}
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = Vector2(900, 324)
	Input.parse_input_event(press)
	await process_frame
	await process_frame
	out["click_launches"] = not player.aiming
	out["path_hidden_after_launch"] = not player.preview.visible
	var release := press.duplicate()
	release.pressed = false
	Input.parse_input_event(release)
	spawned[0].queue_free()
	player.queue_free()
	await process_frame
	return out


func _spawn() -> Array:
	var lvl := level_scene.instantiate()
	world.add_child(lvl)
	var player: RigidBody2D = player_scene.instantiate()
	world.add_child(player)
	player.global_position = lvl.get_node("player_pos").global_position
	await physics_frame
	await process_frame
	return [lvl, player]


func _check_shot(angle_deg: float, strength: float) -> float:
	var spawned: Array = await _spawn()
	var lvl: Node = spawned[0]
	var player: RigidBody2D = spawned[1]
	var force: Vector2 = Vector2.from_angle(deg_to_rad(angle_deg)) * strength * 10 * player.throw_strength

	player.preview.update_path(player, force)
	var predicted: PackedVector2Array = player.preview.points.duplicate()

	# Same launch as player.gd on left click.
	player.freeze = false
	player.apply_force(force)
	player.aiming = false

	# physics_frame fires before each step, so read k is the position after k-1 steps.
	var actual := PackedVector2Array()
	for k in predicted.size() + 1:
		await physics_frame
		if not is_instance_valid(player):
			break
		actual.append(player.global_position)

	if actual.size() < predicted.size() + 1:
		push_error("player vanished after %d steps" % actual.size())
		return INF
	var err := 0.0
	for i in predicted.size():
		if i + 1 < actual.size():
			err = maxf(err, predicted[i].distance_to(actual[i + 1]))
	print("shot %5.1fdeg x %.2f: %d predicted steps, max error %.3f px" % [angle_deg, strength, predicted.size(), err])
	lvl.queue_free()
	if is_instance_valid(player):
		player.queue_free()
	await process_frame
	return err


## After a planet is destroyed player.gd sets freeze = true and the next launch
## starts from rest. Confirm the body really has no leftover velocity then.
func _check_refreeze() -> float:
	var spawned: Array = await _spawn()
	var player: RigidBody2D = spawned[1]
	player.freeze = false
	player.apply_force(Vector2(20000, 0))
	player.aiming = false
	for k in 10:
		await physics_frame
	player.freeze = true
	player.aiming = true
	await physics_frame
	await physics_frame
	player.freeze = false
	await physics_frame
	await physics_frame
	var v := player.linear_velocity.length()
	spawned[0].queue_free()
	player.queue_free()
	await process_frame
	return v
