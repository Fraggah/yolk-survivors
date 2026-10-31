extends Node
## Reusable fire state for enemies and players. Sources refresh independently.
var hit: HitboxComponent
var remaining := 0.0
var tick_left := 0.0
var interval := 0.5
var elapsed := 0.0
var base_interval := 0.5
var damage_credit := 0.0
var tint := Color.ORANGE
var contributions: Dictionary = {}
var last_update_clock := 0.0
var next_update_clock := INF
var scheduled := false
static var prepared_frame := -1
static var prepared_profiles: Dictionary = {}
static var bound_stats: Dictionary = {}

static func _invalidate_prepared() -> void:
	prepared_profiles.clear()

static func apply(enemy: Unit, key: String, template: HitboxComponent, settings: StatusEffect, damage_scaled: bool = false) -> void:
	var started := Time.get_ticks_usec() if FireContacts.profile_enabled else 0
	_apply_fire_impl(enemy,key,template,settings,damage_scaled)
	FireContacts.finish_profile("burn_apply",started)

static func _apply_fire_impl(enemy: Unit, key: String, template: HitboxComponent, settings: StatusEffect, damage_scaled: bool) -> void:
	if enemy.status_immune or settings.duration <= 0.0: return
	var was_burning := enemy.has_status(Unit.State.BURNING)
	if enemy is Enemy and FireContacts.prevent_burning_reapplication and was_burning: return
	var source_stats: UnitStats = template.source.stats if is_instance_valid(template.source) and template.source is Unit else null
	var prepared: Dictionary = _prepare_fire(template,settings,source_stats,damage_scaled)
	var duration: float = prepared.duration
	if duration <= 0.0: return
	var burn = enemy.get_node_or_null(NodePath(key))
	if is_instance_valid(burn) and burn.scheduled: burn.sync_clock()
	if enemy.health_component.current_health<=0.0 or enemy.is_queued_for_deletion(): return
	if burn and burn.is_queued_for_deletion():
		burn.name = key + "_Expired_%s" % burn.get_instance_id()
		burn = null
	if not burn:
		burn = load("res://effects/fire_status.gd").new()
		burn.name = key
		burn.last_update_clock = FireContacts.clock
		enemy.add_child(burn)
		burn.hit = HitboxComponent.new()
		burn.hit.collision_layer = 0
		burn.hit.collision_mask = 0
		burn.hit.monitoring = false
		# Logical damage packet: no shape or overlap monitoring is used by burns.
		# Keep it outside the physics world and release it with the burn.
		burn.tick_left = (source_stats.get_fire_interval() if source_stats else StatusEffect.BASE_FIRE_INTERVAL) * FireContacts.burn_tick_batch
	# Refresh the duration, without restarting the tick timer or duplicating the burn.
	burn.remaining = duration
	burn.base_interval = source_stats.get_fire_interval() if source_stats else StatusEffect.BASE_FIRE_INTERVAL
	burn.interval = burn.base_interval * FireContacts.burn_tick_batch
	burn.tint = settings.color
	var tick_damage: float = prepared.damage
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
	if not prepared.contributions.is_empty():
		for entry in prepared.contributions:
			var pending: float = burn.contributions.get(entry.id, {}).get("pending", 0.0)
			burn.contributions[entry.id] = entry.values.duplicate()
			burn.contributions[entry.id]["pending"] = pending
		burn._refresh_contributions()
	if FireContacts.scheduled_burns:
		if not burn.scheduled:
			burn.scheduled = true
			burn.set_process(false)
			FireContacts.burns.append(weakref(burn))
		burn.schedule_next()
	enemy.status_controller.register_burning(burn)
	load("res://effects/fire_visual.gd").attach(enemy,burn,settings.fire_visuals,settings.color)
	if not was_burning and burn.remaining > 0.0:
		SoundManager.play_event("burning_apply")
		load("res://effects/fire_spread.gd").on_burning_started(enemy, key, template, settings, damage_scaled)

static func _prepare_fire(template: HitboxComponent, settings: StatusEffect, source_stats: UnitStats, damage_scaled: bool) -> Dictionary:
	var cached: bool = FireContacts.cache_status_profiles
	if cached and source_stats and not bound_stats.has(source_stats.get_instance_id()):
		source_stats.stats_changed.connect(_invalidate_prepared)
		bound_stats[source_stats.get_instance_id()] = weakref(source_stats)
		if bound_stats.size()>64:
			for id in bound_stats.keys():
				if not is_instance_valid(bound_stats[id].get_ref()): bound_stats.erase(id)
	if prepared_frame!=Engine.get_process_frames():
		prepared_frame = Engine.get_process_frames()
		prepared_profiles.clear()
	var source_id: int = template.source.get_instance_id() if is_instance_valid(template.source) else 0
	var key := PackedInt64Array([source_id,settings.get_instance_id(),int(template.weapon_damage_record.get("instance_id",0)),int(damage_scaled)])
	if cached and prepared_profiles.has(key): return prepared_profiles[key]
	var player_fire := template.source is Player and source_stats!=null
	var damage: float = source_stats.get_burning_damage() if player_fire else maxf(0.0,source_stats.get_effect_damage(settings.damage,settings.damage_scaling)*source_stats.get_damage_percent_multiplier() if source_stats and not damage_scaled else settings.damage)
	if player_fire:
		if settings.configured_fire_damage:
			damage = maxf(0.1,source_stats.get_effect_damage(settings.damage,settings.damage_scaling))*ItemWeapon.status_damage_multiplier(template.weapon_damage_record,source_stats)
		else: damage = _native_breading_damage(damage,template.weapon_damage_record,source_stats)
	var entries: Array = []
	if settings.has_meta("fire_contributions"):
		var multiplier := source_stats.get_damage_percent_multiplier() if source_stats and not damage_scaled else 1.0
		for entry in settings.get_meta("fire_contributions"):
			entries.append({"id":entry.id,"values":{"record":entry.record,"damage":_native_breading_damage(source_stats.get_burning_damage(),entry.record,source_stats) if player_fire else entry.damage*multiplier,"remaining":source_stats.get_fire_duration(entry.duration) if source_stats else entry.duration}})
	var result := {"duration":source_stats.get_fire_duration(settings.duration) if source_stats else settings.duration,"damage":damage,"contributions":entries}
	if cached: prepared_profiles[key] = result
	return result

