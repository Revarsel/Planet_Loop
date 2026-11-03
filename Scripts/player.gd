extends RigidBody2D
class_name Player

var aiming: bool = true

@export var max_mouse_dist: int = 300
var line_max = 150
var entered: bool = false
var contacted: bool = false
var paused: bool = false

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

@onready var preview: TrajectoryPreview = $TrajectoryPreview

## The old aim line, replaced by the trajectory preview. Turn on to bring it back.
@export var show_aim_line: bool = false

const VORTEX: PackedScene = preload("res://Scenes/exit_vortex.tscn")
## After the last planet: spiral into its centre over this many game seconds
## (world.gd runs at time_scale 2, so real time is half).
@export var exit_time: float = 3.0
## Minimum turns around the centre during the spiral.
@export var exit_turns: float = 2.0

var exiting: bool = false
var _exit_center: Vector2
var _exit_r0: float
var _exit_a0: float
var _exit_spin: float = 1.0
var _exit_angle_total: float
var _exit_start_turn: float # the turning already happening at the start
var _exit_t: float = 0.0
var _sprite_scale: Vector2
var _vortex: Node

func _ready() -> void:
	contact_monitor = true
	freeze = true
	body_entered.connect(_on_body_entered)
	max_contacts_reported = 10
	Signals.planet_destroyed.connect(_planet_destroyed)
	Signals.paused.connect(_paused)
	Signals.unpaused.connect(_unpaused)
	Signals.last_planet_destroyed.connect(_start_exit)
	line.visible = show_aim_line
	line1.visible = show_aim_line
	_sprite_scale = sprite.scale

func _process(delta: float) -> void:
	if paused or exiting:
		return
	if entered:
		entered = false
		contact_monitor = false
		thrust_Particle.emitting = false
		await get_tree().create_timer(4).timeout
		Signals.emit_player_reset()
		queue_free()
	else:
	
		sprite.rotation = linear_velocity.angle() + PI/2
		
		if !aiming:
			#if contact_monitor:
				#thrust_Particle.emitting = true
			thruster.volume_db = lerpf(thruster.volume_db, -10, exp(-50 * delta))
			thruster.pitch_scale = clampf(linear_velocity.length()/950, 0.35, 1)

			if !thruster.playing and contact_monitor:
				thruster.play()
			return
		if States.curr_state == States.states.Pause:
			sprite.rotation = linear_velocity.angle() + PI/2
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
		var launch_force: Vector2 = mouse_dist.normalized() * strength * 10 * throw_strength
		preview.visible = true
		preview.update_path(self, launch_force)
		if mouse_click:
			$Throw.play()
			freeze = false
			apply_force(launch_force)
			preview.visible = false
			line.visible = false
			line1.visible = false
			aiming = false
			thrust_Particle.emitting = true

## Last planet gone: keep moving and spiral into where it was.
func _start_exit(center: Vector2) -> void:
	if entered or aiming:
		return
	exiting = true
	_exit_center = center
	var rel := global_position - center
	_exit_r0 = maxf(rel.length(), 1.0)
	_exit_a0 = rel.angle()
	# Keep turning the way we were already orbiting, at the same speed.
	_exit_spin = 1.0 if rel.cross(linear_velocity) >= 0.0 else -1.0
	var sideways_speed := absf(rel.normalized().cross(linear_velocity))
	_exit_start_turn = sideways_speed / _exit_r0 * exit_time
	_exit_angle_total = maxf(TAU * exit_turns, _exit_start_turn * 1.2)
	_exit_t = 0.0
	# Move it by hand from now on; kinematic freeze lets us set the position.
	contact_monitor = false
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true
	_vortex = VORTEX.instantiate()
	_vortex.global_position = center
	_vortex.spin = _exit_spin
	get_node("/root/World/Particles").add_child(_vortex)

func _physics_process(delta: float) -> void:
	if not exiting or paused or _exit_t >= 1.0:
		return
	_exit_t = minf(_exit_t + delta / exit_time, 1.0)
	var k := _exit_t
	# Radius closes in slowly then fast; angle starts at the current turning
	# speed and speeds up as it tightens.
	var r := _exit_r0 * (1.0 - k * k)
	var a := _exit_a0 + _exit_spin * (_exit_start_turn * k + (_exit_angle_total - _exit_start_turn) * k * k)
	var new_pos := _exit_center + Vector2.from_angle(a) * r
	var step := new_pos - global_position
	global_position = new_pos
	if step.length() > 0.01:
		sprite.rotation = step.angle() + PI / 2
	sprite.scale = _sprite_scale * clampf((1.0 - k) / 0.3, 0.0, 1.0) # shrink in the last 30%
	if _exit_t >= 1.0:
		_finish_exit()

func _finish_exit() -> void:
	sprite.visible = false
	thrust_Particle.emitting = false
	fade_volume(1)
	if is_instance_valid(_vortex):
		_vortex.collapse()
	Signals.emit_satellite_exited()

func _planet_destroyed():
	if exiting:
		return
	aiming = true
	line.visible = show_aim_line
	line1.visible = show_aim_line
	freeze = true

func _on_body_entered(body: Node):
	fade_volume(2)
	thrust_Particle.emitting = false
	if entered == true:
		return
	crash1.emitting = true
	crash2.emitting = true
	entered = true
	Signals.emit_player_destroyed()
	Explosion.play()

func _paused():
	paused = true
	if exiting:
		return # the spiral just holds still; physics isn't involved
	curr_velocity = linear_velocity
	freeze = true

func _unpaused():
	paused = false
	if exiting:
		return
	freeze = false
	paused = false
	linear_velocity = curr_velocity

func fade_volume(duration: float) -> void:
	var target_db = -50
	
	var tween = create_tween()
	
	tween.tween_property(thruster, "volume_db", target_db, 3)
	await tween.finished
	#contact_monitor = true
	thruster.stop()
