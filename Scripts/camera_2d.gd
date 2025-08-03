extends Camera2D

var player: RigidBody2D

var mouse_pos: Vector2 = Vector2.ZERO
var curr_mouse_pos: Vector2 = Vector2.ZERO

var f_pressed: bool = false

func _physics_process(delta: float) -> void:
	player = get_tree().get_first_node_in_group("player")
	if player != null:
		curr_mouse_pos = get_local_mouse_position()
		if !player.aiming:
			global_position = lerp(global_position, player.global_position, exp(-50 * delta))
		elif Input.is_action_pressed("right_click"):
			global_position += (mouse_pos - curr_mouse_pos)
		elif Input.is_key_pressed(KEY_F):
			f_pressed = true
		
		if f_pressed:
			global_position = lerp(global_position, player.global_position, 10 * delta)
			if (global_position - player.global_position).length() < 5:
				global_position = player.global_position
				f_pressed = false
		
		mouse_pos = curr_mouse_pos
