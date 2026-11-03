extends ColorRect

@export var camera: Camera2D
@export var parallax_factor: float = 0.5

const WRAP: float = 100000.0 # must be a multiple of both star grid sizes (100 and 20)

# Built up from camera movement each frame, scaled by zoom: zoomed out, the
# world moves fewer screen pixels, so the far background should too. Changing
# the zoom alone doesn't move it.
var _offset := Vector2.ZERO
var _last_cam_pos: Vector2
var _has_last := false

func _process(_delta: float) -> void:
	if camera:
		var pos := camera.global_position
		if _has_last:
			_offset += (pos - _last_cam_pos) * parallax_factor * camera.zoom.x
		_last_cam_pos = pos
		_has_last = true
		_offset = Vector2(fmod(_offset.x, WRAP), fmod(_offset.y, WRAP))
		material.set_shader_parameter("camera_offset", _offset)
