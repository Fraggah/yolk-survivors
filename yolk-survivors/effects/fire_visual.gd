extends Node2D
## A single visual per burning unit, independently of the number of damage sources.
var sources: Dictionary = {}
var target: Unit
var settings: Resource
var fire_material: ShaderMaterial
var surface: ColorRect
var elapsed := 0.0
var fade := 1.0
var flames: MultiMeshInstance2D
var flame_material: ShaderMaterial
var background_flame: MultiMeshInstance2D
var background_material: ShaderMaterial
var layout_extent := Vector2.ZERO
var layout_count := -1

static func attach(unit: Unit, burn: Node, config: Resource, tint: Color) -> void:
	var visual = unit.get_node_or_null("FireVisual")
	if visual and visual.is_queued_for_deletion():
		visual.name = "ExpiredFireVisual_%s" % visual.get_instance_id()
		visual = null
	if not visual:
		visual = load("res://effects/fire_visual.gd").new()
		visual.name = "FireVisual"
		visual.target = unit
		unit.add_child(visual)
	visual.settings = config if config else load("res://resources/statuses/fire_visual_default.tres")
	visual.sources[burn.get_instance_id()] = weakref(burn)
	visual.fire_material.set_shader_parameter("heat_color",tint)
	for property in ["flicker_speed","core_color","ember_count","ember_size","ember_opacity","heat_opacity"]:
		visual.fire_material.set_shader_parameter(property,visual.settings.get(property))
	for property in ["size_pulse","flicker_speed","distortion_strength","distortion_frequency","distortion_speed"]:
		visual.flame_material.set_shader_parameter(property,visual.settings.get(property))
		visual.background_material.set_shader_parameter(property,visual.settings.get(property))
	visual.flame_material.set_shader_parameter("opacity",visual.settings.flame_opacity)
	visual.background_material.set_shader_parameter("opacity",visual.settings.background_flame_opacity)
	visual.background_material.set_shader_parameter("size_pulse",visual.settings.size_pulse*0.5)
	visual.layout_count = -1

func _ready() -> void:
	# Stay inside the owner draw group.
	global_scale = Vector2.ONE
	add_to_group("projectiles")
	z_as_relative = true
	z_index = 0
	surface = ColorRect.new()
	surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fire_material = ShaderMaterial.new()
	fire_material.shader = preload("res://shaders/burning_unit.gdshader")
	fire_material.set_shader_parameter("variation",float(get_instance_id()%997)*0.13)
	surface.material = fire_material
	add_child(surface)
	flames = MultiMeshInstance2D.new()
	flames.multimesh = MultiMesh.new()
	flames.multimesh.transform_format = MultiMesh.TRANSFORM_2D
	flames.multimesh.use_colors = true
	flames.multimesh.use_custom_data = true
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE
	quad.center_offset = Vector3(0,-0.5,0)
	flames.multimesh.mesh = quad
	flame_material = ShaderMaterial.new()
	flame_material.shader = preload("res://shaders/burning_flame_sprite.gdshader")
	flames.material = flame_material
	flames.z_as_relative = true
	flames.z_index = 0
	# Inherit the animated sprite transform directly, including hop, tilt and squash.
	target.sprite.add_child(flames)
	background_flame = MultiMeshInstance2D.new()
	background_flame.multimesh = MultiMesh.new()
	background_flame.multimesh.transform_format = MultiMesh.TRANSFORM_2D
	background_flame.multimesh.use_colors = true
	background_flame.multimesh.use_custom_data = true
	background_flame.multimesh.mesh = quad
	background_flame.multimesh.instance_count = 1
	background_material = ShaderMaterial.new()
	background_material.shader = flame_material.shader
	background_flame.material = background_material
	background_flame.z_as_relative = true
	background_flame.z_index = 0
	target.sprite.add_child(background_flame)
	target.sprite.move_child(background_flame, flames.get_index())
	tree_exiting.connect(_remove_flames)

