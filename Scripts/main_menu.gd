extends Control
@onready var PlayPressed: Sprite2D = $PLAY/Sprite2D
const PlayP = preload("res://Assets/PlayButton-1-Pressed.png")
@onready var ExitPressed: Sprite2D = $EXIT/Sprite2D
const ExitP = preload("res://Assets/ExitButton-1-Pressed.png")

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level1.tscn")

func _on_exit_button_up() -> void:
	get_tree().quit()

func _on_play_button_down() -> void:
	PlayPressed.texture = PlayP

func _on_exit_button_down() -> void:
	ExitPressed.texture = ExitP
