extends Control

@onready var PlayPressed: Sprite2D = $PLAY/Sprite2D
const PlayP = preload("res://Assets/PlayButton-1-Pressed.png")
const PlayU = preload("res://Assets/PlayButton-1.png")

@onready var ExitPressed: Sprite2D = $EXIT/Sprite2D
const ExitP = preload("res://Assets/ExitButton-1-Pressed.png")
const ExitU = preload("res://Assets/ExitButton-1.png")

@onready var HowToPlayPressed: Sprite2D = $HowToPlayButton/Sprite2D
const HowToPlayP = preload("res://Assets/HowToPlay-ButtonPressed.png")
const HowToPlayU = preload("res://Assets/HowToPlay-Button.png")

func _on_play_pressed() -> void:
	PlayPressed.texture = PlayU
	
	var level: Node2D = load("res://Scenes/Level1.tscn").instantiate()

	var player: Player = load("res://Scenes/player.tscn").instantiate()
	
	get_node("/root/World").add_child(player)
	get_node("/root/World").add_level()
	States.curr_state = States.states.Level
	
	player.global_position = level.get_node("player_pos").global_position
	
	queue_free()
	#get_tree().change_scene_to_file("res://Scenes/Level1.tscn")

func _on_exit_button_up() -> void:
	ExitPressed.texture = ExitU

func _on_play_button_down() -> void:
	PlayPressed.texture = PlayP

func _on_exit_button_down() -> void:
	ExitPressed.texture = ExitP

func _on_how_to_play_button_pressed() -> void:
	HowToPlayPressed.texture = HowToPlayU
	var how_to_play = load("res://Scenes/HowToPlay.tscn").instantiate()
	get_node("/root/World/Screens").add_child(how_to_play)
	if States.curr_state == States.states.MainMenu:
		queue_free()
	else:
		visible = false

func _on_how_to_play_button_button_down() -> void:
	HowToPlayPressed.texture = HowToPlayP


func _on_play_button_up() -> void:
	PlayPressed.texture = PlayU


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_how_to_play_button_button_up() -> void:
	HowToPlayPressed.texture = HowToPlayU
