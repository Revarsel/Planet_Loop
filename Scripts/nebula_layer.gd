extends TextureRect
class_name NebulaLayer
## Nebula clouds, rendered at a fraction of the screen resolution into a small
## SubViewport and stretched up (nearest-neighbour). The shader is the most
## expensive thing on screen, so this cuts its cost ~16x at the default 4,
## with almost no visible change since the clouds are chunky pixels anyway.
## Scrolls like the stars: camera movement x parallax_factor x zoom.

## Screen pixels per nebula pixel. Higher = cheaper and blockier.
@export_range(1, 8) var downscale: int = 4
@export var parallax_factor: float = 0.125

const WRAP := 100000.0

@onready var viewport: SubViewport = $SubViewport
@onready var canvas: ColorRect = $SubViewport/Clouds

var _offset := Vector2.ZERO
var _last_cam_pos: Vector2
var _has_cam := false


func _ready() -> void:
	texture = viewport.get_texture()
	resized.connect(_fit_viewport)
	_fit_viewport()


func _fit_viewport() -> void:
	var s := Vector2i((size / downscale).ceil())
	viewport.size = s.max(Vector2i.ONE)
	canvas.size = Vector2(viewport.size)
	canvas.material.set_shader_parameter("resolution_scale", float(downscale))


func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	if _has_cam:
		_offset += (cam.global_position - _last_cam_pos) * parallax_factor * cam.zoom.x
		_offset = Vector2(fmod(_offset.x, WRAP), fmod(_offset.y, WRAP))
	_last_cam_pos = cam.global_position
	_has_cam = true
	canvas.material.set_shader_parameter("camera_offset", _offset)
