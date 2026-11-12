extends Node2D

@export var yolk_texture: Texture2D
@export var yolk_size := Vector2(46.0, 36.0)

var arcs: Array[Vector4] = []
var elapsed := 0.0
var lifetime := 0.0

func _process(delta: float) -> void:
	if Global.game_paused: return
	elapsed += delta
	if elapsed >= lifetime:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	for arc in arcs:
		var progress := clampf(elapsed / arc.z, 0.0, 1.0)
		if progress >= 1.0: continue
		var point := Vector2(arc.x, arc.y) * (1.0 - (1.0 - progress) * (1.0 - progress))
		point.y -= sin(PI * progress) * arc.w
		var opacity := 1.0 - smoothstep(0.75, 1.0, progress)
		draw_texture_rect(yolk_texture, Rect2(point - yolk_size * 0.5, yolk_size), false, Color(1.0, 1.0, 1.0, opacity))
