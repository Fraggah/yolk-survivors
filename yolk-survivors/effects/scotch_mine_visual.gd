extends Node2D
## Buried pepper and fast blast presentation. Damage belongs to the parent effect.
var settings: SpicyPatternSettings
var radius := 1.0
var sprite: Sprite2D
var base_scale := 1.0
var phase := randf()*TAU
var blast: ColorRect
var blast_material: ShaderMaterial
var flame_burst: MultiMeshInstance2D
var flame_material: ShaderMaterial
var flame_seeds: Array[Vector3] = []
var detonated := false
var elapsed := 0.0
static var texture_bounds: Dictionary = {}

func configure(config: SpicyPatternSettings, reach: float, texture: Texture2D) -> void:
	settings = config
	radius = reach
	sprite = Sprite2D.new()
	var dedicated := settings.mine_texture != null
	sprite.texture = settings.mine_texture if dedicated else texture
	sprite.region_enabled = true
	var id := sprite.texture.get_instance_id()
	if not texture_bounds.has(id): texture_bounds[id] = sprite.texture.get_image().get_used_rect()
	var region: Rect2 = settings.mine_texture_rect if dedicated and settings.mine_texture_rect.has_area() else texture_bounds[id]
	if not dedicated: region.size.y *= settings.mine_visible_fraction
	sprite.region_rect = region
	sprite.centered = false
	sprite.offset = Vector2(-region.size.x*0.5,-region.size.y)
	base_scale = settings.mine_visual_width*Global.GAME_ENTITY_SCALE/maxf(1.0,region.size.x)
	sprite.z_as_relative = true
	sprite.z_index = 0
	add_child(sprite)
	blast = ColorRect.new()
	blast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var extent := Vector2(radius,radius*settings.area_y_ratio)*1.35
	blast.position = -extent
	blast.size = extent*2.0
	blast.z_as_relative = true
	blast.z_index = 0
	blast_material = ShaderMaterial.new()
	blast_material.shader = preload("res://shaders/habanero_blast.gdshader")
	blast_material.set_shader_parameter("heat_color",settings.color)
	blast_material.set_shader_parameter("core_color",settings.mine_core_color)
	blast_material.set_shader_parameter("flame_color",settings.mine_flame_color)
	blast_material.set_shader_parameter("opacity",0.95)
	blast_material.set_shader_parameter("flame_strength",1.35)
	blast_material.set_shader_parameter("variation",phase)
	blast.material = blast_material
	blast.hide()
	add_child(blast)
	flame_burst = MultiMeshInstance2D.new()
	flame_burst.multimesh = MultiMesh.new()
	flame_burst.multimesh.transform_format = MultiMesh.TRANSFORM_2D
	flame_burst.multimesh.use_colors = true
	flame_burst.multimesh.use_custom_data = true
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE
	quad.center_offset = Vector3(0,-0.5,0)
	flame_burst.multimesh.mesh = quad
	flame_burst.multimesh.instance_count = settings.mine_blast_flame_count
	flame_material = ShaderMaterial.new()
	flame_material.shader = preload("res://shaders/burning_flame_sprite.gdshader")
	flame_material.set_shader_parameter("flame_texture",load("res://assets/sprites/Effects/small_fire.png"))
	flame_material.set_shader_parameter("opacity",0.9)
	flame_material.set_shader_parameter("distortion_strength",0.035)
	flame_burst.material = flame_material
	flame_burst.z_as_relative = true
	flame_burst.z_index = 0
	flame_burst.hide()
	add_child(flame_burst)
	for index in settings.mine_blast_flame_count:
		flame_seeds.append(Vector3(randf()*TAU,randf_range(0.45,0.8),randf_range(0.45,0.9)))
		flame_burst.multimesh.set_instance_custom_data(index,Color(randf()*TAU,1.0,0.7,0))
	update_visual(0.0, false, 0.0)

func detonate() -> void:
	if detonated: return
	detonated = true
	SoundManager.play_event("explosion")
	sprite.hide()
	blast.show()
	flame_burst.show()
	blast_material.set_shader_parameter("detonated",true)
	blast_material.set_shader_parameter("progress",0.0)
	var config := SpicyExplosionSettings.new()
	config.color = settings.color
	config.core_color = settings.mine_core_color
	config.area_y_ratio = settings.area_y_ratio
	config.ember_count = settings.mine_ember_count
	config.ember_duration = settings.mine_ember_duration
	config.ember_travel = settings.mine_ember_travel
	config.ember_size = settings.mine_ember_size
	config.opacity = 0.95
	var sparks = load("res://effects/habanero_embers.gd").new()
	get_tree().current_scene.add_child(sparks)
	sparks.global_position = global_position
	sparks.setup(config,radius)

func update_visual(time: float, exploded: bool, blast_time: float) -> void:
	elapsed = time
	if exploded:
		if not detonated: detonate()
		var progress := clampf(blast_time/maxf(0.01,settings.wave_duration),0,1)
		blast_material.set_shader_parameter("progress",progress)
		flame_material.set_shader_parameter("elapsed",blast_time)
		flame_material.set_shader_parameter("fade",1.0-smoothstep(0.2,1.0,progress))
		for index in flame_seeds.size():
			var seed := flame_seeds[index]
			var expansion := 0.2+0.8*(1.0-pow(1.0-progress,3.0))
			var point := Vector2(cos(seed.x),sin(seed.x)*settings.area_y_ratio)*radius*seed.y*expansion
			var height := radius*seed.z*(0.7+0.3*sin(progress*PI))
			flame_burst.multimesh.set_instance_transform_2d(index,Transform2D(0.0,Vector2(height*0.65,height),0.0,point))
			flame_burst.multimesh.set_instance_color(index,Color.WHITE)
		return
	# Anchored at the cut edge: squash/stretch never lifts the buried half out.
	var pulse := sin(elapsed*settings.mine_squash_speed+phase)*settings.mine_squash_strength
	sprite.scale = Vector2(1.0+pulse,1.0-pulse)*base_scale
