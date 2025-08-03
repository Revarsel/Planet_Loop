extends Camera2D

var player: RigidBody2D

func _process(delta: float) -> void:
	player = get_tree().get_first_node_in_group("player")
	if player != null:
		global_position = player.global_position
