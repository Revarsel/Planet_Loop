extends Node2D
class_name BackgroundPlanets
## Distant planets behind the play area. Each layer is a Parallax2D that scrolls
## slower than the camera, so the planets read as far away. Layouts come from a
## fixed seed, so the sky looks the same every run.

const TEXTURES: Array[Texture2D] = [
	preload("res://Assets/Earth-2.png"),
	preload("res://Assets/Earth-3.png"),
	preload("res://Assets/Mars2-Copy-2-Scaled.png"),
]
## Share of each texture's width the planet disc fills (Mars has wide margins).
const DISC_FRACTION: Array[float] = [1.0, 1.0, 0.64]

@export var layout_seed: int = 7
## Size of one repeating tile of sky, in pixels.
@export var tile_size: Vector2 = Vector2(2600, 1600)

## Far to near. scroll = how much of the camera movement the layer follows.
var layers: Array[Dictionary] = [
	{"scroll": 0.05, "count": 8, "size": Vector2(14, 34), "tint": Color(0.45, 0.48, 0.7, 0.45), "drift": Vector2(-2, 0)},
	{"scroll": 0.12, "count": 4, "size": Vector2(45, 95), "tint": Color(0.55, 0.58, 0.78, 0.6), "drift": Vector2.ZERO},
]


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = layout_seed
	for layer in layers:
		var parallax := Parallax2D.new()
		parallax.scroll_scale = Vector2.ONE * layer.scroll
		parallax.repeat_size = tile_size
		parallax.repeat_times = 3
		parallax.autoscroll = layer.drift
		add_child(parallax)
		for i in layer.count:
			parallax.add_child(_make_planet(rng, layer))


func _make_planet(rng: RandomNumberGenerator, layer: Dictionary) -> Sprite2D:
	var kind := rng.randi_range(0, TEXTURES.size() - 1)
	var tex := TEXTURES[kind]
	var diameter := rng.randf_range(layer.size.x, layer.size.y)
	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR # clean when shrunk this far
	sprite.scale = Vector2.ONE * diameter / (tex.get_width() * DISC_FRACTION[kind])
	sprite.position = Vector2(rng.randf() * tile_size.x, rng.randf() * tile_size.y)
	sprite.rotation = rng.randf() * TAU
	sprite.modulate = layer.tint
	return sprite
