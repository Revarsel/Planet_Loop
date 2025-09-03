extends Control

#@onready var PlayPressed: Sprite2D = $PLAY/Sprite2D
#const PlayP = preload("res://Assets/PlayButton-1-Pressed.png")
#const PlayU = preload("res://Assets/PlayButton-1.png")

@onready var ExitPressed: Sprite2D = $EXIT/Sprite2D
const ExitP = preload("res://Assets/ExitButton-1-Pressed.png")
const ExitU = preload("res://Assets/ExitButton-1.png")

@onready var HowToPlayPressed: Sprite2D = $HowToPlayButton/Sprite2D
const HowToPlayP = preload("res://Assets/HowToPlay-ButtonPressed.png")
const HowToPlayU = preload("res://Assets/HowToPlay-Button.png")

func _on_exit_button_up() -> void:
	ExitPressed.texture = ExitU
	get_tree().quit()

func _on_exit_button_down() -> void:
	ExitPressed.texture = ExitP

func _on_how_to_play_button_pressed() -> void:
	HowToPlayPressed.texture = HowToPlayU
	var how_to_play = load("res://Scenes/HowToPlay.tscn").instantiate()
	get_node("/root/World").add_child(how_to_play)
	if States.curr_state == States.states.MainMenu:
		queue_free()
	else:
		visible = false

func _on_how_to_play_button_button_down() -> void:
	HowToPlayPressed.texture = HowToPlayP
