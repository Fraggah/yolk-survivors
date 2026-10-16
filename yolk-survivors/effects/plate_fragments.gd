extends Node2D
var pieces: Array[Dictionary] = []
var elapsed := 0.0
var duration := 0.45
var edge_color := Color("c4bba7")
var edge_width := 0.1
func setup(config: RangedSettings) -> void:
	add_to_group("projectiles")
	z_index = 8
	duration = maxf(0.01, config.plate_fragment_duration)
	edge_color = config.plate_fragment_edge_color
	edge_width = config.plate_fragment_edge_width
	for i in config.plate_fragment_count:
		pieces.append({"point":Vector2.ZERO, "velocity":Vector2.from_angle(randf()*TAU)*randf_range(0.5,1.0)*config.plate_fragment_speed, "angle":randf()*TAU,"spin":randf_range(-12,12),"size":randf_range(3,7)*Global.GAME_ENTITY_SCALE})
func _process(delta: float) -> void:
	if Global.game_paused: return
	elapsed += delta
	if elapsed >= duration:
		queue_free()
		return
	for piece in pieces:
		piece.point += piece.velocity * delta
		piece.velocity *= exp(-3.0*delta)
		piece.velocity.y += 110.0*delta
		piece.angle += piece.spin*delta
	queue_redraw()
func _draw() -> void:
	var alpha := clampf((duration-elapsed)/minf(duration,0.15),0.0,1.0)
	for piece in pieces:
		draw_set_transform(piece.point,piece.angle,Vector2.ONE*piece.size)
		var points := PackedVector2Array([Vector2(-1,-0.4),Vector2(0.3,-0.7),Vector2(1,0.3),Vector2(-0.4,0.7)])
		draw_colored_polygon(points,Color(1,0.97,0.89,alpha))
		var border := points.duplicate()
		border.append(points[0])
		var outline := edge_color
		outline.a *= alpha
		if edge_width > 0.0: draw_polyline(border,outline,edge_width,true)
	draw_set_transform(Vector2.ZERO)
