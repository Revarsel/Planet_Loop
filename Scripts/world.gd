extends Node2D

var current_level: = 1
var curr_level_reset_position: Vector2
var curr_planets: int

var player_dest: bool = false

## Real seconds to wait after the satellite spirals out and vanishes before
## the next level loads.
@export var level_clear_delay: float = 1.5
var _clearing: bool = false # level cleared: R is blocked until the next level
var _satellite_gone: bool = false # countdown only runs once this is true
var _clear_time_left: float = 0.0

@onready var camera: Camera2D = $Camera2D

var endScene: PackedScene = preload("res://Scenes/EndScreen.tscn")

@onready var levels: Array[PackedScene] = [preload("res://Scenes/Level1.tscn"), preload("res://Scenes/Level2.tscn"), preload("res://Scenes/Level3.tscn"), preload("res://Scenes/Level4.tscn"), preload("res://Scenes/Level5.tscn"), preload("res://Scenes/Level6.tscn"), preload("res://Scenes/Level7.tscn"), preload("res://Scenes/Level8.tscn"), preload("res://Scenes/Level9.tscn"), preload("res://Scenes/Level10.tscn")]

@onready var level_node: Node2D = $Level
@onready var particles_node: Node2D = $Particles
@onready var player_scene: = preload("res://Scenes/player.tscn")
@onready var pause_scene: = preload("res://Scenes/Pause.tscn")

func _ready() -> void:
	Signals.planet_destroyed.connect(_planet_destroyed)
	Signals.player_reset.connect(_player_reset)
	Signals.player_destroyed.connect(_player_destroyed)
	Signals.satellite_exited.connect(func(): _satellite_gone = true)
	Engine.time_scale = 2

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") and States.curr_state == States.states.Level and !player_dest:
		var pause = pause_scene.instantiate()
		$Screens.add_child(pause)
		States.curr_state = States.states.Pause
		camera.pause_cam()
		Signals.emit_paused()

	elif Input.is_action_just_pressed("ui_cancel") and States.curr_state == States.states.Pause:
		var paused_node = get_tree().get_first_node_in_group("pause")
		var screens = get_node("/root/World/Screens")
		if screens.get_child_count() == 1:
			paused_node.queue_free()
			States.curr_state = States.states.Level
			camera.update_cam()
			Signals.emit_unpaused()
		else:
			screens.get_child(-1).queue_free()
			screens.get_child(-2).visible = true
		
	var planets: Array[Node] = get_tree().get_nodes_in_group("planet")
	# Only runs in the Level state, so pausing holds the countdown.
	if States.curr_state == States.states.Level:
		if planets.size() > 0:
			_clearing = false
			_satellite_gone = false
		elif not _clearing:
			_clearing = true
			_clear_time_left = level_clear_delay
			# No satellite spiralling out (e.g. planets removed another way):
			# start the countdown straight away.
			var player := get_tree().get_first_node_in_group("player") as Player
			if player == null or not player.exiting:
				_satellite_gone = true
		elif _satellite_gone:
			# delta is scaled by Engine.time_scale; divide to count real seconds.
			_clear_time_left -= delta / Engine.time_scale
			if _clear_time_left <= 0.0:
				_clearing = false
				_advance_level()

func _advance_level() -> void:
	if current_level >= levels.size():
		level_node.get_child(0).queue_free()
		var endScreen: Control = endScene.instantiate()
		add_child(endScreen)
		States.curr_state = States.states.EndScreen
		camera.reset_cam()
		get_tree().get_first_node_in_group("player").queue_free()
	else:
		current_level += 1
		# Fresh satellite for the new level: nothing carries over. Leave the
		# group now so add_level() doesn't find the one being freed.
		var old := get_tree().get_first_node_in_group("player")
		if old != null:
			old.remove_from_group("player")
			old.queue_free()
	level_node.get_child(0).queue_free()
	add_level()
	for i in particles_node.get_children():
		i.queue_free()
	camera.update_cam()

func reset_level():
	if States.curr_state == States.states.Level:
		var curr_level1 = level_node.get_child(0)
		curr_level_reset_position = curr_level1.get_node("player_pos").global_position
		level_node.get_child(0).queue_free()
		var curr_level = levels[current_level-1].instantiate()
		level_node.add_child(curr_level)
		get_tree().get_first_node_in_group("player").queue_free()
		_player_reset()
		camera.update_cam()

func add_level():
	var curr_level = levels[current_level-1].instantiate()
	level_node.add_child(curr_level)
	curr_level_reset_position = curr_level.get_node("player_pos").global_position
	var player := get_tree().get_first_node_in_group("player")
	if player == null: # previous satellite was removed: start with a new one
		player = player_scene.instantiate()
		add_child(player)
		player_dest = false
	player.global_position = curr_level_reset_position

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# No restart once the level is cleared and the next one is on its way.
		if event.keycode == KEY_R and !player_dest and !_clearing:
			reset_level()
	
func _player_reset():
	var level: Marker2D = level_node.get_child(0).get_node("player_pos")
	var player: Player = player_scene.instantiate()
	add_child(player)
	player.global_position = level.global_position
	player_dest = false
	
func _player_destroyed():
	player_dest = true

func _planet_destroyed():
	camera.update_cam()
