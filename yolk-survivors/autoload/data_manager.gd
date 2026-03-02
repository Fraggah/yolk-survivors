extends Node

const SAVE_PATH := "user://save.cfg"

func save_game() -> void:
	var config := ConfigFile.new()
	
	config.set_value("audio", "music_volume", SoundManager.music_volume)
	config.set_value("audio", "sfx_volume", SoundManager.sfx_volume)
	config.set_value("game", "level_reached", Global.level_reached)
	
	config.save(SAVE_PATH)

func load_game() -> bool:
	var config := ConfigFile.new()
	
	var err := config.load(SAVE_PATH)
	if err != OK:
		return false
	
	SoundManager.set_music_volume(
		config.get_value("audio", "music_volume", 1.0)
	)
	
	SoundManager.set_sfx_volume(
		config.get_value("audio", "sfx_volume", 1.0)
	)
	
	Global.level_reached = config.get_value(
		"game",
		"level_reached",
		1
	)
	return true