func _ready() -> void:
	add_to_group("projectiles")

func _exit_tree() -> void:
	if is_instance_valid(hit): hit.free()

func _process(delta: float) -> void:
	var started := Time.get_ticks_usec() if FireContacts.profile_enabled else 0
	_advance_fire(delta)
	FireContacts.finish_profile("burn_ticks",started)
	last_update_clock = FireContacts.clock
	if scheduled: schedule_next()

func sync_clock() -> void:
	var delta := maxf(0.0,FireContacts.clock-last_update_clock)
	last_update_clock = FireContacts.clock
	_advance_fire(delta)
	schedule_next()

func schedule_next() -> void:
	var delay := minf(tick_left,remaining)
	for entry in contributions.values(): delay = minf(delay,float(entry.remaining))
	next_update_clock = FireContacts.clock+maxf(0.00001,delay)

func _advance_fire(delta: float) -> void:
	if Global.game_paused: return
	var enemy := get_parent() as Unit
	if not is_instance_valid(enemy) or (enemy is Enemy and enemy.is_retiring) or enemy.health_component.current_health <= 0.0:
		queue_free()
		return
	if not contributions.is_empty():
		_process_contributions(delta, enemy)
		return
	var active_delta := minf(delta, maxf(0.0, remaining))
	var ticks := _original_ticks(active_delta)
	damage_credit += ticks * hit.damage
	remaining -= delta
	tick_left -= active_delta
	elapsed += active_delta
	if tick_left <= 0.00001 or remaining <= 0.000001:
		while tick_left <= 0.00001: tick_left += interval
		if damage_credit > 0.0:
			var original_damage := hit.damage
			hit.damage = damage_credit
			hit.base_damage = damage_credit
			damage_credit = 0.0
			enemy.receive_hit(hit)
			hit.damage = original_damage
			hit.base_damage = original_damage
	if remaining <= 0.000001:
		queue_free()
		enemy.status_controller.sync_burning_enemy()

## Count original discrete ticks, so an odd final tick is delivered at expiration.
func _original_ticks(step: float) -> int:
	return maxi(0, int(floor((elapsed + step + 0.000001) / base_interval)) - int(floor((elapsed + 0.000001) / base_interval)))


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
	var left := minf(delta, remaining)
	while left > 0.000001 and not contributions.is_empty():
		var step := minf(left, maxf(0.0, tick_left))
		for entry in contributions.values(): step = minf(step, maxf(0.0, entry.remaining))
		var ticks := _original_ticks(step)
		left -= step
		elapsed += step
		tick_left -= step
		for entry in contributions.values():
			entry.pending = float(entry.get("pending", 0.0)) + ticks * entry.damage
			entry.remaining -= step
		remaining = maxf(0.0, remaining - step)
		var due := tick_left <= 0.00001
		if due: tick_left += interval
		# Expiring contributions flush their own remaining damage without advancing others.
		_emit_pending_contributions(enemy, due)
		var expired := false
		for id in contributions.keys():
			if contributions[id].remaining <= 0.000001:
				contributions.erase(id)
				expired = true
		if expired: _refresh_contributions()
		if enemy.is_queued_for_deletion() or enemy.health_component.current_health <= 0.0: break
	if contributions.is_empty():
		queue_free()
		enemy.status_controller.sync_burning_enemy()

func _emit_pending_contributions(enemy: Unit, all_due: bool) -> void:
	var total := 0.0
	var shares: Array[Dictionary] = []
	for entry in contributions.values():
		if not all_due and entry.remaining > 0.000001: continue
		var pending: float = entry.get("pending", 0.0)
		if pending <= 0.0: continue
		total += pending
		shares.append({"record": entry.record, "weight": pending})
		entry.pending = 0.0
	if total <= 0.0: return
	for share in shares: share.weight /= total
	var original_damage := hit.damage
	var original_record := hit.weapon_damage_record
	hit.damage = total
	hit.base_damage = total
	hit.weapon_damage_record = {"wave_damage": 0.0, "total_damage": 0.0, "contributors": shares}
	if not enemy.is_queued_for_deletion() and enemy.health_component.current_health > 0.0: enemy.receive_hit(hit)
	hit.damage = original_damage
	hit.base_damage = original_damage
	hit.weapon_damage_record = original_record

static func _native_breading_damage(base_damage: float, record: Dictionary, stats: UnitStats) -> float:
	var item = record.get("weapon")
	if item is ItemWeapon and item.stats.spicy_pattern and item.stats.spicy_pattern.mode == SpicyPatternSettings.Mode.TRAIL:
		return item.get_effective_damage(stats)
	return base_damage * stats.get_damage_percent_multiplier(item.has_tag(ItemWeapon.Tag.CHILI) if item is ItemWeapon else false, item.has_tag(ItemWeapon.Tag.EXPLOSIVE) if item is ItemWeapon else false)
