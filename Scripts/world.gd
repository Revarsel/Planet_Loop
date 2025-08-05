extends Node2D

var current_level: = 1
var curr_planets: int

var levels: Array[PackedScene] = [preload("res://Scenes/Level1.tscn"), preload("res://Scenes/Level2.tscn"), preload("res://Scenes/Level3.tscn"), preload("res://Scenes/Level4.tscn"), preload("res://Scenes/Level5.tscn"), preload("res://Scenes/Level6.tscn")]

@onready var level_node: Node2D = $Level
@onready var player: Player = $Player

func _ready() -> void:
	Signals.player_reset.connect(_player_reset)

func _process(delta: float) -> void:
	var planets: Array[Node] = get_tree().get_nodes_in_group("planet")
	if planets.size() == 0:
		current_level += 1
		if current_level > 3:
			get_tree().quit()
		level_node.get_child(0).queue_free()
		var curr_level = levels[current_level-1].instantiate()
		level_node.add_child(curr_level)

func _player_reset():
	var level: Marker2D = level_node.get_child(0).get_node("player_pos")
	player.global_position = level.global_position
	player._planet_destroyed()
	player.rotation = 0
	player.contact_monitor = true
