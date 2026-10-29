extends Node2D
## Presentation only: collision and burn remain confined to the ground oval.
var settings: SpicyPatternSettings
var radius := 1.0
var duration := 1.0
var elapsed := 0.0
var column_height := 0.0
var contact_sprite: Sprite2D
var contact_glow: Sprite2D
var contact_material: ShaderMaterial
var heat_surface: ColorRect
var heat_material: ShaderMaterial
var fill_sprite: Sprite2D
var fill_material: ShaderMaterial
var rings: MultiMeshInstance2D
var ring_texture: Texture2D
var base_flames: MultiMeshInstance2D
var contact_sparks: MultiMeshInstance2D
var contact_spark_seeds: Array[Vector4] = []
var embers: MultiMeshInstance2D
var ring_material: ShaderMaterial
var base_material: ShaderMaterial
var flame_material: ShaderMaterial
var ember_seeds: Array[Vector4] = []
var last_visual_time := -1.0

func configure(config: SpicyPatternSettings, reach: float, lifetime: float) -> void:
	settings = config
	radius = reach
	duration = lifetime
	var surface := ColorRect.new()
	surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var extent := Vector2(radius, radius*settings.area_y_ratio)
	surface.position = -extent
	surface.size = extent*2.0
	surface.z_as_relative = false
	surface.z_index = -1
	base_material = ShaderMaterial.new()
	base_material.shader = preload("res://shaders/fire_column_base.gdshader")
	base_material.set_shader_parameter("flame_color", settings.color)
	base_material.set_shader_parameter("core_color", settings.column_core_color)
	base_material.set_shader_parameter("opacity", settings.opacity)
	surface.material = base_material
	add_child(surface)
	heat_surface = ColorRect.new()
	heat_surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	heat_surface.z_as_relative = false
	# All refraction must precede every column body, not just its own body.
	heat_surface.z_index = -2
	heat_material = ShaderMaterial.new()
	heat_material.shader = preload("res://shaders/fire_column_heat.gdshader")
	heat_material.set_shader_parameter("strength_pixels", settings.column_heat_distortion_pixels)
	heat_material.set_shader_parameter("opacity", settings.column_heat_opacity)
	heat_surface.material = heat_material
	add_child(heat_surface)
	fill_sprite = Sprite2D.new()
	fill_sprite.texture = settings.column_fill_texture
	if not fill_sprite.texture: fill_sprite.texture = load("res://assets/sprites/Effects/reaper_fire_column_fill.png")
	fill_sprite.z_as_relative = true
	fill_sprite.z_index = 0
	fill_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	fill_material = ShaderMaterial.new()
	fill_material.shader = preload("res://shaders/fire_column_fill.gdshader")
	fill_material.set_shader_parameter("opacity", settings.column_fill_opacity)
	fill_material.set_shader_parameter("distortion", settings.column_distortion)
	fill_material.set_shader_parameter("flow_speed", settings.column_flow_speed)
	fill_sprite.material = fill_material
	add_child(fill_sprite)
	rings = _batch(0)
	ring_material = ShaderMaterial.new()
	ring_material.shader = preload("res://shaders/fire_column_ring.gdshader")
	ring_texture = settings.column_ring_texture
	if not ring_texture: ring_texture = load("res://assets/sprites/Effects/reaper_fire_ring_v2.png")
	ring_material.set_shader_parameter("ring_texture", ring_texture)
	ring_material.set_shader_parameter("opacity", settings.column_ring_opacity)
	ring_material.set_shader_parameter("center_opacity", settings.column_ring_center_opacity)
	ring_material.set_shader_parameter("distortion", settings.column_distortion)
	ring_material.set_shader_parameter("flow_speed", settings.column_flow_speed)
	rings.material = ring_material
	base_flames = _batch(settings.column_base_flames)
	flame_material = ShaderMaterial.new()
	flame_material.shader = preload("res://shaders/burning_flame_sprite.gdshader")
	flame_material.set_shader_parameter("flame_texture", load("res://assets/sprites/Effects/small_fire.png"))
	flame_material.set_shader_parameter("opacity", settings.opacity)
	flame_material.set_shader_parameter("distortion_strength", settings.column_distortion)
	base_flames.material = flame_material
	for index in settings.column_base_flames:
		var angle := lerpf(0.06, PI-0.06, float(index)/maxi(1, settings.column_base_flames-1))
		var point := Vector2(cos(angle), sin(angle)*settings.area_y_ratio)*radius*0.86
		var height := radius*randf_range(0.24,0.42)
		base_flames.multimesh.set_instance_transform_2d(index, Transform2D(0.0, Vector2(height*0.65,height), 0.0, point+Vector2(0,-height*0.5)))
		base_flames.multimesh.set_instance_custom_data(index, Color(randf()*TAU, randf_range(0.7,1.4), randf_range(0.5,1.4),0))
	contact_sprite = Sprite2D.new()
	contact_sprite.texture = settings.column_contact_texture
	if not contact_sprite.texture: contact_sprite.texture = load("res://assets/sprites/Effects/reaper_fire_ring.png")
	contact_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	contact_sprite.z_as_relative = true
	contact_sprite.z_index = 0
	contact_material = ShaderMaterial.new()
	contact_material.shader = preload("res://shaders/fire_column_contact.gdshader")
	contact_material.set_shader_parameter("opacity", settings.column_contact_opacity)
	contact_material.set_shader_parameter("front_start", settings.column_contact_front_start)
	contact_material.set_shader_parameter("distortion", settings.column_distortion)
	contact_sprite.material = contact_material
	add_child(contact_sprite)
	contact_glow = Sprite2D.new()
	contact_glow.texture = contact_sprite.texture
	contact_glow.texture_filter = contact_sprite.texture_filter
	contact_glow.material = contact_material
	contact_glow.self_modulate.a = settings.column_contact_glow_opacity
	add_child(contact_glow)
	move_child(contact_glow,contact_sprite.get_index())
	contact_sparks = _batch(settings.column_contact_spark_count)
	var spark_material := ShaderMaterial.new()
	spark_material.shader = preload("res://shaders/fire_column_spark.gdshader")
	contact_sparks.material = spark_material
	for index in settings.column_contact_spark_count:
		contact_spark_seeds.append(Vector4(randf(), randf(), randf(), randf()))
	embers = _batch(settings.column_ember_count)
	for index in settings.column_ember_count:
		ember_seeds.append(Vector4(randf(),randf(),randf(),randf()))
	update_visual(0.0)

