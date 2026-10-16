extends Node2D

var settings: SpicyExplosionSettings
var hit: HitboxComponent
var radius := 0.0
var elapsed := 0.0
var detonated := false
var weapon_id := 0

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
	z_index = 1
	queue_redraw()

func _process(delta: float) -> void:
	if Global.game_paused: return
	if not is_instance_valid(hit.source):
		queue_free()
		return
	elapsed += delta
	if not detonated and elapsed >= settings.anticipation: detonate()
	if elapsed >= settings.anticipation + settings.visual_duration: queue_free()
	queue_redraw()

func detonate() -> void:
	if detonated or Global.game_paused: return
	detonated = true
	for enemy in get_tree().get_nodes_in_group("combat_enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.is_retiring or enemy.health_component.current_health <= 0.0: continue
		var offset: Vector2 = enemy.global_position - global_position
		offset.y /= settings.area_y_ratio
		if offset.length_squared() > radius * radius: continue
		enemy._on_hurtbox_component_on_damage(hit)
		if not enemy.is_queued_for_deletion() and enemy.health_component.current_health > 0.0:
			load("res://effects/spicy_burn.gd").apply(enemy, weapon_id, hit, settings)

func _draw() -> void:
	if not settings: return
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, settings.area_y_ratio))
	if not detonated:
		var anticipation_progress := clampf(elapsed / maxf(0.01, settings.anticipation), 0.0, 1.0)
		for layer in 6:
			var color := settings.color
			color.a = settings.opacity * 0.025 * anticipation_progress
			draw_circle(Vector2.ZERO, radius * (1.0 - layer * 0.12), color)
	else:
		var progress := clampf((elapsed - settings.anticipation) / settings.visual_duration, 0.0, 1.0)
		for layer in 8:
			var color := settings.color.lerp(Color(1.0, 0.93, 0.45), layer / 9.0)
			color.a = settings.opacity * (1.0 - progress) * 0.25
			draw_circle(Vector2.ZERO, radius * (0.55 + 0.45 * progress) * (1.0 - layer * 0.1), color)
		for spark in 12:
			var angle := TAU * spark / 12.0
			var point := Vector2.from_angle(angle) * radius * progress
			var color := settings.color.lerp(Color(1, 0.85, 0.3), 0.5)
			color.a = settings.opacity * (1.0 - progress)
			draw_line(point, point + Vector2.from_angle(angle) * radius * 0.12, color, 3.0, true)
