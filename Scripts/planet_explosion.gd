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

var _texture: Texture2D
var _sprite_scale := Vector2.ONE
var _accent := Color(0.4, 0.8, 1.0)
var _debris_colors := PackedColorArray()


## `debris_colors` comes from the planet's .tres (planet_sprite.debris_colors).
func setup(texture: Texture2D, sprite_scale: Vector2, accent: Color, debris_colors: PackedColorArray) -> void:
	_texture = texture
	_sprite_scale = sprite_scale
	_accent = accent
	_debris_colors = debris_colors


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
	ramp.gradient = _palette(_debris_colors, _accent)
	frag_mat.color_initial_ramp = ramp
	fragments.process_material = frag_mat
	fragments.emitting = true

	var spark_mat := (sparks.process_material as ParticleProcessMaterial).duplicate()
	spark_mat.color = _accent.lightened(0.35)
	sparks.process_material = spark_mat
	sparks.emitting = true

	get_tree().create_timer(lifetime).timeout.connect(queue_free)


## Step gradient so each chunk gets exactly one of the colours.
static func _palette(colors: PackedColorArray, fallback: Color) -> Gradient:
	if colors.is_empty():
		colors = PackedColorArray([fallback, fallback.darkened(0.3), fallback.lightened(0.3)])
	var g := Gradient.new()
	g.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	var offsets := PackedFloat32Array()
	for i in colors.size():
		offsets.append(float(i) / colors.size())
	g.offsets = offsets
	g.colors = colors
	return g
