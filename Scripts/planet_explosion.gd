extends Node2D
class_name PlanetExplosion
## Planet destroyed effect. The planet node is freed instantly, so planet.gd
## spawns this in its place: the planet image flashes white-hot and swells
## away, a coloured core flash expands, chunks in the planet's own colours
## tumble outward, and sparks burn out. Frees itself when done.
## Call setup() before adding it to the tree.

## Total life of the effect, in game seconds (world.gd runs at time_scale 2).
@export var lifetime: float = 3.0
@export var burst_time: float = 0.35
@export var body_swell: float = 1.35
@export var flash_end_scale: float = 4.0

@onready var body: Sprite2D = $Body
@onready var flash: Sprite2D = $Flash
@onready var fragments: GPUParticles2D = $Fragments
@onready var sparks: GPUParticles2D = $Sparks

## Sampled colours per planet texture, so each texture is only read once.
static var _palette_cache: Dictionary = {}

var _texture: Texture2D
var _sprite_scale := Vector2.ONE
var _accent := Color(0.4, 0.8, 1.0)


func setup(texture: Texture2D, sprite_scale: Vector2, accent: Color) -> void:
	_texture = texture
	_sprite_scale = sprite_scale
	_accent = accent


func _ready() -> void:
	# The planet image: white-hot, then swells and fades.
	body.texture = _texture
	body.scale = _sprite_scale
	body.modulate = Color(2.5, 2.5, 2.5, 1.0) # >1 pushes the colours toward white
	var t := create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(body, "scale", _sprite_scale * body_swell, burst_time)
	t.tween_property(body, "modulate:a", 0.0, burst_time)

	# Core flash in the planet's accent colour.
	flash.modulate = Color(_accent.r, _accent.g, _accent.b, 1.0)
	var f := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	f.tween_property(flash, "scale", Vector2.ONE * flash_end_scale, burst_time * 2.0)
	f.tween_property(flash, "modulate:a", 0.0, burst_time * 2.0)

	# Chunks in the planet's own colours. Copy the material so the colours
	# never leak into another explosion.
	var frag_mat := (fragments.process_material as ParticleProcessMaterial).duplicate()
	var ramp := GradientTexture1D.new()
	ramp.gradient = palette_for(_texture, _accent)
	frag_mat.color_initial_ramp = ramp
	fragments.process_material = frag_mat
	fragments.emitting = true

	var spark_mat := (sparks.process_material as ParticleProcessMaterial).duplicate()
	spark_mat.color = _accent.lightened(0.35)
	sparks.process_material = spark_mat
	sparks.emitting = true

	get_tree().create_timer(lifetime).timeout.connect(queue_free)


## A few colours picked from random solid pixels of the planet texture, as a
## step gradient. Falls back to the accent colour if the image can't be read.
static func palette_for(texture: Texture2D, fallback: Color) -> Gradient:
	if texture != null and _palette_cache.has(texture):
		return _palette_cache[texture]
	var colors := PackedColorArray()
	if texture != null:
		var img := texture.get_image()
		if img != null:
			if img.is_compressed():
				img.decompress()
			var rng := RandomNumberGenerator.new()
			rng.seed = 1 # same palette every run
			var tries := 0
			while colors.size() < 8 and tries < 400:
				tries += 1
				var c := img.get_pixel(rng.randi_range(0, img.get_width() - 1), rng.randi_range(0, img.get_height() - 1))
				if c.a > 0.9 and c.get_luminance() > 0.08: # skip outline black
					colors.append(c)
	if colors.is_empty():
		colors = PackedColorArray([fallback, fallback.darkened(0.3), fallback.lightened(0.3)])
	var g := Gradient.new()
	g.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	var offsets := PackedFloat32Array()
	for i in colors.size():
		offsets.append(float(i) / colors.size())
	g.offsets = offsets
	g.colors = colors
	if texture != null:
		_palette_cache[texture] = g
	return g