func _batch(count: int) -> MultiMeshInstance2D:
	var result := MultiMeshInstance2D.new()
	result.multimesh = MultiMesh.new()
	result.multimesh.transform_format = MultiMesh.TRANSFORM_2D
	result.multimesh.use_colors = true
	result.multimesh.use_custom_data = true
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE
	result.multimesh.mesh = quad
	result.multimesh.instance_count = count
	for index in count: result.multimesh.set_instance_color(index, Color.WHITE)
	result.z_as_relative = true
	result.z_index = 0
	add_child(result)
	return result

func _configured_height() -> float:
	# Fixed world height; camera movement and zoom must never stretch the fire.
	return settings.column_height*Global.GAME_ENTITY_SCALE

func update_visual(time: float) -> void:
	if settings.column_visual_update_rate>0.0 and time>=last_visual_time and time-last_visual_time<1.0/settings.column_visual_update_rate: return
	last_visual_time = time
	elapsed = time
	column_height = _configured_height()
	var fill_height := column_height + radius*settings.area_y_ratio
	fill_sprite.scale = Vector2(radius*settings.column_fill_width/fill_sprite.texture.get_width(), fill_height/fill_sprite.texture.get_height())
	fill_sprite.position = Vector2(0, (radius*settings.area_y_ratio-column_height)*0.5)
	fill_material.set_shader_parameter("base_roundness", radius*settings.area_y_ratio/fill_height)
	fill_material.set_shader_parameter("world_height", fill_height)
	fill_material.set_shader_parameter("base_depth", radius*settings.area_y_ratio)
	ring_material.set_shader_parameter("body_texture", fill_sprite.texture)
	ring_material.set_shader_parameter("body_height", fill_height)
	ring_material.set_shader_parameter("body_depth", radius*settings.area_y_ratio)
	ring_material.set_shader_parameter("body_width", radius*settings.column_fill_width)
	var pixel_transform := get_viewport().get_stretch_transform()*get_global_transform_with_canvas() if is_inside_tree() else global_transform
	ring_material.set_shader_parameter("column_screen_origin", pixel_transform.origin)
	ring_material.set_shader_parameter("column_screen_scale", Vector2(pixel_transform.x.x,pixel_transform.y.y))
	for shader_material in [fill_material, heat_material, ring_material]:
		shader_material.set_shader_parameter("flare_height", settings.column_flare_height*Global.GAME_ENTITY_SCALE)
		shader_material.set_shader_parameter("top_width_multiplier", settings.column_top_width_multiplier)
	var contact_width := radius*2.25
	var contact_height := contact_width*contact_sprite.texture.get_height()/contact_sprite.texture.get_width()
	contact_sprite.scale = Vector2.ONE*contact_width/contact_sprite.texture.get_width()
	contact_sprite.position = Vector2(0, radius*settings.area_y_ratio-contact_height*0.5)
	contact_glow.scale = contact_sprite.scale*settings.column_contact_glow_scale
	contact_glow.position = contact_sprite.position
	var heat_width := radius*(2.0+settings.column_heat_side_reach*2.0)
	heat_surface.position = Vector2(-heat_width*0.5,-column_height)
	heat_surface.size = Vector2(heat_width,fill_height+radius*0.2)
	heat_material.set_shader_parameter("world_height",heat_surface.size.y)
	heat_material.set_shader_parameter("base_depth", radius*(settings.area_y_ratio+0.2))
	var spacing := maxf(8.0, settings.column_ring_spacing*Global.GAME_ENTITY_SCALE)
	var count := maxi(2, ceili(column_height/spacing)+2)
	if rings.multimesh.instance_count != count:
		rings.multimesh.instance_count = count
	var fade := minf(clampf(elapsed/settings.column_fade_in,0,1), clampf((duration-elapsed)/settings.column_fade_out,0,1))
	for shader_material in [base_material, ring_material, flame_material, fill_material, contact_material, heat_material]:
		shader_material.set_shader_parameter("elapsed", elapsed)
		shader_material.set_shader_parameter("fade", fade)
	for index in count:
		var height := (float(index)+sin(float(index)*2.399963)*0.12+fposmod(elapsed*settings.column_flow_speed,1.0))*spacing
		var phase := float(index)*2.399963
		var depth := radius*settings.area_y_ratio
		var body_width := _width_at_height(height)
		var width := radius*body_width
		var sprite_size := Vector2(width*1.85, width*1.85*ring_texture.get_height()/ring_texture.get_width()*settings.column_ring_height_scale*(1.0+0.12*sin(phase)))
		var center_height := height-depth+sprite_size.y*0.5
		var center_uv_y := (column_height-center_height)/fill_height
		var time_value := elapsed*settings.column_flow_speed
		var drift := (sin(center_uv_y*19.0-time_value*1.8)*0.65+sin(center_uv_y*33.0+time_value*1.2)*0.35)*settings.column_distortion
		var center_scale := _width_at_height(center_height)
		var center_x := (0.015-drift)*radius*settings.column_fill_width*center_scale
		var anchor := Vector2(center_x, -center_height)
		rings.multimesh.set_instance_transform_2d(index, Transform2D(0.0, sprite_size,0.0,anchor))
		rings.multimesh.set_instance_color(index, Color.WHITE)
		rings.multimesh.set_instance_custom_data(index, Color(phase,center_height,sprite_size.x,sprite_size.y))
	_update_contact_sparks(fade)
	for index in ember_seeds.size():
		var particle_seed := ember_seeds[index]
		var age := fposmod(elapsed*(0.35+particle_seed.z*0.3)+particle_seed.x,1.0)
		var height := age*column_height
		var angle := particle_seed.y*TAU+elapsed*(1.2+particle_seed.w)
		var point := Vector2(cos(angle)*radius*_width_at_height(height)*(0.8+particle_seed.z*0.5), -height+sin(angle)*radius*settings.area_y_ratio)
		var size := settings.column_ember_size*Global.GAME_ENTITY_SCALE*(0.5+particle_seed.w)
		embers.multimesh.set_instance_transform_2d(index, Transform2D(angle, Vector2(size,size*1.8),0.0,point))
		var tint := settings.column_core_color
		tint.a = sin(age*PI)*fade*0.8
		embers.multimesh.set_instance_color(index,tint)

