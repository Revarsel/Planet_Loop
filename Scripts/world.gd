extends Node2D

var current_level: = 1
var curr_level_reset_position: Vector2
var curr_planets: int

@onready var curr_state: States.states = States.curr_state

var player_dest: bool = false

@onready var camera: Camera2D = $Camera2D

var levels: Array[PackedScene] = [preload("res://Scenes/Level1.tscn"), preload("res://Scenes/Level2.tscn"), preload("res://Scenes/Level3.tscn"), preload("res://Scenes/Level4.tscn"), preload("res://Scenes/Level5.tscn"), preload("res://Scenes/Level6.tscn")]

@onready var level_node: Node2D = $Level
@onready var player_scene: = preload("res://Scenes/player.tscn")

func _ready() -> void:
	Signals.planet_destroyed.connect(_planet_destroyed)
	Signals.player_reset.connect(_player_reset)
	Signals.player_destroyed.connect(_player_destroyed)

func _process(delta: float) -> void:
	var planets: Array[Node] = get_tree().get_nodes_in_group("planet")
	if planets.size() == 0 and curr_state == States.states.Level:
		current_level += 1
		if current_level > 6:
			get_tree().quit()
		level_node.get_child(0).queue_free()
		var curr_level = levels[current_level-1].instantiate()
		level_node.add_child(curr_level)
		curr_level_reset_position = curr_level.get_node("player_pos").global_position
		get_tree().get_first_node_in_group("player").global_position = curr_level_reset_position
		camera.update_cam()
		# curr_level.get_node("player_pos").global_position

func reset_level():
	if curr_state == States.states.Level:
		var curr_level1 = level_node.get_child(0)
		curr_level_reset_position = curr_level1.get_node("player_pos").global_position
		level_node.get_child(0).queue_free()
		var curr_level = levels[current_level-1].instantiate()
		level_node.add_child(curr_level)
		get_tree().get_first_node_in_group("player").queue_free()
		_player_reset()
		camera.update_cam()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R and !player_dest:
			reset_level()
	
func _player_reset():
	var level: Marker2D = level_node.get_child(0).get_node("player_pos")
	var player: Player = player_scene.instantiate()
	add_child(player)
	player.global_position = level.global_position
	player._planet_destroyed()
	player.rotation = 0
	player_dest = false
	
func _player_destroyed():
	player_dest = true

func _planet_destroyed():
	camera.update_cam()
