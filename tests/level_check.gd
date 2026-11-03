extends SceneTree
## Headless level checker. Fires a grid of launches (angle x strength) through the
## real player/planet scenes and physics, then chains successful shots to prove the
## whole level can be cleared. Prints one JSON line per level step.
##
## Usage:
##   godot --headless --fixed-fps 60 --path . --script res://tests/level_check.gd -- res://Scenes/Level7.tscn
##
## Difficulty signals per step: "target_hits" = how many of the 630 launches from
## that spot destroy the chosen planet (lower = more precise aim needed), and
## "hit_rate" = share of launches that destroy any planet.

const ANGLE_STEP := 4.0
const STRENGTHS := [0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0]
const MAX_FRAMES := 1200 # 40 game seconds at time_scale 2
const LOST_DISTANCE := 2500.0
const MIN_TARGET_HITS := 15

var player_scene: PackedScene # loaded after autoloads exist, or player.gd fails to compile
var level_scene: PackedScene
var world: Node2D
var level_holder: Node2D
var particles: Node2D

var kill_flag := false
var crash_flag := false


func _initialize() -> void:
	Engine.time_scale = 2.0 # same as world.gd
	_main.call_deferred()


func _main() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		push_error("level_check: pass a level scene path after --")
		quit(1)
		return
	level_scene = load(args[0])
	if level_scene == null:
		push_error("level_check: cannot load %s" % args[0])
		quit(1)
		return

	_setup_world()
	player_scene = load("res://Scenes/player.tscn")
	var probe := level_scene.instantiate()
	var start: Vector2 = probe.get_node("player_pos").position
	var total := 0
	for c in probe.get_children():
		if c.is_in_group("planet"):
			total += 1
	probe.free()

	var path: Array = await _solve(start, [], total)
	var ok := path.size() == total
	print("RESULT ", JSON.stringify({"level": args[0], "solvable": ok, "planets": total, "steps": path}))
	quit(0 if ok else 2)


func _setup_world() -> void:
	# Planets look up these autoloads and /root/World/Particles.
	for n in ["Signals", "States"]:
		if root.get_node_or_null(n) == null:
			var node: Node = load("res://Scripts/%s.gd" % n).new()
			node.name = n
			root.add_child(node)
	var sig := root.get_node("Signals")
	sig.planet_destroyed.connect(func(): kill_flag = true)
	sig.player_destroyed.connect(func(): crash_flag = true)
	root.get_node("States").curr_state = 1 # Level

	world = Node2D.new()
	world.name = "World"
	root.add_child(world)
	level_holder = Node2D.new()
	world.add_child(level_holder)
	particles = Node2D.new()
	particles.name = "Particles"
	world.add_child(particles)


## Depth-first: sweep all launches from `start`, then recurse on the most
## forgiving kills first. Returns the list of steps that cleared planets.
func _solve(start: Vector2, removed: Array, total: int) -> Array:
	if removed.size() == total:
		return []
	var sweep := await _sweep(start, removed)
	var kills: Dictionary = sweep.kills # planet name -> Array of shots
	# Play like a person: go for the nearest planet that is reasonably hittable
	# (MIN_TARGET_HITS launches), else fall back to the most hittable one.
	var lvl := level_scene.instantiate()
	var dist := {}
	for n in kills.keys():
		dist[n] = lvl.get_node(NodePath(n)).position.distance_to(start)
	lvl.free()
	var names := kills.keys()
	names.sort_custom(func(a, b):
		var ea: bool = kills[a].size() >= MIN_TARGET_HITS
		var eb: bool = kills[b].size() >= MIN_TARGET_HITS
		if ea != eb:
			return ea
		if ea:
			return dist[a] < dist[b]
		return kills[a].size() > kills[b].size())
	for planet_name in names:
		var shots: Array = kills[planet_name]
		# Try the middle of the successful group: the most central, robust shot.
		shots.sort_custom(func(a, b): return a.angle < b.angle)
		for idx in [shots.size() / 2, 0, shots.size() - 1]:
			var s: Dictionary = shots[idx]
			var step := {
				"from": [roundi(start.x), roundi(start.y)],
				"hit_rate": snappedf(float(sweep.hits) / sweep.count, 0.001),
				"crash_rate": snappedf(float(sweep.crashes) / sweep.count, 0.001),
				"target": planet_name,
				"target_hits": shots.size(),
				"options": names.map(func(n): return "%s:%d" % [n, kills[n].size()]),
				"angle": s.angle,
				"strength": s.strength,
			}
			var rest: Array = await _solve(s.pos, removed + [planet_name], total)
			if rest.size() == total - removed.size() - 1:
				return [step] + rest
	return []


func _sweep(start: Vector2, removed: Array) -> Dictionary:
	var out := {"kills": {}, "hits": 0, "crashes": 0, "count": 0}
	var a := 0.0
	while a < 360.0:
		for st in STRENGTHS:
			var r := await _shot(start, removed, a, st)
			out.count += 1
			if r.outcome == "kill":
				out.hits += 1
				if not out.kills.has(r.planet):
					out.kills[r.planet] = []
				out.kills[r.planet].append({"angle": a, "strength": st, "pos": r.pos})
			elif r.outcome == "crash":
				out.crashes += 1
		a += ANGLE_STEP
	return out


func _shot(start: Vector2, removed: Array, angle_deg: float, strength: float) -> Dictionary:
	var lvl := level_scene.instantiate()
	for n in removed:
		var p := lvl.get_node(NodePath(n))
		lvl.remove_child(p)
		p.free()
	level_holder.add_child(lvl)
	var alive: Array[String] = []
	for c in lvl.get_children():
		if c.is_in_group("planet"):
			alive.append(String(c.name))
	var player: RigidBody2D = player_scene.instantiate()
	world.add_child(player)
	player.global_position = start
	await physics_frame
	await process_frame

	# Same launch as player.gd on left click.
	kill_flag = false
	crash_flag = false
	player.freeze = false
	player.apply_force(Vector2.from_angle(deg_to_rad(angle_deg)) * strength * 10 * player.throw_strength)
	player.aiming = false

	var result := {"outcome": "lost"}
	for f in MAX_FRAMES:
		await physics_frame
		if crash_flag:
			result.outcome = "crash"
			break
		if kill_flag:
			result.outcome = "kill"
			result.pos = player.global_position
			# The destroyed planet may already be freed, so find the missing name.
			for n in alive:
				var c := lvl.get_node_or_null(NodePath(n))
				if c == null or c.is_queued_for_deletion():
					result.planet = n
			break
		var near := false
		for c in lvl.get_children():
			if c.is_in_group("planet") and is_instance_valid(c) and not c.is_queued_for_deletion() \
					and c.global_position.distance_to(player.global_position) < LOST_DISTANCE:
				near = true
		if not near:
			break

	lvl.queue_free()
	player.queue_free()
	for c in particles.get_children():
		c.queue_free()
	await process_frame
	return result
