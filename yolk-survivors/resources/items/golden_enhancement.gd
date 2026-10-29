extends RefCounted
## Explicit gameplay magnitudes: never scale identities, caps or visual timing.
const BOOST_FIELDS := ["last_bite_push_percent", "last_bite_dash_reduction", "mushroom_explosion_radius", "mushroom_effects_scaling", "mushroom_health_scaling", "mushroom_damage_bonus", "mushroom_speed_percent", "mushroom_attack_speed_bonus", "mushroom_buff_duration", "mushroom_heal_health", "damage", "damage_scaling", "effects_damage_scaling", "crit_chance", "crit_damage", "max_range", "knockback", "slow_duration", "piercing", "bounces", "life_steal", "projectile_speed", "proc_chance", "effect_radius", "heal_amount", "fire_interval_reduction", "controlled_damage_percent", "flambe_damage_per_enemy", "airbourne_collision_damage_percent", "airbourne_explosion_damage_percent", "burning_regen_bonus", "regen_per_level", "electric_slow_strength", "electric_slow_duration", "projectile_count", "burst_count", "airbourne_speed", "airbourne_duration", "explosion_radius", "harpoon_pin_duration", "harpoon_capture_radius", "landing_slow_radius", "landing_slow_duration", "corn_explosion_chance", "popcorn_speed", "popcorn_range", "bonus_yolks", "pit_projectile_speed", "pit_range_multiplier", "pit_radius", "splatter_count", "splatter_speed", "splatter_range_multiplier", "stream_width", "hit_count", "launch_speed", "launch_duration", "capture_radius", "slow_radius", "close_hit_radius", "count", "radius", "lifetime", "movement_speed", "orbit_speed", "trigger_radius", "maximum_active", "column_trail_lifetime", "explosion_count", "burn_duration", "chance", "duration", "chain_radius", "maximum_chain_targets"]
const NESTED_FIELDS := ["ranged_settings", "melee_settings", "spicy_pattern", "spicy_explosion_settings"]
const CHANCES := ["crit_chance", "life_steal", "proc_chance", "electric_slow_strength", "corn_explosion_chance", "chance"]

static func roll_outcome(roll: float = -1.0, weights := PackedFloat32Array()) -> float:
	var outcomes := [-1.0, 0.10, 0.25, 0.50, 1.0]
	if weights.size() != 5: weights = PackedFloat32Array([25, 40, 23, 10, 2])
	var total := 0.0
	for weight in weights: total += maxf(0.0, weight)
	if total <= 0.0: return -1.0
	var value := (randf() if roll < 0.0 else clampf(roll, 0.0, 0.999999)) * total
	for index in weights.size():
		value -= maxf(0.0, weights[index])
		if value < 0.0: return outcomes[index]
	return 1.0

static func improve(item: ItemBase, bonus: float, penalty_override: float = -1.0) -> ItemBase:
	var improved := item.duplicate() as ItemBase
	var factor := 1.0 + bonus
	var penalty := maxf(0.0, 1.0 - bonus) if penalty_override < 0.0 else penalty_override
	improved.golden_multiplier = item.golden_multiplier * factor
	improved.golden_penalty_multiplier = item.golden_penalty_multiplier * penalty
	improved.golden_perfect = item.golden_perfect or bonus >= 1.0
	if item is ItemWeapon:
		improved.effects_damage_scaling = item.effects_damage_scaling * factor
		improved.extra_damage_scalings = item.extra_damage_scalings.duplicate()
		for key in improved.extra_damage_scalings: improved.extra_damage_scalings[key] *= factor
		improved.breading_chili_damage_percent *= factor
		improved.breading_pet_damage_percent *= factor
		improved.breading_explosion_radius *= factor
		improved.breading_slow_strength = minf(1.0, item.breading_slow_strength * factor)
		improved.breading_slow_duration *= factor
		var breaded_statuses: Array[StatusEffect] = []
		for effect in item.breading_status_effects:
			var enhanced_status := effect.duplicate() as StatusEffect
			_scale_magnitudes(enhanced_status, factor, penalty)
			breaded_statuses.append(enhanced_status)
		improved.breading_status_effects = breaded_statuses
		improved.stats = item.stats.duplicate(true)
		_scale_magnitudes(improved.stats, factor, penalty)
		improved.stats.cooldown = maxf(0.05, item.stats.cooldown / factor)
		improved.health_drain_per_second *= penalty
		improved.max_health_drain_percent_per_second *= penalty
		improved.final_stat_modifiers = item.final_stat_modifiers.duplicate()
		for key in improved.final_stat_modifiers:
			var amount := float(improved.final_stat_modifiers[key])
			improved.final_stat_modifiers[key] = amount * (factor if amount > 0.0 else penalty)
	elif item is ItemPassive:
		_scale_magnitudes(improved, factor, penalty)
		for index in range(1, ItemPassive.STAT_SLOT_COUNT + 1):
			var field := "add_value" + ("" if index == 1 else "_%d" % index)
			var value: float = item.get(field)
			improved.set(field, value * (factor if value >= 0.0 else penalty))
		if "catalogue_id" in item:
			improved.fire_duration_reduction = item.fire_duration_reduction * penalty
			# Liquidación retains its weights and 90% ceiling; discount bounds and 2x1 improve.
			improved.two_for_one_chance = minf(1.0, item.two_for_one_chance * factor)
			improved.minimum_discount_percent = mini(90, floori(item.minimum_discount_percent * factor))
			improved.maximum_discount_percent = mini(90, floori(item.maximum_discount_percent * factor))
	var statuses: Array[StatusEffect] = []
	for effect in item.on_hit_effects:
		var enhanced := effect.duplicate() as StatusEffect
		_scale_magnitudes(enhanced, factor, penalty)
		statuses.append(enhanced)
	improved.on_hit_effects = statuses
	return improved

static func _scale_magnitudes(resource: Resource, factor: float, penalty: float) -> void:
	for property in resource.get_property_list():
		var key: String = property.name
		if not property.usage & PROPERTY_USAGE_STORAGE: continue
		var value = resource.get(key)
		if key in NESTED_FIELDS and value is Resource:
			var nested: Resource = value.duplicate(true)
			_scale_magnitudes(nested, factor, penalty)
			resource.set(key, nested)
		elif key in BOOST_FIELDS and (value is float or value is int):
			var scaled := float(value) * factor
			if key in CHANCES: scaled = minf(1.0, scaled)
			if value is int: resource.set(key, floori(scaled + 0.00001))
			else: resource.set(key, scaled)
		elif key == "landing_slow_factor" or key == "slow_factor":
			resource.set(key, maxf(0.0, 1.0 - (1.0 - float(value)) * factor))
		elif key in ["relaunch_speed_multiplier", "relaunch_duration_multiplier"]:
			resource.set(key, 1.0 - (1.0 - float(value)) * penalty)
		elif key == "plate_break_chance":
			resource.set(key, float(value) * penalty)
