extends Control

@onready var MainPressed: Sprite2D = $MainMenu/Sprite2D
const MainP = preload("res://Assets/MainMenuButton-1-pressed.png")
const MainU = preload("res://Assets/MainMenuButton-1.png")

func _on_main_menu_pressed() -> void:
	MainPressed.texture = MainU
	#get_tree().change_scene_to_file("res://Scenes/world.tscn")
	if States.curr_state == States.states.MainMenu:
		var back_scene = load("res://Scenes/MainMenu.tscn").instantiate()
		get_node("/root/World").add_child(back_scene)
	elif States.curr_state == States.states.Pause:
		get_node("/root/World/Pause").visible = true
	queue_free()

func _on_main_menu_button_down() -> void:
	MainPressed.texture = MainP
