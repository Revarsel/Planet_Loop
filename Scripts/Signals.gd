extends Node

signal planet_destroyed

signal player_destroyed

func emit_planet_destroyed():
	planet_destroyed.emit()

func emit_player_destroyed():
	planet_destroyed.emit()
