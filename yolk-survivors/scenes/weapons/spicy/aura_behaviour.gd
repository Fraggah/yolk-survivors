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
	aura.hide()
	surface = ColorRect.new()
	surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aura.add_child(surface)
	aura_material = ShaderMaterial.new()
	aura_material.shader = preload("res://shaders/spicy_aura.gdshader")
	surface.material = aura_material

func _process(delta: float) -> void:
	if not weapon.data or not is_instance_valid(weapon.get_parent()): return
	aura.visible = aura_contributors()[0] == weapon
	if not aura.visible: return
	aura.global_position = weapon.get_parent().global_position
	if Global.game_paused: return
	elapsed += delta
	var settings := weapon.data.stats.aura_settings
	var extent := Vector2.ZERO
	var contributors := aura_contributors()
	for equipped in contributors:
		var reach: float = equipped.get_effective_range() * Global.GAME_ENTITY_SCALE * weapon.get_parent().stats.get_area_radius_multiplier()
		extent.x = maxf(extent.x, reach)
		extent.y = maxf(extent.y, reach * equipped.data.stats.aura_settings.area_y_ratio)
	var coverage := PackedVector2Array()
	coverage.resize(6)
	for index in mini(6, contributors.size()):
		var equipped := contributors[index]
		var reach: float = equipped.get_effective_range() * Global.GAME_ENTITY_SCALE * weapon.get_parent().stats.get_area_radius_multiplier()
		coverage[index] = Vector2(reach / extent.x, reach * equipped.data.stats.aura_settings.area_y_ratio / extent.y)
	aura_material.set_shader_parameter("coverage_count", mini(6, contributors.size()))
	aura_material.set_shader_parameter("coverage_extents", coverage)
	surface.position = -extent
	surface.size = extent * 2.0
	aura_material.set_shader_parameter("elapsed", elapsed)
	aura_material.set_shader_parameter("heat_color", settings.color)
	aura_material.set_shader_parameter("opacity", settings.opacity)
	aura_material.set_shader_parameter("breathing_speed", settings.breathing_speed)
	aura_material.set_shader_parameter("breathing_strength", settings.breathing_strength)
	for property in ["orbit_particle_count", "orbit_speed", "orbit_particle_size", "orbit_opacity", "ring_opacity", "ember_color", "central_particle_count", "central_particle_size", "central_travel", "central_lifetime", "central_opacity"]:
		aura_material.set_shader_parameter(property, settings.get(property))

func can_execute_attack() -> bool:
	return aura_contributors()[0] == weapon

func execute_attack() -> void:
	if Global.game_paused or not can_execute_attack(): return
	var source := weapon.get_parent() as Player
	if not is_instance_valid(source): return
	var hit := HitboxComponent.new()
	hit.setup(0.0, false, weapon.data.stats.knockback, source)
	configure_hit_criticals(hit)
	hit.life_steal_chance = get_life_steal_chance()
	var contributors := aura_contributors()
	for enemy in get_tree().get_nodes_in_group("combat_enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.is_retiring or enemy.health_component.current_health <= 0.0: continue
		var shares: Array[Dictionary] = []
		var total := 0.0
		for equipped in contributors:
			var offset: Vector2 = enemy.global_position - source.global_position
			offset.y /= equipped.data.stats.aura_settings.area_y_ratio
			var reach: float = equipped.get_effective_range() * Global.GAME_ENTITY_SCALE * source.stats.get_area_radius_multiplier()
			if offset.length_squared() > reach * reach: continue
			var amount := equipped.data.get_effective_damage(source.stats)
			total += amount
			shares.append({"record": equipped.damage_record, "weight": amount})
		if shares.is_empty(): continue
		for share in shares: share.weight /= maxf(0.00001, total)
		hit.base_damage = total
		hit.damage = total
		hit.weapon_damage_record = {"wave_damage": 0.0, "total_damage": 0.0, "contributors": shares}
		enemy._on_hurtbox_component_on_damage(hit)
	hit.free()

func reset_attack() -> void:
	super.reset_attack()
	elapsed = 0.0

func aura_contributors() -> Array[Weapon]:
	var result: Array[Weapon] = []
	var player := weapon.get_parent() as Player
	if is_instance_valid(player):
		for equipped in player.current_weapons:
			if not is_instance_valid(equipped) or equipped.is_queued_for_deletion(): continue
			if equipped.data.scene == weapon.data.scene and equipped.data.stats.aura_settings:
				result.append(equipped)
	if not result.has(weapon): result.append(weapon)
	return result

