extends Control

@onready var PlayPressed: Sprite2D = $PLAY/Sprite2D
const PlayP = preload("res://Assets/PlayButton-1-Pressed.png")
const PlayU = preload("res://Assets/PlayButton-1.png")

@onready var ExitPressed: Sprite2D = $EXIT/Sprite2D
const ExitP = preload("res://Assets/ExitButton-1-Pressed.png")
const ExitU = preload("res://Assets/ExitButton-1.png")

func _on_play_pressed() -> void:
	PlayPressed.texture = PlayU
	
	var level: Node2D = load("res://Scenes/Level1.tscn").instantiate()

	var player: Player = load("res://Scenes/player.tscn").instantiate()
	
	get_node("/root/World/Level").add_child(level)
	get_node("/root/World").add_child(player)
	get_node("/root/World").curr_state = States.states.Level
	
	player.global_position = level.get_node("player_pos").global_position
	
	queue_free()
	#get_tree().change_scene_to_file("res://Scenes/Level1.tscn")

func _on_exit_button_up() -> void:
	ExitPressed.texture = ExitU
	get_tree().quit()

func _on_play_button_down() -> void:
	PlayPressed.texture = PlayP

func _on_exit_button_down() -> void:
	ExitPressed.texture = ExitP
