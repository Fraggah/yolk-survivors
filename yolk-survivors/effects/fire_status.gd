extends Node2D
## Reusable fire state for enemies and players. Sources refresh independently.
var hit: HitboxComponent
var remaining := 0.0
var tick_left := 0.0
var interval := 0.5
var elapsed := 0.0
var tint := Color.ORANGE
var contributions: Dictionary = {}

static func apply(enemy: Unit, key: String, template: HitboxComponent, settings: StatusEffect, damage_scaled: bool = false) -> void:
	if enemy.status_immune or settings.duration <= 0.0: return
	var was_burning := enemy.has_status(Unit.State.BURNING)
	var source_stats: UnitStats = template.source.stats if is_instance_valid(template.source) and template.source is Unit else null
	var duration: float = source_stats.get_fire_duration(settings.duration) if source_stats else settings.duration
	if duration <= 0.0: return
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
		burn.tick_left = source_stats.get_fire_interval() if source_stats else StatusEffect.BASE_FIRE_INTERVAL
	# Refresh the duration, without restarting the tick timer or duplicating the burn.
	burn.remaining = duration
	burn.interval = source_stats.get_fire_interval() if source_stats else StatusEffect.BASE_FIRE_INTERVAL
	burn.tint = settings.color
	var player_fire := template.source is Player and source_stats != null
	var tick_damage: float = source_stats.get_burning_damage() if player_fire else maxf(0.0, source_stats.get_effect_damage(settings.damage, settings.damage_scaling) * source_stats.get_damage_percent_multiplier() if source_stats and not damage_scaled else settings.damage)
	if player_fire:
		if settings.configured_fire_damage:
			tick_damage = maxf(0.1, source_stats.get_effect_damage(settings.damage, settings.damage_scaling)) * ItemWeapon.status_damage_multiplier(template.weapon_damage_record, source_stats)
		else:
			tick_damage = _native_breading_damage(tick_damage, template.weapon_damage_record, source_stats)
	burn.hit.setup(tick_damage, false, 0.0, template.source)
	burn.hit.status_effects.clear()
	burn.hit.is_status_damage = true
	burn.hit.breading_suppressed = bool(settings.get_meta("breading_generated", false))
	burn.hit.can_be_blocked = false
	burn.hit.critical_allowed = false
	burn.hit.critical = false
	burn.hit.roll_critical_per_target = false
	burn.hit.critical_chance = 0.0
	burn.hit.critical_multiplier = 1.0
	burn.hit.life_steal_chance = template.life_steal_chance
	burn.hit.weapon_damage_record = settings.get_meta("damage_record",template.weapon_damage_record)
	if settings.has_meta("fire_contributions"):
		var multiplier := source_stats.get_damage_percent_multiplier() if source_stats and not damage_scaled else 1.0
		for entry in settings.get_meta("fire_contributions"):
			burn.contributions[entry.id] = {"record": entry.record, "damage": _native_breading_damage(source_stats.get_burning_damage(), entry.record, source_stats) if player_fire else entry.damage * multiplier, "remaining": source_stats.get_fire_duration(entry.duration) if source_stats else entry.duration}
		burn._refresh_contributions()
	enemy.status_controller.register_burning(burn)
	load("res://effects/fire_visual.gd").attach(enemy,burn,settings.fire_visuals,settings.color)
	if not was_burning and burn.remaining > 0.0:
		SoundManager.play_event("burning_apply")
		load("res://effects/fire_spread.gd").on_burning_started(enemy, key, template, settings, damage_scaled)

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
	if not contributions.is_empty():
		_process_contributions(delta, enemy)
		return
	var active_delta := minf(delta, maxf(0.0, remaining))
	remaining -= delta
	tick_left -= active_delta
	elapsed += active_delta
	while tick_left <= 0.00001:
		tick_left += interval
		if enemy.is_queued_for_deletion() or enemy.health_component.current_health <= 0.0: break
		enemy.receive_hit(hit)
	if remaining <= 0.0:
		queue_free()
		enemy.status_controller.sync_burning_enemy()


func _refresh_contributions() -> void:
	var total := 0.0
	remaining = 0.0
	var shares: Array[Dictionary] = []
	for entry in contributions.values():
		total += entry.damage
		remaining = maxf(remaining, entry.remaining)
		shares.append({"record": entry.record, "weight": entry.damage})
	for share in shares: share.weight /= maxf(0.00001, total)
	hit.base_damage = total
	hit.damage = total
	hit.weapon_damage_record = {"wave_damage": 0.0, "total_damage": 0.0, "contributors": shares}

func _process_contributions(delta: float, enemy: Unit) -> void:
	var left := delta
	while left > 0.000001 and not contributions.is_empty():
		var step := minf(left, maxf(0.0, tick_left))
		for entry in contributions.values(): step = minf(step, maxf(0.0, entry.remaining))
		left -= step
		elapsed += step
		tick_left -= step
		for entry in contributions.values(): entry.remaining -= step
		# A tick on an expiration boundary still belongs to the ending contribution.
		if tick_left <= 0.00001:
			tick_left += interval
			if not enemy.is_queued_for_deletion() and enemy.health_component.current_health > 0.0: enemy.receive_hit(hit)
		for id in contributions.keys():
			if contributions[id].remaining <= 0.000001: contributions.erase(id)
		_refresh_contributions()
	if contributions.is_empty():
		queue_free()
		enemy.status_controller.sync_burning_enemy()

static func _native_breading_damage(base_damage: float, record: Dictionary, stats: UnitStats) -> float:
	var item = record.get("weapon")
	if item is ItemWeapon and item.stats.spicy_pattern and item.stats.spicy_pattern.mode == SpicyPatternSettings.Mode.TRAIL:
		return item.get_effective_damage(stats)
	return base_damage * stats.get_damage_percent_multiplier(item.has_tag(ItemWeapon.Tag.CHILI) if item is ItemWeapon else false, item.has_tag(ItemWeapon.Tag.EXPLOSIVE) if item is ItemWeapon else false)
