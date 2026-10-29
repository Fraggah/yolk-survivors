extends Node2D
## Ground-only fire presentation; damage stays in SpicyPatternEffect.
var settings: SpicyPatternSettings
var fire_settings: Resource
var ground_material: ShaderMaterial
var flame_material: ShaderMaterial
var background_material: ShaderMaterial
var flames: MultiMeshInstance2D
var duration := 3.0
var coverage_entries: Array[Dictionary] = []
var coverage_radius := 1.0
var background: MultiMeshInstance2D

func configure(config: SpicyPatternSettings, radius: float, lifetime: float) -> void:
	settings = config
	duration = lifetime
	coverage_radius = radius
	fire_settings = config.trail_fire_visuals
	if not fire_settings: fire_settings = load("res://resources/statuses/fire_visual_default.tres")
	if GroundFire.enabled: return
	if GroundFire.enabled: return
	var floor_surface := ColorRect.new()
	floor_surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	floor_surface.z_as_relative = true
	floor_surface.z_index = 0
	var extent := Vector2(radius*2.0,radius*settings.area_y_ratio*2.0)
	floor_surface.position = Vector2(-extent.x*0.5,-extent.y*0.8)
	floor_surface.size = extent
	ground_material = ShaderMaterial.new()
	ground_material.shader = preload("res://shaders/burning_unit.gdshader")
	ground_material.set_shader_parameter("heat_color",settings.color)
	ground_material.set_shader_parameter("variation",float(get_instance_id()%997)*0.13)
	for property in ["flicker_speed","core_color","ember_count","ember_size","ember_opacity","heat_opacity"]:
		ground_material.set_shader_parameter(property,fire_settings.get(property))
	floor_surface.material = ground_material
	add_child(floor_surface)
	var texture: Texture2D = fire_settings.flame_texture
	if not texture: texture = load("res://assets/sprites/Effects/small_fire.png")
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE
	quad.center_offset = Vector3(0,-0.5,0)
	flames = _batch(quad,fire_settings.flame_count)
	flame_material = _material(texture,fire_settings.flame_opacity*settings.opacity)
	flames.material = flame_material
	var rng := RandomNumberGenerator.new()
	rng.seed = get_instance_id()
	for i in fire_settings.flame_count:
		var direction := Vector2.from_angle(rng.randf()*TAU)
		var point := direction*sqrt(rng.randf())*radius*0.8*Vector2(1,settings.area_y_ratio)
		var height: float = radius*settings.trail_flame_height*rng.randf_range(0.65,1.25)
		flames.multimesh.set_instance_transform_2d(i,Transform2D(0.0,Vector2(height*texture.get_width()/texture.get_height(),height),0.0,point))
		flames.multimesh.set_instance_color(i,Color.WHITE)
		flames.multimesh.set_instance_custom_data(i,Color(rng.randf()*TAU,rng.randf_range(0.65,1.6),rng.randf_range(fire_settings.flip_interval_min,maxf(fire_settings.flip_interval_min,fire_settings.flip_interval_max)),0))
	background = _batch(quad,1)
	background_material = _material(texture,fire_settings.background_flame_opacity*settings.opacity)
	background_material.set_shader_parameter("size_pulse",fire_settings.size_pulse*0.5)
	background.material = background_material
	background.multimesh.set_instance_transform_2d(0,Transform2D(0.0,Vector2(radius*1.8,radius*1.1),0.0,Vector2.ZERO))
	background.multimesh.set_instance_color(0,Color.WHITE)
	background.multimesh.set_instance_custom_data(0,Color(rng.randf()*TAU,0.75,1.1,0))
	move_child(background,1)
	update_visual(0.0)

func _batch(mesh: QuadMesh, count: int) -> MultiMeshInstance2D:
	var batch := MultiMeshInstance2D.new()
	batch.multimesh = MultiMesh.new()
	batch.multimesh.transform_format = MultiMesh.TRANSFORM_2D
	batch.multimesh.use_colors = true
	batch.multimesh.use_custom_data = true
	batch.multimesh.mesh = mesh
	batch.multimesh.instance_count = count
	batch.z_as_relative = true
	batch.z_index = 0
	add_child(batch)
	return batch

func _material(texture: Texture2D, opacity: float) -> ShaderMaterial:
	var shader_material := ShaderMaterial.new()
	shader_material.shader = preload("res://shaders/burning_flame_sprite.gdshader")
	shader_material.set_shader_parameter("flame_texture",texture)
	shader_material.set_shader_parameter("opacity",opacity)
	for property in ["size_pulse","flicker_speed","distortion_strength","distortion_frequency","distortion_speed"]:
		shader_material.set_shader_parameter(property,fire_settings.get(property))
	return shader_material

func update_visual(elapsed: float) -> void:
	if not ground_material: return
	if not ground_material: return
	_update_coverage(elapsed)
	var fade := minf(clampf(elapsed/maxf(0.01,settings.trail_fade_in),0.0,1.0),clampf((duration-elapsed)/maxf(0.01,settings.trail_fade_out),0.0,1.0))
	for shader_material in [ground_material,flame_material,background_material]:
		shader_material.set_shader_parameter("elapsed",elapsed)
		shader_material.set_shader_parameter("fade",fade)

func set_coverage(entries: Array[Dictionary]) -> void:
	coverage_entries = entries
	if not ground_material: return
	if not ground_material: return
	ground_material.set_shader_parameter("coverage_enabled", true)

func _coverage_at(point: Vector2, elapsed: float) -> float:
	var density := 0.0
	for entry in coverage_entries:
		var offset := point
		offset.y /= entry.ratio
		var spatial := 1.0 - smoothstep(entry.radius * 0.82, entry.radius, offset.length())
		var temporal := clampf((entry.lifetime - elapsed) / maxf(0.01, settings.trail_fade_out), 0.0, 1.0)
		density += spatial * temporal
	return density

func _update_coverage(elapsed: float) -> void:
	if coverage_entries.is_empty(): return
	var extents := PackedVector2Array()
	var weights := PackedFloat32Array()
	extents.resize(6)
	weights.resize(6)
	for index in mini(6, coverage_entries.size()):
		var entry := coverage_entries[index]
		extents[index] = Vector2(entry.radius / coverage_radius, entry.radius * entry.ratio / (coverage_radius * settings.area_y_ratio))
		weights[index] = clampf((entry.lifetime - elapsed) / maxf(0.01, settings.trail_fade_out), 0.0, 1.0)
	ground_material.set_shader_parameter("coverage_count", mini(6, coverage_entries.size()))
	ground_material.set_shader_parameter("coverage_extents", extents)
	ground_material.set_shader_parameter("coverage_weights", weights)
	for index in flames.multimesh.instance_count:
		var point := flames.multimesh.get_instance_transform_2d(index).origin
		var density := _coverage_at(point, elapsed)
		flames.multimesh.set_instance_color(index, Color(1, 1, 1, minf(density, 1.0) * (1.0 + maxf(0.0, density - 1.0) * 0.14)))
	var active_radius := 0.0
	for entry in coverage_entries:
		if elapsed < entry.lifetime: active_radius = maxf(active_radius, entry.radius)
	background.multimesh.set_instance_transform_2d(0, Transform2D(0.0, Vector2(active_radius * 1.8, active_radius * 1.1), 0.0, Vector2.ZERO))
