extends Node2D
class_name FloatingText

@onready var label: Label = $Label
var managed := false
var recycle: Callable
var pause_source: Node
var elapsed := 0.0
var lifetime := 1.3
var animation_scale := 1.0
var start_position := Vector2.ZERO

func _ready() -> void:
	set_process(false)

func setup_text(value: String, color: Color, duration: float = 1.3) -> void:
	label.text = value
	modulate = color
	scale = Vector2.ZERO
	
	rotation = deg_to_rad(randf_range(-10, 10))
	var random_scale := randf_range(.8, 1.6)
	if managed:
		elapsed = 0.0
		lifetime = maxf(0.01,duration)
		animation_scale = random_scale
		start_position = global_position
		set_process(true)
		return
	
	var tween := create_tween()
	var timing := maxf(0.01, duration) / 1.3
	
	tween.parallel().tween_property(self, "scale", Vector2.ONE * random_scale, .4 * timing)
	tween.parallel().tween_property(self, "global_position", global_position + Vector2.UP * 15, .4 * timing)
	
	tween.tween_interval(.5 * timing)
	
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, .4 * timing)
	tween.parallel().tween_property(self, "modulate:a", .0, .4 * timing)
	
	await tween.finished
	queue_free()

func _process(delta: float) -> void:
	if not managed or pause_source.game_paused: return
	elapsed += delta
	var time := elapsed/lifetime*1.3
	if time>=1.3:
		recycle.call()
		return
	var growth := clampf(time/0.4,0.0,1.0)
	var fade := clampf((time-0.9)/0.4,0.0,1.0)
	scale = Vector2.ONE*animation_scale*growth*(1.0-fade)
	global_position = start_position+Vector2.UP*15.0*growth
	modulate.a = 1.0-fade
