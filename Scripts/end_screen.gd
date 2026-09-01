extends Control

@onready var MainPressed: Sprite2D = $MainMenu/Sprite2D
const MainP = preload("res://Assets/MainMenuButton-1-pressed.png")
const MainU = preload("res://Assets/MainMenuButton-1.png")

@onready var ExitPressed: Sprite2D = $EXIT/Sprite2D
const ExitP = preload("res://Assets/ExitButton-1-Pressed.png")
const ExitU = preload("res://Assets/ExitButton-1.png")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()

func _on_main_menu_pressed() -> void:
	MainPressed.texture = MainU
	
	#var Main_Menu: Node2D = load("res://Scenes/world.tscn").instantiate()
	
	#get_node("/root/World/Level").add_child(Main_Menu)
	#get_node("/root/World").curr_state = States.states.Level
	
	
	#queue_free()
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _on_exit_button_up() -> void:
	ExitPressed.texture = ExitU
	get_tree().quit()

func _on_main_menu_button_down() -> void:
	MainPressed.texture = MainP

func _on_exit_button_down() -> void:
	ExitPressed.texture = ExitP
