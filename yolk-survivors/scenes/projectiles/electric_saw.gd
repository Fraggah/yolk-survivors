extends Projectile
## Procedural blade keeps the outline crisp at gameplay scale.
@export var blade_radius := 10.0
@export var tooth_count := 12
@export var spin_speed := 22.0
@export var outline_width := 1.8
@export var metal_color := Color("d9dedb")
@export var shadow_color := Color("82969d")
@export var electric_color := Color("80dbed")
var blade_angle := 0.0

func _process(delta: float) -> void:
	if Global.game_paused: return
	super._process(delta)
	blade_angle += delta * spin_speed
	queue_redraw()

func _draw() -> void:
	var teeth := PackedVector2Array()
	for i in maxi(3, tooth_count):
		var angle := blade_angle + TAU * i / maxi(3, tooth_count)
		for point in [Vector2(blade_radius * 0.78, 0).rotated(angle), Vector2(blade_radius, 0).rotated(angle + TAU / maxi(3, tooth_count) * 0.3), Vector2(blade_radius * 0.86, 0).rotated(angle + TAU / maxi(3, tooth_count) * 0.7)]:
			teeth.append(point)
	draw_colored_polygon(teeth, metal_color)
	teeth.append(teeth[0])
	draw_polyline(teeth, Color("242522"), outline_width, true)
	draw_circle(Vector2.ZERO, blade_radius * 0.55, shadow_color)
	draw_arc(Vector2.ZERO, blade_radius * 0.55, 0, TAU, 32, Color("242522"), outline_width, true)
	draw_circle(Vector2.ZERO, blade_radius * 0.22, electric_color)
	for i in 3:
		var angle := blade_angle + i * TAU / 3.0
		var spark := PackedVector2Array([Vector2(blade_radius * 0.58, 0).rotated(angle), Vector2(blade_radius * 0.7, -3).rotated(angle), Vector2(blade_radius * 0.83, 1).rotated(angle)])
		draw_polyline(spark, electric_color, 1.8, true)
