extends RefCounted
## Shared aura/trail records retain each contributing weapon's own effects.

static func on_damage(hit: HitboxComponent, target: Unit, dealt: float) -> void:
	if hit.breading_suppressed or not target is Enemy or not hit.source is Player: return
	_process_record(hit, target, dealt, hit.weapon_damage_record, 1.0)

static func _process_record(hit: HitboxComponent, target: Enemy, dealt: float, record: Dictionary, weight: float) -> void:
	if record.is_empty(): return
	if record.has("contributors"):
		for share in record.contributors: _process_record(hit, target, dealt, share.record, weight * share.weight)
		return
	var item = record.get("weapon")
	if not item is ItemWeapon or item.breading_tags.is_empty(): return
	if hit.is_status_damage:
		# Native Cayena damage consists of fire ticks, rather than direct impacts.
		if not item.stats.spicy_pattern or item.stats.spicy_pattern.mode != SpicyPatternSettings.Mode.TRAIL: return
	_apply(item, hit, target, dealt * weight, record)

static func _apply(item: ItemWeapon, original: HitboxComponent, target: Enemy, amount: float, record: Dictionary) -> void:
	if item.breading_explosion_radius <= 0.0 and item.breading_slow_strength <= 0.0 and item.breading_status_effects.is_empty(): return
	var template := HitboxComponent.new()
	template.setup(amount, false, 0.0, original.source)
	template.status_effects.clear()
	template.weapon_damage_record = record
	template.breading_suppressed = true
	template.explosive_bonus_applied = original.explosive_bonus_applied
	template.life_steal_chance = original.life_steal_chance
	if item.breading_explosion_radius > 0.0:
		var config := RangedSettings.new()
		config.explosion_radius = item.breading_explosion_radius
		config.explosion_damage_multiplier = item.breading_explosion_damage_ratio
		config.explosion_color = Color("ed9d40")
		config.explosion_visual_duration = 0.16
		var blast = load("res://scenes/projectiles/ranged_area_effect.gd").new()
		target.get_tree().current_scene.add_child(blast)
		blast.global_position = target.global_position
		blast.setup(template, config, false)
	if target.health_component.current_health > 0.0 and not target.is_queued_for_deletion():
		if item.breading_slow_strength > 0.0:
			var stats: UnitStats = original.source.stats
			target.status_controller.add_slow(stats.effective_slow(1.0 - item.breading_slow_strength), item.breading_slow_duration * stats.get_crowd_control_multiplier())
		for effect in item.breading_status_effects:
			if Global.get_chance_succes(effect.chance):
				load("res://effects/status_controller.gd").apply_effect(target, effect, template)
	template.free()
