extends StaticBody2D

@export var gravity: float
var player: RigidBody2D

@onready var area: Area2D = $Area2D

var calculate: bool = false
var curr_angle: float = 0
var prev_angle: float = 0
var total_angle: float = 0

@export var max_distance: int = 500

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	Engine.time_scale = 2
	player = get_tree().get_first_node_in_group("player")
	if player != null:
		if player.aiming:
			return
		var distance: = global_position - player.global_position
		var length: float = max(distance.length(), 250)
		var force: = gravity * 2000 / (length * length)
		player.apply_force(distance.normalized() * force * int(length < max_distance))
		if calculate:
			curr_angle = abs((player.global_position - global_position).angle())
			total_angle += abs(curr_angle - prev_angle)
			prev_angle = curr_angle
			
			if total_angle > TAU:
				Signals.emit_planet_destroyed()
				queue_free()

func _on_body_entered(area: Node2D):
	curr_angle = abs((player.global_position - global_position).angle())
	prev_angle = curr_angle
	total_angle = 0
	calculate = true

func _on_body_exited(area: Node2D):
	total_angle = 0
	calculate = false
