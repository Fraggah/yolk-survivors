extends Control
var section: Node2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_to_group("boss_turret_indicators")

func _process(_delta: float) -> void:
	if not Global.game_paused: queue_redraw()

func markers() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not is_instance_valid(section) or not section.running: return result
	var viewport_size := get_viewport_rect().size
	var center := viewport_size*0.5
	# Leave the health/currency HUD unobscured along the top edge.
	var safe := Rect2(Vector2(36,132),viewport_size-Vector2(72,168))
	var canvas := get_viewport().get_canvas_transform()
	for turret in section.turrets:
		var screen: Vector2 = canvas*section.to_global(turret.position)
		if Rect2(Vector2.ZERO,viewport_size).has_point(screen): continue
		var direction := screen-center
		var distance := INF
		if direction.x > 0: distance = minf(distance,(safe.end.x-center.x)/direction.x)
		elif direction.x < 0: distance = minf(distance,(safe.position.x-center.x)/direction.x)
		if direction.y > 0: distance = minf(distance,(safe.end.y-center.y)/direction.y)
		elif direction.y < 0: distance = minf(distance,(safe.position.y-center.y)/direction.y)
		var point := center+direction*distance
		# Search neighboring edge slots when multiple turrets share a direction.
		var side_edge := is_equal_approx(point.x,safe.position.x) or is_equal_approx(point.x,safe.end.x)
		for step in [0,1,-1,2,-2,3,-3,4,-4,5,-5]:
			var candidate := point+Vector2(0,step*58) if side_edge else point+Vector2(step*58,0)
			if candidate.x < safe.position.x or candidate.x > safe.end.x or candidate.y < safe.position.y or candidate.y > safe.end.y: continue
			var crowded := false
			for previous in result:
				if candidate.distance_to(previous.point) < 54: crowded = true
			if not crowded:
				point = candidate
				break
		result.append({"point":point,"diagonal":turret.diagonal,"active":turret.beams.stage==1,"angle":turret.get("angle",PI*0.25 if turret.diagonal else 0.0),"turn":turret.get("rotation_sign",0.0)})
	return result

func _draw() -> void:
	for marker in markers():
		var point: Vector2 = marker.point
		var color := Color("ff9b39") if marker.active else Color("ffe4a8")
		draw_circle(point,25,Color("35251c"),true,-1,true)
		draw_arc(point,25,0,TAU,40,color,3,true)
		var angle: float = marker.angle
		if marker.turn != 0:
			preload("res://scenes/bosses/turret_rotation_cue.gd").draw_turn(self,point,32,angle,marker.turn,color)
		for offset in [0.0,PI*0.5]:
			var direction := Vector2.from_angle(angle+offset)*12
			draw_line(point-direction,point+direction,color,4,true)
