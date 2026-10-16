extends Node2D
## Reusable fire state for enemies and players. Sources refresh independently.
var hit: HitboxComponent
var remaining := 0.0
var tick_left := 0.0
var interval := 0.5
var elapsed := 0.0
var tint := Color.ORANGE

static func apply(enemy: Unit, key: String, template: HitboxComponent, settings: StatusEffect, damage_scaled: bool = false) -> void:
	if settings.duration <= 0.0 or settings.damage <= 0.0: return
	var source_stats: UnitStats = template.source.stats if is_instance_valid(template.source) and template.source is Unit else null
	var burn = enemy.get_node_or_null(NodePath(key))
	if burn and burn.is_queued_for_deletion():
		burn.name = key + "_Expired_%s" % burn.get_instance_id()
		burn = null
	if not burn:
		burn = load("res://effects/fire_status.gd").new()
		burn.name = key
		enemy.add_child(burn)
		burn.hit = HitboxComponent.new()
		burn.hit.collision_layer = 0
		burn.hit.collision_mask = 0
		burn.hit.monitoring = false
		burn.add_child(burn.hit)
		burn.tick_left = source_stats.get_fire_interval(settings.tick_interval) if source_stats else settings.tick_interval
	# Refresh the duration, without restarting the tick timer or duplicating the burn.
	burn.remaining = settings.duration * (source_stats.effect_duration_multiplier() if source_stats else 1.0)
	burn.interval = source_stats.get_fire_interval(settings.tick_interval) if source_stats else maxf(0.05, settings.tick_interval)
	burn.tint = settings.color
	burn.hit.setup(settings.damage * (source_stats.get_effect_multiplier() * source_stats.final_multiplier("damage_percent") if source_stats and not damage_scaled else 1.0), false, 0.0, template.source)
	burn.hit.status_effects.clear()
	burn.hit.is_status_damage = true
	burn.hit.can_be_blocked = false
	burn.hit.roll_critical_per_target = template.roll_critical_per_target
	burn.hit.critical_chance = template.critical_chance
	burn.hit.critical_multiplier = template.critical_multiplier
	burn.hit.life_steal_chance = template.life_steal_chance
	burn.hit.weapon_damage_record = template.weapon_damage_record

func _ready() -> void:
	add_to_group("projectiles")
	z_as_relative = false
	z_index = 3

func _process(delta: float) -> void:
	if Global.game_paused: return
	var enemy := get_parent() as Unit
	if not is_instance_valid(enemy) or (enemy is Enemy and enemy.is_retiring) or enemy.health_component.current_health <= 0.0:
		queue_free()
		return
	var active_delta := minf(delta, maxf(0.0, remaining))
	remaining -= delta
	tick_left -= active_delta
	elapsed += active_delta
	while tick_left <= 0.00001:
		tick_left += interval
		if enemy.is_queued_for_deletion() or enemy.health_component.current_health <= 0.0: break
		enemy.receive_hit(hit)
	if remaining <= 0.0: queue_free()
	queue_redraw()

func _draw() -> void:
	for index in 3:
		var phase := fmod(elapsed * 1.7 + index * 0.33, 1.0)
		var point := Vector2((index - 1) * 9.0 + sin(elapsed * 7.0 + index) * 2.0, -10.0 - phase * 24.0)
		var size := 4.0 * (1.0 - phase) + 1.0
		var color := tint
		color.a *= 1.0 - phase
		draw_colored_polygon(PackedVector2Array([point + Vector2(-size, 0), point + Vector2(0, -size * 2.5), point + Vector2(size, 0), point + Vector2(0, size)]), color)
		draw_circle(point, size * 0.45, Color(1.0, 0.87, 0.3, color.a))
