extends Line2D
class_name JetTrail
## Solid glowing jet behind the thruster. Particles alone break into separate
## dots when the satellite is fast (they spawn once per frame), so this line
## follows the emitter's recent path to keep the jet continuous.
## Lives inside thruster_flame.tscn and follows the flame's `emitting` flag.

## Jet length, in physics steps of history.
@export var max_points: int = 7
## Points removed per physics step once the flame stops.
@export var shrink_per_step: int = 2

var emitter: GPUParticles2D


func _ready() -> void:
	top_level = true # points are in world space
	global_transform = Transform2D.IDENTITY
	emitter = get_parent() as GPUParticles2D
	clear_points()


func _physics_process(_delta: float) -> void:
	if emitter == null:
		return
	if not emitter.emitting:
		for i in mini(shrink_per_step, get_point_count()):
			remove_point(0)
		return
	var pos := emitter.global_position
	var count := get_point_count()
	# Skip duplicate points (satellite paused), so the jet holds its shape.
	if count == 0 or get_point_position(count - 1).distance_to(pos) > 0.5:
		add_point(pos)
	while get_point_count() > max_points:
		remove_point(0)
