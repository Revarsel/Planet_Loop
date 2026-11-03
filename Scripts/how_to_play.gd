extends Control
## How To Play screen. Opened from the main menu or the pause menu, which set
## `previous_screen` and hide themselves. The bottom button goes back:
## - from the main menu: shows "Main Menu" and returns to it
## - from the pause menu: shows "Play" and resumes the game (no progress lost)

const MainP = preload("res://Assets/MainMenuButton-1-pressed.png")
const MainU = preload("res://Assets/MainMenuButton-1.png")
const PlayP = preload("res://Assets/PlayButton-1-Pressed.png")
const PlayU = preload("res://Assets/PlayButton-1.png")
## Button art height inside the button, so both images look the same size.
const ART_HEIGHT := 92.0

@onready var back_sprite: Sprite2D = $MainMenu/Sprite2D2

var previous_screen: Control
var _up_tex: Texture2D = MainU
var _down_tex: Texture2D = MainP


func _ready() -> void:
	# Wired here rather than in HowToPlay.tscn.
	$MainMenu.pressed.connect(_on_main_menu_pressed)
	$MainMenu.button_down.connect(_on_main_menu_button_down)
	$MainMenu.button_up.connect(_on_main_menu_button_up)
	if _from_pause():
		_up_tex = PlayU
		_down_tex = PlayP
	back_sprite.texture = _up_tex
	back_sprite.scale = Vector2.ONE * ART_HEIGHT / _up_tex.get_height()


func _from_pause() -> bool:
	return is_instance_valid(previous_screen) and previous_screen.is_in_group("pause")


func _on_main_menu_pressed() -> void:
	back_sprite.texture = _up_tex
	if _from_pause():
		get_node("/root/World").resume_game()
	elif is_instance_valid(previous_screen):
		previous_screen.visible = true
		queue_free()
	else:
		get_node("/root/World").go_to_main_menu()


func _on_main_menu_button_down() -> void:
	back_sprite.texture = _down_tex


func _on_main_menu_button_up() -> void:
	back_sprite.texture = _up_tex
