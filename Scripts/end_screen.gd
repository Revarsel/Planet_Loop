extends Control

@onready var MainPressed: Sprite2D = $MainMenu/Sprite2D
const MainP = preload("res://Assets/MainMenuButton-1-pressed.png")
const MainU = preload("res://Assets/MainMenuButton-1.png")

@onready var ExitPressed: Sprite2D = $EXIT/Sprite2D
const ExitP = preload("res://Assets/ExitButton-1-Pressed.png")
const ExitU = preload("res://Assets/ExitButton-1.png")

# No Esc handling here: closing the end screen used to leave a blank screen.

func _ready() -> void:
	# Wired here rather than in EndScreen.tscn.
	$MainMenu.pressed.connect(_on_main_menu_pressed)
	$MainMenu.button_down.connect(_on_main_menu_button_down)
	$MainMenu.button_up.connect(_on_main_menu_button_up)

func _on_main_menu_pressed() -> void:
	MainPressed.texture = MainU
	get_node("/root/World").go_to_main_menu()

func _on_main_menu_button_down() -> void:
	MainPressed.texture = MainP

func _on_main_menu_button_up() -> void:
	MainPressed.texture = MainU

func _on_exit_button_up() -> void:
	ExitPressed.texture = ExitU
	get_tree().quit()

func _on_exit_button_down() -> void:
	ExitPressed.texture = ExitP
