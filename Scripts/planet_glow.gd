extends Sprite2D
class_name PlanetGlow
## Soft additive halo behind a planet that slowly breathes.
## planet.gd sets glow_color to match the planet type.

@export var glow_color: Color = Color(0.4, 0.8, 1.0, 0.35)
@export var pulse_amount: float = 0.2
@export var pulse_speed: float = 1.0

var _t: float = randf() * TAU # desync neighbouring planets


func _process(delta: float) -> void:
	_t += delta * pulse_speed
	var c := glow_color
	c.a *= 1.0 + pulse_amount * sin(_t)
	self_modulate = c
