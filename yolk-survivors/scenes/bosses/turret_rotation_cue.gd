extends Node2D
var radius := 84.0
var angle := 0.0
var turn := 1.0
var firing := false

func _draw() -> void:
	var color := Color("ff9b39") if firing else Color("ffe4a8")
	draw_turn(self,Vector2.ZERO,radius,angle,turn,color)

static func draw_turn(canvas: CanvasItem, center: Vector2, r: float, rotation_angle: float, sign_value: float, color: Color) -> void:
	var points := PackedVector2Array()
	var start := rotation_angle-PI*0.5
	var end := start+sign_value*TAU*0.72
	for index in 41:
		points.append(center+Vector2.from_angle(lerpf(start,end,index/40.0))*r)
	canvas.draw_polyline(points,color,3,true)
	var head := center+Vector2.from_angle(end)*r
	var forward := Vector2(-sin(end),cos(end))*sign_value
	var side := forward.orthogonal()
	var arrow_size := minf(12,r*0.3)
	canvas.draw_colored_polygon(PackedVector2Array([head+forward*arrow_size,head-forward*arrow_size+side*arrow_size*0.7,head-forward*arrow_size-side*arrow_size*0.7]),color)
