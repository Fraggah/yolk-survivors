extends Node2D
var start := Vector2.ZERO
var finish := Vector2.ZERO
var progress := 0.0
var firing := false

func _ready() -> void:
	z_index = -1
	add_to_group("boss_turret_paths")

func _draw() -> void:
	var origin := start.lerp(finish,progress) if firing else start
	var distance := origin.distance_to(finish)
	var color := Color(1,0.76,0.32,0.38 if firing else 0.9)
	var direction := origin.direction_to(finish)
	var side := direction.orthogonal()
	draw_line(origin,finish,Color(1,0.65,0.12,0.08),16,true)
	for index in ceili(distance/42):
		var from := origin+direction*index*42
		var to := origin+direction*minf(distance,index*42+24)
		draw_line(from,to,color,3,true)
	if distance > 30:
		for fraction in [0.25,0.6,0.9]:
			var point := origin.lerp(finish,fraction)
			draw_colored_polygon(PackedVector2Array([point+direction*14,point-direction*10+side*10,point-direction*10-side*10]),color)
	draw_arc(finish,18,0,TAU,32,color,3,true)
