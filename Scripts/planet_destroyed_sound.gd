extends AudioStreamPlayer
## Plays when any planet is destroyed. Lives in world.tscn rather than on the
## planet, because the planet is freed the moment it is destroyed.


func _ready() -> void:
	Signals.planet_destroyed.connect(play)
