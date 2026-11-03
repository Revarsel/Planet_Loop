extends Node2D
class_name BackgroundPlanets
## Distant planets behind the play area. Lives in the background CanvasLayer
## (screen space), so zooming never shrinks them. Each layer scrolls by the
## camera's movement x its scroll factor x zoom, like the stars, so zoomed out
## they move slower. Each layer wraps over a tile much bigger than the screen,
## so you never see the same planet twice at once (no visible grid).
## Layouts come from a fixed seed, so the sky looks the same every run.

const TEXTURES: Array[Texture2D] = [
	preload("res://Assets/Earth-2.png"),
	preload("res://Assets/Earth-3.png"),
	preload("res://Assets/Mars2-Copy-2-Scaled.png"),
]
## Share of each texture's width the planet disc fills (Mars has wide margins).
const DISC_FRACTION: Array[float] = [1.0, 1.0, 0.64]

@export var layout_seed: int = 7
## Wrap area per layer, in screen pixels. Must be well over the screen size.
@export var tile_size: Vector2 = Vector2(3200, 2000)
## Planets wrap this far off screen, so they never pop in at the edge.
@export var margin: float = 140.0

## Far to near. scroll = share of the camera movement the layer follows.
## drift = slow sideways motion in screen pixels per second.
var layers: Array[Dictionary] = [
	{"scroll": 0.05, "count": 26, "size": Vector2(14, 34), "tint": Color(0.45, 0.48, 0.7, 0.45), "drift": Vector2(-3, 0)},
	{"scroll": 0.12, "count": 12, "size": Vector2(45, 95), "tint": Color(0.55, 0.58, 0.78, 0.6), "drift": Vector2.ZERO},
	{"scroll": 0.2, "count": 4, "size": Vector2(110, 160), "tint": Color(0.6, 0.62, 0.8, 0.65), "drift": Vector2.ZERO},
]

var _planets: Array[Dictionary] = [] # {sprite, base, layer}
var _offsets: Array[Vector2] = []
var _last_cam_pos: Vector2
var _has_cam := false


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = layout_seed
	for i in layers.size():
		_offsets.append(Vector2.ZERO)
		for n in layers[i].count:
			var sprite := _make_planet(rng, layers[i])
			add_child(sprite)
			_planets.append({"sprite": sprite, "base": Vector2(rng.randf() * tile_size.x, rng.randf() * tile_size.y), "layer": i})
	_place()


func _process(delta: float) -> void:
	var cam := get_viewport().get_camera_2d()
	var moved := Vector2.ZERO
	var zoom := 1.0
	if cam != null:
		zoom = cam.zoom.x
		if _has_cam:
			moved = cam.global_position - _last_cam_pos
		_last_cam_pos = cam.global_position
		_has_cam = true
	for i in layers.size():
		_offsets[i] += moved * layers[i].scroll * zoom - layers[i].drift * delta
	_place()


func _place() -> void:
	for p in _planets:
		var pos: Vector2 = p.base - _offsets[p.layer]
		p.sprite.position = Vector2(fposmod(pos.x, tile_size.x) - margin, fposmod(pos.y, tile_size.y) - margin)


func _make_planet(rng: RandomNumberGenerator, layer: Dictionary) -> Sprite2D:
	var kind := rng.randi_range(0, TEXTURES.size() - 1)
	var tex := TEXTURES[kind]
	var diameter := rng.randf_range(layer.size.x, layer.size.y)
	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR # clean when shrunk this far
	sprite.scale = Vector2.ONE * diameter / (tex.get_width() * DISC_FRACTION[kind])
	sprite.rotation = rng.randf() * TAU
	sprite.modulate = layer.tint
	return sprite
