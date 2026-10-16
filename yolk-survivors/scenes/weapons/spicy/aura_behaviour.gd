extends WeaponBehaviour

var aura: Node2D
var surface: ColorRect
var aura_material: ShaderMaterial
var elapsed := 0.0

func _ready() -> void:
	aura = Node2D.new()
	add_child(aura)
	aura.set_as_top_level(true)
	aura.z_index = -1
	surface = ColorRect.new()
	surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aura.add_child(surface)
	aura_material = ShaderMaterial.new()
	aura_material.shader = preload("res://shaders/spicy_aura.gdshader")
	surface.material = aura_material

func _process(delta: float) -> void:
	if not weapon.data or not is_instance_valid(weapon.get_parent()): return
	aura.global_position = weapon.get_parent().global_position
	if Global.game_paused: return
	elapsed += delta
	var settings := weapon.data.stats.aura_settings
	var radius: float = weapon.data.stats.max_range * Global.GAME_ENTITY_SCALE * weapon.get_parent().stats.get_area_radius_multiplier()
	var extent := Vector2(radius, radius * settings.area_y_ratio)
	surface.position = -extent
	surface.size = extent * 2.0
	aura_material.set_shader_parameter("elapsed", elapsed)
	aura_material.set_shader_parameter("heat_color", settings.color)
	aura_material.set_shader_parameter("opacity", settings.opacity)
	aura_material.set_shader_parameter("breathing_speed", settings.breathing_speed)
	aura_material.set_shader_parameter("breathing_strength", settings.breathing_strength)

func execute_attack() -> void:
	var source := weapon.get_parent() as Player
	if not is_instance_valid(source): return
	var settings := weapon.data.stats.aura_settings
	var radius: float = weapon.data.stats.max_range * Global.GAME_ENTITY_SCALE * weapon.get_parent().stats.get_area_radius_multiplier()
	var hit := HitboxComponent.new()
	hit.setup(get_base_damage(), false, weapon.data.stats.knockback, source)
	configure_hit_criticals(hit)
	hit.life_steal_chance = get_life_steal_chance()
	hit.weapon_damage_record = weapon.damage_record
	for enemy in get_tree().get_nodes_in_group("combat_enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.is_retiring or enemy.health_component.current_health <= 0.0: continue
		var offset: Vector2 = enemy.global_position - source.global_position
		offset.y /= settings.area_y_ratio
		if offset.length_squared() <= radius * radius:
			enemy._on_hurtbox_component_on_damage(hit)
	hit.free()

func reset_attack() -> void:
	super.reset_attack()
	elapsed = 0.0
