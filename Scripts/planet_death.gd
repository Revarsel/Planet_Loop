extends GPUParticles2D

func _ready() -> void:
	emitting = true
	finished.connect(_on_particle_finished)

func _on_particle_finished():
	queue_free()
