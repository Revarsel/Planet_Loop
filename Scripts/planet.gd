extends StaticBody2D

@export var gravity: float = 10000
var player: RigidBody2D

@onready var area: Area2D = $Area2D

@onready var sprite: Sprite2D = $Sprite2D

@export var res: planet_sprite

var calculate: bool = false
var curr_angle: float = 0
var prev_angle: float = 0
var total_angle: float = 0

var player_dead: bool = false

@export var max_distance: int = 750

func _update():
	if res != null:
		print("Not null")
		sprite.texture = res.texture
		sprite.scale = Vector2(res.scale, res.scale)

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	Signals.player_destroyed.connect(_player_destroyed)
	_update()

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
			total_angle += abs(curr_angle - prev_angle) * int(!player_dead)
			prev_angle = curr_angle
			
			if total_angle > TAU:
				Signals.emit_planet_destroyed()
				queue_free()

func _on_body_entered(area1: Node2D):
	prev_angle = abs((player.global_position - global_position).angle())
	total_angle = 0
	calculate = true

func _on_body_exited(area1: Node2D):
	total_angle = 0
	calculate = false

func _player_destroyed():
	player_dead = true
	gravity /= 2
