extends ColorRect

@export var camera: Camera2D
@export var parallax_factor: float = 0.5

const WRAP: float = 100000.0 # must be a multiple of both star grid sizes (100 and 20)

func _process(_delta: float) -> void:
	if camera:
		var wrapped_x: float = fmod(camera.global_position.x * parallax_factor, WRAP)
		var wrapped_y: float = fmod(camera.global_position.y * parallax_factor, WRAP)
		material.set_shader_parameter("camera_offset", Vector2(wrapped_x, wrapped_y))
