extends Control

@onready var MainPressed: Sprite2D = $MainMenu/Sprite2D
const MainP = preload("res://Assets/MainMenuButton-1-pressed.png")
const MainU = preload("res://Assets/MainMenuButton-1.png")

func _on_main_menu_pressed() -> void:
	MainPressed.texture = MainU
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _on_main_menu_button_down() -> void:
	MainPressed.texture = MainP
