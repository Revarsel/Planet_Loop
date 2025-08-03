extends RigidBody2D
class_name Player

var aiming: bool = true

@export var max_mouse_dist: int = 300
var line_max = 150

@export var throw_strength: int = 2000

@onready var line: Line2D = $Line2D
@onready var line1: Line2D = $Line2D2

func _ready() -> void:
	Signals.planet_destroyed.connect(_planet_destroyed)

func _process(delta: float) -> void:
	if !aiming:
		return
	var mouse_click = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var mouse_coord = get_global_mouse_position()
	
	var mouse_dist = mouse_coord - global_position
	var strength = min(mouse_dist.length() / max_mouse_dist, 1)
	
	var min_line_length = mouse_dist.normalized() * 15
	var max_line_length = min_line_length + mouse_dist.normalized() * line_max
	var line_length = min_line_length + strength * line_max * mouse_dist.normalized()
	line.set_point_position(0, min_line_length)
	line.set_point_position(1, line_length)
	line1.set_point_position(0, min_line_length)
	line1.set_point_position(1, max_line_length)
	if mouse_click:
		freeze = false
		apply_force(mouse_dist.normalized() * strength * 10 * throw_strength)
		line.visible = false
		line1.visible = false
		aiming = false

func _planet_destroyed():
	aiming = true
	line.visible = true
	line1.visible = true
	freeze = true
