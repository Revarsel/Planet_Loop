extends Node

signal planet_destroyed

signal player_destroyed

signal player_reset

signal paused
signal unpaused

## The level's final planet was destroyed at `center`.
signal last_planet_destroyed(center: Vector2)
## The satellite finished spiralling into the centre and vanished.
signal satellite_exited

func emit_last_planet_destroyed(center: Vector2):
	last_planet_destroyed.emit(center)

func emit_satellite_exited():
	satellite_exited.emit()

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
