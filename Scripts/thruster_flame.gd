extends GPUParticles2D
class_name ThrusterFlame
## Godot spawns each frame's particles at the emitter's current position, so a
## fast satellite leaves the flame in separate clumps. Each frame this stretches
## the spawn area back over the distance moved since the last frame, so new
## particles fill the gap and the flame stays smooth at any speed.

## Ignore jumps bigger than this (respawn / teleport), in pixels.
const MAX_GAP := 80.0
## Minimum spawn area half-size, in pixels.
const BASE_EXTENT := 1.5

var _mat: ParticleProcessMaterial
var _last_pos: Vector2


func _ready() -> void:
	# Own copy, so changing the spawn area never affects another instance.
	_mat = (process_material as ParticleProcessMaterial).duplicate()
	_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_material = _mat
	_last_pos = global_position


## Physics, not _process: the satellite only moves on physics steps, and on
## high-refresh screens several drawn frames share one step. The spread from
## the last step stays in place for every frame until the next one.
func _physics_process(_delta: float) -> void:
	var moved := global_position - _last_pos
	_last_pos = global_position
	if moved.length() > MAX_GAP:
		moved = Vector2.ZERO
	# The emitter turns with the satellite, so work in its local frame:
	# spawn anywhere between last frame's position and this one.
	var half := moved.rotated(-global_rotation) / 2.0
	_mat.emission_box_extents = Vector3(absf(half.x) + BASE_EXTENT, absf(half.y) + BASE_EXTENT, 0.0)
	_mat.emission_shape_offset = Vector3(-half.x, -half.y, 0.0)
