extends AudioStreamPlayer
## Owned by the weapon: never survives selling, death or arena cleanup.
var active := false
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
func _process(_delta: float) -> void:
	if not active:
		stop()
		return
	stream_paused = Global.game_paused
	if not Global.game_paused and not playing: play()
