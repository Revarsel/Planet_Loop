extends Node
class_name Ambience
## Background audio: a looping music track, plus ambient accents that play
## now and then at random. Accents share one player, so two never overlap.
## All times are real seconds (world.gd speeds up game time, not these).

@export var music_volume_db: float = -8.0
@export var accent_streams: Array[AudioStream] = []
@export var accent_volume_db: float = -14.0
## Random wait after an accent ends before the next one starts.
@export var accent_gap_min: float = 20.0
@export var accent_gap_max: float = 45.0
## Random wait before the very first accent.
@export var first_gap_min: float = 8.0
@export var first_gap_max: float = 15.0
## Fade in/out length for the music start and for each accent.
@export var fade_time: float = 2.5

const SILENT_DB := -60.0

@onready var music: AudioStreamPlayer = $Music
@onready var accent: AudioStreamPlayer = $Accent

var _last_accent: AudioStream
var _schedule_id: int = 0 # only the newest scheduled accent may start
var _accent_id: int = 0 # only the current accent may fade itself out


func _ready() -> void:
	music.volume_db = SILENT_DB
	music.finished.connect(music.play) # keep looping even if the import has loop off
	music.play()
	_fade(music, music_volume_db)
	accent.finished.connect(func(): _schedule_accent(accent_gap_min, accent_gap_max))
	_schedule_accent(first_gap_min, first_gap_max)


## Start a random accent now. Does nothing if one is already playing.
func play_random_accent() -> void:
	if accent_streams.is_empty() or accent.playing:
		return
	_schedule_id += 1 # cancel any pending scheduled start
	var pick: AudioStream = accent_streams.pick_random()
	if pick == _last_accent and accent_streams.size() > 1:
		pick = accent_streams.pick_random() # re-roll once: repeats stay possible but rarer
	_last_accent = pick
	accent.stream = pick
	accent.volume_db = SILENT_DB
	accent.play()
	_fade(accent, accent_volume_db)

	_accent_id += 1
	var id := _accent_id
	await _wait(maxf(pick.get_length() - fade_time, 0.0))
	if id == _accent_id and accent.playing:
		_fade(accent, SILENT_DB)


func _schedule_accent(gap_min: float, gap_max: float) -> void:
	_schedule_id += 1
	var id := _schedule_id
	await _wait(randf_range(gap_min, gap_max))
	if id == _schedule_id:
		play_random_accent()


func _fade(player: AudioStreamPlayer, to_db: float) -> void:
	var tween := create_tween().set_ignore_time_scale(true)
	tween.tween_property(player, "volume_db", to_db, fade_time)


func _wait(seconds: float) -> Signal:
	# ignore_time_scale = true: real seconds even though the game runs at 2x.
	return get_tree().create_timer(seconds, true, false, true).timeout
