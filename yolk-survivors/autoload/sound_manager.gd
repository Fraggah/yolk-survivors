extends Node

@export var stream_players: Array[AudioStreamPlayer]

enum Sound {
	ENEMY_HIT,
	FIRE,
	UI_CLICK,
	PUNCH
}

var sound_dictionary: Dictionary[Sound, Resource] = {
	Sound.FIRE: preload("res://assets/audio/ShotgunFire.wav"),
	Sound.ENEMY_HIT: preload("res://assets/audio/EnemyHit.wav"),
	Sound.UI_CLICK: preload("res://assets/audio/UI Pop.mp3"),
	Sound.PUNCH: preload("res://assets/audio/Punch.mp3")
}

func play_sound(type: int) -> void:
	var stream := get_free_stream_player()
	if not stream: return
	 
	var audio := sound_dictionary[type]
	stream.stream = audio
	stream.pitch_scale = randf_range(.8, 1.2)
	stream.play()


func get_free_stream_player() -> AudioStreamPlayer:
	for stream: AudioStreamPlayer in stream_players:
		if not stream.playing:
			return stream
	
	return null