func _process(delta: float) -> void:
	if Global.game_paused or not settings: return
	if not is_instance_valid(target) or target.is_queued_for_deletion() or target.health_component.current_health <= 0 or (target is Enemy and target.is_retiring):
		queue_free()
		return
	for key in sources.keys():
		var burn = sources[key].get_ref()
		if not is_instance_valid(burn) or burn.is_queued_for_deletion() or burn.remaining <= 0:
			sources.erase(key)
	if sources.is_empty():
		fade = maxf(0.0,fade-delta/maxf(0.01,settings.fade_duration))
		if fade <= 0:
			queue_free()
			return
	else:
		fade = minf(1.0,fade+delta*10.0)
	elapsed += delta
	var rect := target.sprite.get_rect()
	var sprite_extent := rect.size * target.sprite.global_scale.abs()
	var extent: Vector2 = Vector2(maxf(12.0,sprite_extent.x*1.65),maxf(20.0,sprite_extent.y*1.7))*settings.coverage
	global_rotation = 0.0
	global_scale = Vector2.ONE
	global_position = target.sprite.to_global(Vector2(rect.get_center().x,rect.end.y))
	surface.position = Vector2(-extent.x*0.5,-extent.y*0.82)
	surface.size = extent
	fire_material.set_shader_parameter("elapsed",elapsed)
	fire_material.set_shader_parameter("fade",fade)
	flames.position = Vector2(rect.get_center().x,rect.end.y)
	background_flame.position = flames.position
	if layout_count != settings.flame_count or not layout_extent.is_equal_approx(rect.size):
		_build_flames(rect.size)
	flame_material.set_shader_parameter("elapsed",elapsed)
	flame_material.set_shader_parameter("fade",fade)
	background_material.set_shader_parameter("elapsed",elapsed)
	background_material.set_shader_parameter("fade",fade)

func _build_flames(sprite_extent: Vector2) -> void:
	layout_count = settings.flame_count
	layout_extent = sprite_extent
	var texture: Texture2D = settings.flame_texture
	if not texture: texture = load("res://assets/sprites/Effects/small_fire.png")
	flame_material.set_shader_parameter("flame_texture",texture)
	background_material.set_shader_parameter("flame_texture",texture)
	var background_size := Vector2(sprite_extent.x*settings.background_flame_width,sprite_extent.y*settings.background_flame_height)
	background_flame.multimesh.set_instance_transform_2d(0,Transform2D(0.0,background_size,0.0,Vector2.ZERO))
	background_flame.multimesh.set_instance_color(0,Color.WHITE)
	background_flame.multimesh.set_instance_custom_data(0,Color(1.7,0.75,1.1,0))
	flames.multimesh.instance_count = layout_count
	flames.multimesh.visible_instance_count = layout_count
	var rng := RandomNumberGenerator.new()
	rng.seed = get_instance_id()
	var lower_count := roundi(layout_count * settings.lower_body_fraction)
	for i in layout_count:
		var anchor_height := rng.randf_range(-0.35,-0.02) if i < lower_count else rng.randf_range(-0.85,-0.5)
		var anchor := Vector2(rng.randf_range(-0.42,0.42)*sprite_extent.x,anchor_height*sprite_extent.y)
		var height: float = sprite_extent.y*settings.flame_sprite_height*rng.randf_range(0.65,1.25)
		var size := Vector2(height*texture.get_width()/texture.get_height(),height)
		flames.multimesh.set_instance_transform_2d(i,Transform2D(0.0,size,0.0,anchor))
		flames.multimesh.set_instance_color(i,Color(1,1,1,rng.randf_range(0.95,1.0)))
		var flip_period := rng.randf_range(settings.flip_interval_min,maxf(settings.flip_interval_min,settings.flip_interval_max))
		flames.multimesh.set_instance_custom_data(i,Color(rng.randf()*TAU,rng.randf_range(0.65,1.6),flip_period,0))

func _remove_flames() -> void:
	if is_instance_valid(flames): flames.queue_free()
	if is_instance_valid(background_flame): background_flame.queue_free()
