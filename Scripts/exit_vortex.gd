extends Node2D
class_name ExitVortex
## Swirl at the last planet's centre while the satellite spirals in.
## player.gd spawns it, sets `spin` to match the satellite's direction, and
## calls collapse() when the satellite vanishes: the swirl stops and a flash
## and spark burst finish it off. Frees itself afterwards.

## 1 = counter-clockwise, -1 = clockwise (matches the satellite's spiral).
var spin: float = 1.0

@onready var glow: Sprite2D = $Glow
@onready var swirl: GPUParticles2D = $Swirl
@onready var burst: GPUParticles2D = $Burst


func _ready() -> void:
	var mat := (swirl.process_material as ParticleProcessMaterial).duplicate()
	mat.orbit_velocity_min = absf(mat.orbit_velocity_min) * spin
	mat.orbit_velocity_max = absf(mat.orbit_velocity_max) * spin
	swirl.process_material = mat
	swirl.emitting = true

	glow.modulate.a = 0.0
	glow.scale = Vector2.ONE * 0.5
	var t := create_tween().set_parallel(true)
	t.tween_property(glow, "modulate:a", 0.7, 1.0)
	t.tween_property(glow, "scale", Vector2.ONE * 1.1, 2.4)


func collapse() -> void:
	swirl.emitting = false
	burst.emitting = true
	glow.modulate.a = 1.0 # flare to full brightness, then expand and fade
	var t := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(glow, "scale", Vector2.ONE * 3.5, 0.6)
	t.tween_property(glow, "modulate:a", 0.0, 0.6)
	get_tree().create_timer(2.5).timeout.connect(queue_free)
