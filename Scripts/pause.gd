extends Control

@onready var ExitPressed: Sprite2D = $EXIT/Sprite2D
const ExitP = preload("res://Assets/ExitButton-1-Pressed.png")
const ExitU = preload("res://Assets/ExitButton-1.png")

@onready var HowToPlayPressed: Sprite2D = $HowToPlayButton/Sprite2D
const HowToPlayP = preload("res://Assets/HowToPlay-ButtonPressed.png")
const HowToPlayU = preload("res://Assets/HowToPlay-Button.png")

@onready var ResumePressed: Sprite2D = $Resume/Sprite2D
const PlayP = preload("res://Assets/PlayButton-1-Pressed.png")
const PlayU = preload("res://Assets/PlayButton-1.png")

@onready var MainMenuPressed: Sprite2D = $MainMenu/Sprite2D
const MainP = preload("res://Assets/MainMenuButton-1-pressed.png")
const MainU = preload("res://Assets/MainMenuButton-1.png")

func _ready() -> void:
	# Wired here rather than in Pause.tscn so the buttons always work.
	$Resume.pressed.connect(_on_resume_pressed)
	$Resume.button_down.connect(_on_resume_button_down)
	$Resume.button_up.connect(_on_resume_button_up)
	$MainMenu.pressed.connect(_on_main_menu_pressed)
	$MainMenu.button_down.connect(_on_main_menu_button_down)
	$MainMenu.button_up.connect(_on_main_menu_button_up)
	$HowToPlayButton.button_up.connect(_on_how_to_play_button_button_up)

func _on_exit_button_up() -> void:
	ExitPressed.texture = ExitU
	get_tree().quit()

func _on_exit_button_down() -> void:
	ExitPressed.texture = ExitP

func _on_how_to_play_button_pressed() -> void:
	HowToPlayPressed.texture = HowToPlayU
	var how_to_play = load("res://Scenes/HowToPlay.tscn").instantiate()
	how_to_play.previous_screen = self # its back button resumes the game
	get_node("/root/World/Screens").add_child(how_to_play)
	visible = false

func _on_how_to_play_button_button_down() -> void:
	HowToPlayPressed.texture = HowToPlayP

func _on_how_to_play_button_button_up() -> void:
	HowToPlayPressed.texture = HowToPlayU

func _on_resume_pressed() -> void:
	ResumePressed.texture = PlayU
	get_node("/root/World").resume_game()

func _on_resume_button_down() -> void:
	ResumePressed.texture = PlayP

func _on_resume_button_up() -> void:
	ResumePressed.texture = PlayU

func _on_main_menu_pressed() -> void:
	MainMenuPressed.texture = MainU
	get_node("/root/World").go_to_main_menu()

func _on_main_menu_button_down() -> void:
	MainMenuPressed.texture = MainP

func _on_main_menu_button_up() -> void:
	MainMenuPressed.texture = MainU