func _update_contact_sparks(fade: float) -> void:
	for index in contact_spark_seeds.size():
		var particle_seed := contact_spark_seeds[index]
		var lifetime := maxf(0.1, settings.column_contact_spark_lifetime*(0.65+particle_seed.w*0.7))
		var age := fposmod(elapsed/lifetime+particle_seed.x,1.0)
		var angle := lerpf(0.05, PI-0.05, particle_seed.y)
		var direction := Vector2(cos(angle), sin(angle)*settings.area_y_ratio)
		var travel := radius*settings.column_contact_spark_travel*(0.35+particle_seed.z*0.65)
		var ground := direction*(radius*0.88+travel*age)
		var leap := radius*settings.column_contact_spark_height*(0.25+particle_seed.w*0.75)
		var point := ground-Vector2(0,4.0*leap*age*(1.0-age))
		var velocity := direction*travel-Vector2(0,4.0*leap*(1.0-2.0*age))
		var size := settings.column_contact_spark_size*Global.GAME_ENTITY_SCALE*(0.55+particle_seed.z*0.9)*(1.0-age*0.5)
		var streak := 1.0+particle_seed.w*2.6
		contact_sparks.multimesh.set_instance_transform_2d(index,Transform2D(velocity.angle(),Vector2(size*streak,size),0.0,point))
		var tint := settings.column_core_color.lerp(settings.color,age*0.75)
		tint.a = smoothstep(0.0,0.07,age)*(1.0-smoothstep(0.5,1.0,age))*settings.column_contact_spark_opacity*fade
		contact_sparks.multimesh.set_instance_color(index,tint)

func _width_at_height(height: float) -> float:
	var progress := pow(clampf(height/maxf(1.0,settings.column_flare_height*Global.GAME_ENTITY_SCALE),0.0,1.0),0.8)
	return lerpf(1.0,settings.column_top_width_multiplier,progress)
