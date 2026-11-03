extends Node
## Player settings (autoload "Settings"), saved to user://settings.cfg so they
## stick between sessions. Music on/off mutes the "Music" audio bus, which the
## background music and ambient accents play on; sound effects are unaffected.

signal music_changed(enabled: bool)

const PATH := "user://settings.cfg"
const MUSIC_BUS := &"Music"

var music_enabled: bool = true


func _ready() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) == OK:
		music_enabled = bool(cfg.get_value("audio", "music", true))
	_apply()


func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	_apply()
	var cfg := ConfigFile.new()
	cfg.load(PATH) # keep any other settings; fine if the file doesn't exist yet
	cfg.set_value("audio", "music", music_enabled)
	var err := cfg.save(PATH)
	if err != OK:
		push_warning("Settings: could not save %s (error %d)" % [PATH, err])
	music_changed.emit(music_enabled)


func _apply() -> void:
	var idx := AudioServer.get_bus_index(MUSIC_BUS)
	if idx < 0:
		push_warning("Settings: no '%s' audio bus; check default_bus_layout.tres" % MUSIC_BUS)
		return
	AudioServer.set_bus_mute(idx, not music_enabled)
