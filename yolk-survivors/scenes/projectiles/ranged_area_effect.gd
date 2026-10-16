extends Node2D

var hit: HitboxComponent
var settings: RangedSettings
var is_pit := false
var elapsed := 0.0
var lifetime := 0.2
var radius := 70.0
var next_hit := 0.0
var texture: Texture2D

func _ready() -> void:
	add_to_group("projectiles")

func setup(template: HitboxComponent, config: RangedSettings, pit: bool) -> void:
	settings = config
	is_pit = pit
	lifetime = settings.pit_duration if pit else settings.explosion_visual_duration
	radius = (settings.pit_radius if pit else settings.explosion_radius) * Global.GAME_ENTITY_SCALE
	if template.source is Unit: radius *= template.source.stats.get_area_radius_multiplier()
	texture = settings.pit_texture if pit else settings.explosion_texture
	hit = HitboxComponent.new()
	hit.collision_layer = 0
	hit.collision_mask = 0
	hit.monitoring = false
	hit.setup(template.base_damage * (settings.pit_damage_multiplier if pit else settings.explosion_damage_multiplier), false, template.knockback_power, template.source)
	hit.roll_critical_per_target = template.roll_critical_per_target
	hit.critical_chance = template.critical_chance
	hit.critical_multiplier = template.critical_multiplier
	hit.life_steal_chance = template.life_steal_chance
	hit.status_effects.assign(template.status_effects)
	hit.weapon_damage_record = template.weapon_damage_record
	add_child(hit)
	z_index = 2
	if not pit: _damage_enemies()
	queue_redraw()

func _process(delta: float) -> void:
	if Global.game_paused or not settings: return
	elapsed += delta
	if elapsed >= lifetime:
		queue_free()
		return
	if is_pit:
		next_hit -= delta
		if next_hit <= 0.0:
			next_hit = settings.pit_hit_interval
			_damage_enemies()
	queue_redraw()

func _damage_enemies() -> void:
	if not is_instance_valid(hit.source): return
	for enemy in get_tree().get_nodes_in_group("combat_enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.is_retiring or enemy.health_component.current_health <= 0.0: continue
		var offset: Vector2 = enemy.global_position - global_position
		offset.y /= settings.area_y_ratio
		if offset.length_squared() <= radius * radius:
			enemy._on_hurtbox_component_on_damage(hit)

func _draw() -> void:
	if not settings: return
	var progress := clampf(elapsed / lifetime, 0.0, 1.0)
	if is_pit and texture:
		draw_texture_rect(texture, Rect2(-Vector2(20, 14), Vector2(40, 28)), false, Color(1, 1, 1, minf(1.0, (1.0 - progress) * 5.0)))
		return
	var color := settings.explosion_color
	color.a = (1.0 - progress) * 0.65
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, settings.area_y_ratio))
	draw_circle(Vector2.ZERO, radius * (0.6 + progress * 0.4), color)
	draw_arc(Vector2.ZERO, radius * (0.6 + progress * 0.4), 0.0, TAU, 40, Color(color, color.a * 0.8), 3.0, true)
	draw_set_transform(Vector2.ZERO)
	if texture:
		var size := Vector2.ONE * radius * (0.8 + progress * 0.5)
		draw_texture_rect(texture, Rect2(-size * 0.5, size), false, Color(1, 1, 1, 1.0 - progress))
