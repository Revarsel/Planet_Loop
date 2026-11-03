extends Resource
class_name planet_sprite

@export var texture: Texture

@export var scale: float

@export var particle: String

## Colours for the debris when this planet explodes. Picked from the planet
## art; edit freely in the Inspector. Empty = use the planet's accent colour.
@export var debris_colors: PackedColorArray
