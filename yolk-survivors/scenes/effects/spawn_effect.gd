extends Sprite2D
class_name SpawnEffect

signal completed
@onready var anim_player: AnimationPlayer = $AnimationPlayer
var completion_sent := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("spawn_effects")
	anim_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(_animation: StringName) -> void:
	complete()

func complete() -> void:
	if completion_sent: return
	completion_sent = true
	completed.emit()
	queue_free()
