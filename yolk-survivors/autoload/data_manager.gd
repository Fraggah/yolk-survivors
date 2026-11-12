extends Node

const SETTINGS_PATH := "user://settings.cfg"
const LEGACY_SAVE_PATH := "user://save.cfg"

var master_volume := 1.0

func _ready() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		config.load(LEGACY_SAVE_PATH)
	set_master_volume(config.get_value("audio", "master_volume", 1.0))
	SoundManager.set_music_volume(config.get_value("audio", "music_volume", 1.0))
	SoundManager.set_sfx_volume(config.get_value("audio", "sfx_volume", 1.0))
	UITheme.set_palette(config.get_value("display", "palette", UITheme.PALETTES.find_key(UITheme.palette)))
	if DisplayServer.get_name() == "headless": return
	var fullscreen: bool = config.get_value("display", "fullscreen", DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	var vsync: int = config.get_value("display", "vsync", DisplayServer.window_get_vsync_mode())
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_vsync_mode(vsync)

func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))
	AudioServer.set_bus_mute(0, is_zero_approx(master_volume))

func save_settings() -> Error:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", SoundManager.music_volume)
	config.set_value("audio", "sfx_volume", SoundManager.sfx_volume)
	config.set_value("display", "palette", UITheme.PALETTES.find_key(UITheme.palette))
	config.set_value("display", "fullscreen", DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	config.set_value("display", "vsync", DisplayServer.window_get_vsync_mode())
	return config.save(SETTINGS_PATH)
