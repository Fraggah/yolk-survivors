extends Node2D
## Fast pressure front, brief echoes and radial fragments; no collision here.
var settings: SpicyPatternSettings
var radius := 1.0
var elapsed := 0.0
var wave_material: ShaderMaterial
var sparks: MultiMeshInstance2D
var seeds: Array[Vector3] = []

func configure(config: SpicyPatternSettings, reach: float) -> void:
	settings = config
	radius = reach
	var surface := ColorRect.new()
	surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var extent := Vector2(radius,radius*settings.area_y_ratio)*1.15
	surface.position = -extent
	surface.size = extent*2.0
	surface.z_as_relative = true
	surface.z_index = 0
	wave_material = ShaderMaterial.new()
	wave_material.shader = preload("res://shaders/rocoto_shockwave.gdshader")
	wave_material.set_shader_parameter("heat_color",settings.color)
	wave_material.set_shader_parameter("core_color",settings.shockwave_core_color)
	wave_material.set_shader_parameter("duration",settings.wave_duration)
	wave_material.set_shader_parameter("tail_duration",settings.shockwave_visual_tail)
	wave_material.set_shader_parameter("rim_width",settings.shockwave_rim_width)
	wave_material.set_shader_parameter("opacity",settings.opacity)
	wave_material.set_shader_parameter("variation",randf()*TAU)
	surface.material = wave_material
	add_child(surface)
	sparks = MultiMeshInstance2D.new()
	sparks.multimesh = MultiMesh.new()
	sparks.multimesh.transform_format = MultiMesh.TRANSFORM_2D
	sparks.multimesh.use_colors = true
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE
	sparks.multimesh.mesh = quad
	sparks.multimesh.instance_count = settings.shockwave_spark_count
	var spark_material := ShaderMaterial.new()
	spark_material.shader = preload("res://shaders/rocoto_fragment.gdshader")
	sparks.material = spark_material
	sparks.z_as_relative = true
	sparks.z_index = 0
	add_child(sparks)
	for index in settings.shockwave_spark_count:
		seeds.append(Vector3(float(index)*TAU/maxi(1,settings.shockwave_spark_count)+randf_range(-0.08,0.08),randf_range(0.65,1.1),randf_range(0.6,1.5)))
	update_visual(0.0)

func update_visual(time: float) -> void:
	elapsed = time
	wave_material.set_shader_parameter("elapsed",elapsed)
	var progress := clampf(elapsed/maxf(0.01,settings.wave_duration),0,1)
	var tail := clampf((elapsed-settings.wave_duration)/maxf(0.01,settings.shockwave_visual_tail),0,1)
	for index in seeds.size():
		var seed := seeds[index]
		var direction := Vector2(cos(seed.x),sin(seed.x)*settings.area_y_ratio)
		var point := direction*radius*(progress+tail*0.1)*seed.y
		point.y -= radius*0.08*sin(progress*PI)*seed.z
		var size := settings.shockwave_spark_size*Global.GAME_ENTITY_SCALE*seed.z
		sparks.multimesh.set_instance_transform_2d(index,Transform2D(direction.angle(),Vector2(size*(1.4+progress),size),0.0,point))
		var tint := settings.shockwave_core_color.lerp(settings.color,progress*0.55)
		tint.a = smoothstep(0.0,0.12,progress)*(1.0-tail)*(1.0-tail)*0.6
		sparks.multimesh.set_instance_color(index,tint)
