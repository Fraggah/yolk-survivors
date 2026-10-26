extends AudioStreamPlayer
## Editable music library and a single voice shared across gameplay screens.
@export_group("Music")
@export var menu_music: AudioStream
@export var shop_music: AudioStream
@export var wave_music_tracks: Array[AudioStream] = []
@export var boss_music_tracks: Array[AudioStream] = []
@export_group("")
var context := ""

func _ready() -> void:
	finished.connect(_repeat_track)

func play_track(track: AudioStream, next_context: String) -> void:
	context = next_context
	stream_paused = false
	if stream == track and playing: return
	stop()
	stream = track
	if stream: play()

func _repeat_track() -> void:
	if stream: play()

func choose_music(wave: WaveData, stage: ArenaStage, boss: bool = false) -> AudioStream:
	var sources: Array = []
	if wave: sources.append(wave.music_tracks)
	if stage: sources.append(stage.music_tracks)
	sources.append(boss_music_tracks if boss else wave_music_tracks)
	for tracks in sources:
		var valid: Array[AudioStream] = []
		for track in tracks:
			if track: valid.append(track)
		if not valid.is_empty(): return valid.pick_random()
	return null

