extends Button
class_name MusicToggle
## Square music on/off button drawn in the same wood style as the menu buttons:
## a pixel music note, with a red slash when the music is off.

const FILL := Color8(217, 160, 102)
const FILL_HOVER := Color8(229, 178, 122)
const FILL_PRESSED := Color8(196, 140, 86)
const BORDER := Color8(143, 86, 59)
const SHADE := Color8(163, 102, 73)
const SLASH := Color8(200, 60, 50)
## Size of one "pixel" of the drawing, in screen pixels.
const PX := 4.0

## The note on an 11 x 11 grid (X = filled).
const NOTE := [
	"......XX...",
	"......XXX..",
	"......X.XX.",
	"......X..X.",
	"......X....",
	"......X....",
	"......X....",
	"...XXXX....",
	"..XXXXX....",
	"..XXXXX....",
	"...XXX.....",
]


func _ready() -> void:
	flat = true
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = Vector2(PX * 17, PX * 17)
	size = custom_minimum_size
	tooltip_text = "Music on/off"
	pressed.connect(func(): Settings.set_music_enabled(not Settings.music_enabled))
	Settings.music_changed.connect(func(_on): queue_redraw())
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	button_down.connect(queue_redraw)
	button_up.connect(queue_redraw)


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var fill := FILL
	if is_pressed():
		fill = FILL_PRESSED
	elif is_hovered():
		fill = FILL_HOVER
	draw_rect(r, BORDER)
	draw_rect(r.grow(-PX), fill)
	draw_rect(Rect2(PX, size.y - PX * 3, size.x - PX * 2, PX * 2), SHADE) # bottom lip, like the other buttons

	var origin := ((size - Vector2(11, 11) * PX) / 2.0).floor() - Vector2(0, PX)
	for y in NOTE.size():
		var row: String = NOTE[y]
		for x in row.length():
			if row[x] == "X":
				draw_rect(Rect2(origin + Vector2(x, y) * PX, Vector2(PX, PX)), BORDER)

	if not Settings.music_enabled:
		# Pixel-stepped diagonal slash, top-right to bottom-left.
		for i in 12:
			draw_rect(Rect2(origin + Vector2(11 - i, i - 0.5) * PX - Vector2(PX, 0), Vector2(PX * 2, PX)), SLASH)
