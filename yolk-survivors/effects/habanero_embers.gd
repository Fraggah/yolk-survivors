extends Node2D
var settings: SpicyExplosionSettings
var radius := 0.0
var elapsed := 0.0
var sparks: Array[Vector4] = []
func setup(config: SpicyExplosionSettings, blast_radius: float) -> void:
	settings = config
	radius = blast_radius
	z_index = 0
	add_to_group("projectiles")
	for i in settings.ember_count:
		sparks.append(Vector4(randf()*TAU,randf_range(0.2,0.65),randf_range(0.7,1.25),randf_range(0.6,1.4)))
func _process(delta: float) -> void:
	if Global.game_paused: return
	elapsed += delta
	if elapsed >= maxf(0.01,settings.ember_duration):
		queue_free()
		return
	queue_redraw()
func _draw() -> void:
	if not settings: return
	var t := clampf(elapsed/maxf(0.01,settings.ember_duration),0,1)
	for spark in sparks:
		var direction := Vector2.from_angle(spark.x)
		var distance := radius*(spark.y+settings.ember_travel*(1.0-pow(1.0-t,2.0))*spark.z)
		var point := direction*distance*Vector2(1,settings.area_y_ratio)
		point.y -= radius*0.12*sin(t*PI)*spark.w
		var size := settings.ember_size*Global.GAME_ENTITY_SCALE*spark.w*(1.0-t*0.7)
		var color := settings.color.lerp(settings.core_color,0.45*(1.0-t))
		color.a = settings.opacity*(1.0-t)*(1.0-t)
		draw_set_transform(point,spark.x,Vector2.ONE)
		draw_colored_polygon(PackedVector2Array([Vector2(-size*2.5,0),Vector2(0,-size*0.65),Vector2(size,0),Vector2(0,size*0.65)]),color)
	draw_set_transform(Vector2.ZERO)
