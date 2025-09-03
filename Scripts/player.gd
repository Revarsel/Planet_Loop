extends RigidBody2D
class_name Player

var aiming: bool = true

@export var max_mouse_dist: int = 300
var line_max = 150
var entered: bool = false
var contacted: bool = false

var curr_velocity: Vector2 = Vector2.ZERO

@export var throw_strength: int = 2000

@onready var Explosion: AudioStreamPlayer = $Explosion
@onready var thruster: AudioStreamPlayer = $Thruster

@onready var thrust_Particle: GPUParticles2D = $Sprite2D/ThrustParticle
@onready var crash1: GPUParticles2D = $Sprite2D/Crash1
@onready var crash2: GPUParticles2D = $Sprite2D/Crash2

@onready var line: Line2D = $Line2D
@onready var line1: Line2D = $Line2D2
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	contact_monitor = true
	freeze = true
	body_entered.connect(_on_body_entered)
	max_contacts_reported = 10
	Signals.planet_destroyed.connect(_planet_destroyed)
	Signals.paused.connect(_paused)
	Signals.unpaused.connect(_unpaused)

func _process(delta: float) -> void:
	if entered:
		entered = false
		contact_monitor = false
		await get_tree().create_timer(4).timeout
		Signals.emit_player_reset()
		queue_free()
	else:
	
		sprite.rotation = linear_velocity.angle() + PI/2
		
		if !aiming:
			if contact_monitor == false:
				thrust_Particle.emitting = false
			else:
				thrust_Particle.emitting = true
			thruster.volume_db = lerpf(thruster.volume_db, -10, exp(-50 * delta))
			thruster.pitch_scale = clampf(linear_velocity.length()/950, 0.35, 1)

			if !thruster.playing and contact_monitor:
				thruster.play()
			return
		if States.curr_state == States.states.Pause:
			return
		thrust_Particle.emitting = false
		thruster.volume_db = lerpf(thruster.volume_db, -80, exp(-300 * delta))
		var mouse_click = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		var mouse_coord = get_global_mouse_position()
		
		sprite.rotation = (mouse_coord - sprite.global_position).angle() + PI/2
		
		var mouse_dist = mouse_coord - global_position
		var strength = min(mouse_dist.length() / max_mouse_dist, 1)
		
		var min_line_length = mouse_dist.normalized() * 15
		var max_line_length = min_line_length + mouse_dist.normalized() * line_max
		var line_length = min_line_length + strength * line_max * mouse_dist.normalized()
		line.set_point_position(0, min_line_length)
		line.set_point_position(1, line_length)
		line1.set_point_position(0, min_line_length)
		line1.set_point_position(1, max_line_length)
		if mouse_click:
			$Throw.play()
			freeze = false
			apply_force(mouse_dist.normalized() * strength * 10 * throw_strength)
			line.visible = false
			line1.visible = false
			aiming = false

func _planet_destroyed():
	aiming = true
	line.visible = true
	line1.visible = true
	freeze = true

func _on_body_entered(body: Node):
	thruster.stop()
	thrust_Particle.emitting = false
	crash1.emitting = true
	crash2.emitting = true
	if entered == true:
		return
	entered = true
	Signals.emit_player_destroyed()
	Explosion.play()

func _paused():
	curr_velocity = linear_velocity
	freeze = true

func _unpaused():
	freeze = false
	linear_velocity = curr_velocity
