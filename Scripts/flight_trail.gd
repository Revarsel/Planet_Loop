extends Line2D
class_name FlightTrail
## Fading trail behind the satellite while it flies. Shrinks away when the
## satellite stops (planet destroyed or crash) and freezes while paused.

@export var max_points: int = 45
## Oldest points removed per physics step once the satellite stops.
@export var shrink_per_step: int = 2

var body: Player


func _ready() -> void:
	top_level = true # points are in world space
	global_position = Vector2.ZERO
	body = get_parent() as Player
	clear_points()


func _physics_process(_delta: float) -> void:
	if body == null or body.paused:
		return
	if body.aiming or body.freeze:
		for i in mini(shrink_per_step, get_point_count()):
			remove_point(0)
		return
	add_point(body.global_position)
	while get_point_count() > max_points:
		remove_point(0)
