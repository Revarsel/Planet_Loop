extends Node

signal planet_destroyed

signal player_destroyed

signal player_reset

signal paused
signal unpaused

func emit_planet_destroyed():
	planet_destroyed.emit()

func emit_player_destroyed():
	player_destroyed.emit()

func emit_player_reset():
	player_reset.emit()

func emit_paused():
	paused.emit()

func emit_unpaused():
	unpaused.emit()
