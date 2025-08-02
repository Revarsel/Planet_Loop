extends RigidBody2D
class_name Player

var aiming: bool = true

@export var max_mouse_dist: int = 300
var line_max = 100

@export var throw_strength: int = 2000

@onready var line: Line2D = $Line2D

func _process(delta: float) -> void:
	if !aiming:
		return
	var mouse_click = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var mouse_coord = get_global_mouse_position()
	
	var mouse_dist = mouse_coord - global_position
	var strength = min(mouse_dist.length() / max_mouse_dist, 1)
	
	var min_line_length = mouse_dist.normalized() * 15
	var line_length = min_line_length + max(strength - 0.15, 0) * line_max * mouse_dist.normalized()
	line.set_point_position(0, min_line_length)
	line.set_point_position(1, line_length)
	if mouse_click:
		#print(strength)
		apply_force(mouse_dist.normalized() * strength * 10 * throw_strength)
		line.set_point_position(1, Vector2(0,0))
		line.set_point_position(0, Vector2(0,0))
		aiming = false
