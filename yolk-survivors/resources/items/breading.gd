extends RefCounted

static func available_tags(item: ItemWeapon, player: Player) -> Array[int]:
	var result: Array[int] = []
	for tag in ItemWeapon.TAG_LABELS.size():
		if item.tags.has(tag): continue
		var candidate := item.duplicate() as ItemWeapon
		candidate.tags = item.tags.duplicate()
		candidate.tags.append(tag)
		if not is_instance_valid(player) or player.stats.can_use_weapon(candidate): result.append(tag)
	return result

static func add_tag(item: ItemWeapon, tag: int, config: ItemPassive = null) -> ItemWeapon:
	if item.tags.has(tag): return item
	if config == null: config = load("res://resources/items/passives/catalogue/item_081.tres")
	var result := item.duplicate() as ItemWeapon
	# AUTO must retain its original stat after an additional Melee/Ranged tag.
	if item.damage_scaling_stat == ItemWeapon.DamageScalingStat.AUTO:
		match item.get_damage_scaling_stat_id():
			"melee_damage": result.damage_scaling_stat = ItemWeapon.DamageScalingStat.MELEE
			"ranged_damage": result.damage_scaling_stat = ItemWeapon.DamageScalingStat.RANGED
			"effects": result.damage_scaling_stat = ItemWeapon.DamageScalingStat.EFFECTS
			_: result.damage_scaling_stat = ItemWeapon.DamageScalingStat.NONE
	result.golden_multiplier = item.golden_multiplier
	result.golden_penalty_multiplier = item.golden_penalty_multiplier
	result.golden_perfect = item.golden_perfect
	result.tags = item.tags.duplicate()
	result.tags.append(tag)
	result.breading_tags = item.breading_tags.duplicate()
	result.breading_tags.append(tag)
	result.extra_damage_scalings = item.extra_damage_scalings.duplicate()
	result.breading_status_effects = item.breading_status_effects.duplicate()
	match tag:
		ItemWeapon.Tag.MELEE: result.extra_damage_scalings["melee_damage"] = config.breading_extra_scaling
		ItemWeapon.Tag.RANGED: result.extra_damage_scalings["ranged_damage"] = config.breading_extra_scaling
		ItemWeapon.Tag.CHILI: result.breading_chili_damage_percent = config.breading_chili_damage_percent
		ItemWeapon.Tag.PET: result.breading_pet_damage_percent = config.breading_pet_damage_percent
		ItemWeapon.Tag.EXPLOSIVE:
			result.breading_explosion_radius = config.breading_explosion_radius
			result.breading_explosion_damage_ratio = config.breading_explosion_damage_ratio
		ItemWeapon.Tag.CONTROL:
			result.breading_slow_strength = config.breading_slow_strength
			result.breading_slow_duration = config.breading_slow_duration
		ItemWeapon.Tag.PYRO, ItemWeapon.Tag.ELECTRIC:
			var status := StatusEffect.new() if tag == ItemWeapon.Tag.PYRO else load("res://resources/statuses/electricity_default.tres").duplicate() as StatusEffect
			status.chance = config.breading_proc_chance
			status.set_meta("breading_generated", true)
			result.breading_status_effects.append(status)
	return result

static func inherit_tags(base: ItemWeapon, donors: Array) -> ItemWeapon:
	var result := base
	for donor: ItemWeapon in donors:
		for tag in donor.breading_tags:
			if not result.tags.has(tag): result = add_tag(result, tag)
			if not result.breading_tags.has(tag): continue
			match tag:
				ItemWeapon.Tag.MELEE, ItemWeapon.Tag.RANGED:
					var key := "melee_damage" if tag == ItemWeapon.Tag.MELEE else "ranged_damage"
					result.extra_damage_scalings[key] = maxf(result.extra_damage_scalings.get(key, 0.0), donor.extra_damage_scalings.get(key, 0.0))
				ItemWeapon.Tag.CHILI: result.breading_chili_damage_percent = maxf(result.breading_chili_damage_percent, donor.breading_chili_damage_percent)
				ItemWeapon.Tag.PET: result.breading_pet_damage_percent = maxf(result.breading_pet_damage_percent, donor.breading_pet_damage_percent)
				ItemWeapon.Tag.CONTROL:
					result.breading_slow_strength = maxf(result.breading_slow_strength, donor.breading_slow_strength)
					result.breading_slow_duration = maxf(result.breading_slow_duration, donor.breading_slow_duration)
				ItemWeapon.Tag.EXPLOSIVE:
					result.breading_explosion_radius = maxf(result.breading_explosion_radius, donor.breading_explosion_radius)
					result.breading_explosion_damage_ratio = maxf(result.breading_explosion_damage_ratio, donor.breading_explosion_damage_ratio)
				ItemWeapon.Tag.PYRO, ItemWeapon.Tag.ELECTRIC:
					var kind := StatusEffect.Kind.FIRE if tag == ItemWeapon.Tag.PYRO else StatusEffect.Kind.ELECTRICITY
					for effect in donor.breading_status_effects:
						if effect.kind != kind: continue
						for index in result.breading_status_effects.size():
							if result.breading_status_effects[index].kind == kind and effect.chance > result.breading_status_effects[index].chance:
								result.breading_status_effects[index] = effect
	return result
