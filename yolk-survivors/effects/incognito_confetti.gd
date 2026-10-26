extends Node2D
## A single draw node for the shell, egg-white and yolk confetti burst.
const PALETTE := [Color("fffdf1"), Color("ead1aa"), Color("fff3d4"), Color("ffce32"), Color("f2a51b")]
var pieces: Array[Dictionary] = []
var elapsed := 0.0
var duration := 1.15
@export var size_multiplier := 1.4
@export var animation_speed := 1.5
var origin := Vector2(0, -30)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("incognito_confetti")
	for index in 72:
		var direction := Vector2.from_angle(TAU * float(index) / 72.0 + randf_range(-0.08, 0.08))
		pieces.append({"point": origin, "velocity": direction * randf_range(90, 260) + Vector2(0, -110), "angle": randf() * TAU, "spin": randf_range(-14, 14), "size": Vector2(randf_range(3, 7), randf_range(2, 5)), "phase": randf() * TAU, "color": PALETTE[index % PALETTE.size()]})
	queue_redraw()

func _process(delta: float) -> void:
	if Global.game_paused: return
	delta *= animation_speed
	elapsed += delta
	if elapsed >= duration:
		queue_free()
		return
	for piece in pieces:
		piece.point += piece.velocity * delta
		piece.velocity *= exp(-1.4 * delta)
		piece.velocity.y += 260.0 * delta
		piece.angle += piece.spin * delta
	queue_redraw()

func _draw() -> void:
	var alpha := clampf((duration - elapsed) / 0.3, 0.0, 1.0)
	for piece in pieces:
		var flutter := Vector2(0.35 + 0.65 * absf(cos(elapsed * 15.0 + piece.phase)), 1)
		draw_set_transform(origin + (piece.point - origin) * size_multiplier, piece.angle, piece.size * flutter * size_multiplier)
		var color: Color = piece.color
		color.a *= alpha
		draw_colored_polygon(PackedVector2Array([Vector2(-1, -0.7), Vector2(0.7, -1), Vector2(1, 0.7), Vector2(-0.6, 1)]), color)
	draw_set_transform(Vector2.ZERO)
