extends Node2D

var settings: SpicyExplosionSettings
var hit: HitboxComponent
var radius := 0.0
var elapsed := 0.0
var detonated := false
var weapon_id := 0
var blast_material: ShaderMaterial
var visual_seed := randf() * TAU

func configure(weapon: Weapon, point: Vector2, config: SpicyExplosionSettings, damage: float, life_steal: float) -> void:
	position = point
	settings = config
	weapon_id = weapon.get_instance_id()
	radius = settings.explosion_radius * Global.GAME_ENTITY_SCALE * weapon.get_parent().stats.get_area_radius_multiplier()
	hit = HitboxComponent.new()
	hit.collision_layer = 0
	hit.collision_mask = 0
	hit.monitoring = false
	hit.setup(damage, false, weapon.data.stats.knockback, weapon.get_parent())
	weapon.weapon_behaviour.configure_hit_criticals(hit)
	hit.life_steal_chance = life_steal
	hit.weapon_damage_record = weapon.damage_record
	add_child(hit)

func _ready() -> void:
	add_to_group("projectiles")
	z_index = 0
	var surface := ColorRect.new()
	surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var extent := Vector2(radius,radius*settings.area_y_ratio)*1.35
	surface.position = -extent
	surface.size = extent*2.0
	blast_material = ShaderMaterial.new()
	blast_material.shader = preload("res://shaders/habanero_blast.gdshader")
	surface.material = blast_material
	add_child(surface)
	blast_material.set_shader_parameter("heat_color",settings.color)
	blast_material.set_shader_parameter("core_color",settings.core_color)
	blast_material.set_shader_parameter("flame_color",settings.flame_color)
	blast_material.set_shader_parameter("opacity",settings.opacity)
	blast_material.set_shader_parameter("anticipation_opacity",settings.anticipation_opacity)
	blast_material.set_shader_parameter("flame_strength",settings.flame_strength)
	blast_material.set_shader_parameter("variation",visual_seed)

func _process(delta: float) -> void:
	if Global.game_paused: return
	if not is_instance_valid(hit.source):
		queue_free()
		return
	elapsed += delta
	if not detonated and elapsed >= settings.anticipation: detonate()
	if elapsed >= settings.anticipation + settings.visual_duration: queue_free()
	if blast_material:
		blast_material.set_shader_parameter("detonated",detonated)
		var progress := elapsed/maxf(0.001,settings.anticipation)
		if detonated: progress = (elapsed-settings.anticipation)/maxf(0.001,settings.visual_duration)
		blast_material.set_shader_parameter("progress",clampf(progress,0,1))

func detonate() -> void:
	if detonated or Global.game_paused: return
	detonated = true
	if settings.ember_count > 0:
		var embers = preload("res://effects/habanero_embers.gd").new()
		get_tree().current_scene.add_child(embers)
		embers.global_position = global_position
		embers.setup(settings,radius)
	for enemy in get_tree().get_nodes_in_group("combat_enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.is_retiring or enemy.health_component.current_health <= 0.0: continue
		var offset: Vector2 = enemy.global_position - global_position
		offset.y /= settings.area_y_ratio
		if offset.length_squared() > radius * radius: continue
		enemy._on_hurtbox_component_on_damage(hit)
		if not enemy.is_queued_for_deletion() and enemy.health_component.current_health > 0.0:
			load("res://effects/spicy_burn.gd").apply(enemy, weapon_id, hit, settings)

