extends Node2D
## Layered painted vapor; only the parent ground oval deals damage.
var settings: SpicyPatternSettings
var radius := 1.0
var duration := 5.0
var elapsed := 0.0
var puffs: MultiMeshInstance2D
var cloud_material: ShaderMaterial
var ground_material: ShaderMaterial
var seeds: Array[Vector4] = []
var puff_origins: Array[Vector2] = []
var texture: Texture2D

func configure(config: SpicyPatternSettings, reach: float, lifetime: float) -> void:
	settings = config
	radius = reach
	duration = lifetime
	texture = settings.cloud_texture
	if not texture: texture = load("res://assets/sprites/Effects/ghost_pepper_cloud.png")
	var ground := ColorRect.new()
	ground.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var extent := Vector2(radius,radius*settings.area_y_ratio)
	ground.position = -extent
	ground.size = extent*2.0
	ground.z_as_relative = true
	ground.z_index = 0
	ground_material = ShaderMaterial.new()
	ground_material.shader = preload("res://shaders/ghost_cloud_ground.gdshader")
	ground_material.set_shader_parameter("tint",settings.color)
	ground.material = ground_material
	add_child(ground)
	puffs = MultiMeshInstance2D.new()
	puffs.multimesh = MultiMesh.new()
	puffs.multimesh.transform_format = MultiMesh.TRANSFORM_2D
	puffs.multimesh.use_colors = true
	puffs.multimesh.use_custom_data = true
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE
	puffs.multimesh.mesh = quad
	puffs.multimesh.instance_count = settings.cloud_layer_count
	cloud_material = ShaderMaterial.new()
	cloud_material.shader = preload("res://shaders/ghost_cloud.gdshader")
	cloud_material.set_shader_parameter("cloud_texture",texture)
	cloud_material.set_shader_parameter("opacity",settings.opacity)
	cloud_material.set_shader_parameter("distortion",settings.cloud_distortion)
	cloud_material.set_shader_parameter("billow_speed",settings.cloud_billow_speed)
	puffs.material = cloud_material
	puffs.z_as_relative = true
	puffs.z_index = 0
	add_child(puffs)
	for index in settings.cloud_layer_count:
		var seed := Vector4(randf(),randf(),randf(),randf())
		seeds.append(seed)
		# Stratify coverage while randomizing each cloud's composition.
		var angle := float(index)*2.399963+seed.z*1.6
		var distance := sqrt((float(index)+seed.y)/maxi(1,settings.cloud_layer_count))*radius*0.72
		puff_origins.append(Vector2(cos(angle),sin(angle)*settings.area_y_ratio)*distance)
		puffs.multimesh.set_instance_custom_data(index,Color(seed.x*TAU,seed.w,0,0))
	update_visual(0.0)

func update_visual(time: float) -> void:
	elapsed = time
	var fade := minf(clampf(elapsed/maxf(0.01,settings.cloud_fade_in),0,1),clampf((duration-elapsed)/maxf(0.01,settings.cloud_fade_out),0,1))
	cloud_material.set_shader_parameter("elapsed",elapsed)
	cloud_material.set_shader_parameter("fade",fade)
	ground_material.set_shader_parameter("fade",fade)
	for index in seeds.size():
		var seed := seeds[index]
		var lifetime := maxf(0.3,settings.cloud_puff_lifetime*(0.7+seed.z*0.6))
		var age := fposmod(elapsed*settings.cloud_billow_speed/lifetime+seed.x,1.0)
		var phase := seed.x*TAU+elapsed*settings.cloud_billow_speed*(0.55+seed.w)
		var life := smoothstep(0.0,0.18,age)*(1.0-smoothstep(0.65,1.0,age))
		var layer_scale := lerpf(settings.cloud_puff_min_scale,maxf(settings.cloud_puff_min_scale,settings.cloud_puff_max_scale),seed.y)
		var width := radius*2.25*layer_scale*(0.85+age*0.25+sin(phase)*0.06)
		var height := width*settings.area_y_ratio*(0.8+seed.w*0.35)
		var point := puff_origins[index]
		point += Vector2(sin(phase),cos(phase*0.73)*settings.area_y_ratio)*radius*settings.cloud_puff_drift
		point.y -= radius*settings.cloud_visual_height+age*radius*0.06
		var stretch := Vector2(width,height)
		puffs.multimesh.set_instance_transform_2d(index,Transform2D(sin(phase*0.4)*0.08,stretch,0.0,point))
		var tint := Color(1.0,0.88+seed.z*0.12,0.88+seed.w*0.12,settings.cloud_puff_opacity*(0.65+seed.w*0.5)*life)
		puffs.multimesh.set_instance_color(index,tint)
