extends Node

signal planet_destroyed

func emit_planet_destroyed():
	planet_destroyed.emit()
