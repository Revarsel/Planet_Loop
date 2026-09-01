extends Camera2D

var player: RigidBody2D

var mouse_pos: Vector2 = Vector2.ZERO
var curr_mouse_pos: Vector2 = Vector2.ZERO

@onready var background: ColorRect = $CanvasLayer/ColorRect

var f_pressed: bool = false

var lerp_speed: float = 75

var main_pos: Vector2 = Vector2(576, 324)

var update: bool = true
var paused: bool = false

func _ready() -> void:
	Signals.player_reset.connect(update_cam)

func _physics_process(delta: float) -> void:
	player = get_tree().get_first_node_in_group("player")
	if player == null or paused:
		return
		
	if player.aiming:
		if Input.is_action_just_pressed("scale_up"):
			zoom *= Vector2(1.1,1.1)
			#background.scale /= Vector2(1.1,1.1)
		elif Input.is_action_just_pressed("scale_down"):
			zoom /= Vector2(1.1,1.1)
			#background.scale *= Vector2(1.1,1.1)
			#background.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	else:
		zoom = zoom.lerp(Vector2(1,1), exp(-lerp_speed * delta))
		#background.scale = Vector2(1,1)
	
	if update:
		global_position = lerp(global_position, player.global_position, exp(-lerp_speed * delta))
		if (global_position - player.global_position).length() < 5:
			global_position = player.global_position
			update = false

	curr_mouse_pos = get_local_mouse_position()
	if !player.aiming: # Player is thrown
		global_position = lerp(global_position, player.global_position, exp(-60 * delta))
	elif Input.is_action_pressed("right_click"):
		global_position += (mouse_pos - curr_mouse_pos)
		update = false
	elif Input.is_key_pressed(KEY_F):
		f_pressed = true
	
	if f_pressed:
		global_position = lerp(global_position, player.global_position, exp(-lerp_speed * delta))
		if (global_position - player.global_position).length() < 5:
			global_position = player.global_position
			f_pressed = false
	
	mouse_pos = curr_mouse_pos

func update_cam():
	paused = false
	update = true

func reset_cam():
	paused = true
	global_position = main_pos

func pause_cam():
	paused = true
