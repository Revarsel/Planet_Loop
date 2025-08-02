extends StaticBody2D

@export var gravity: float
var player: RigidBody2D

func _process(delta: float) -> void:
	player = get_tree().get_first_node_in_group("player")
	if player != null:
		if player.aiming:
			return
		var distance = global_position - player.global_position
		var length = max(distance.length(), 0.1)
		var force = gravity * 10 / length
		player.apply_force(distance.normalized() * force)
