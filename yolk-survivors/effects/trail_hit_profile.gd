extends RefCounted
## Pure immutable damage/status profile shared by both trail implementations.
static func build(entries: Array[Dictionary], item_effects: Array[StatusEffect]) -> Dictionary:
	var total := 0.0
	var shares: Array[Dictionary] = []
	for entry in entries:
		total += entry.damage
		shares.append({"record": entry.record, "weight": entry.damage})
	for share in shares: share.weight /= maxf(0.00001, total)
	var record := {"wave_damage": 0.0, "total_damage": 0.0, "contributors": shares}
	var effects: Array[StatusEffect] = []
	effects.assign(item_effects)
	var fires: Dictionary = {}
	for entry in entries:
		for effect in entry.effects:
			if not effect: continue
			if effect.kind != StatusEffect.Kind.FIRE:
				if not effects.has(effect): effects.append(effect)
				continue
			var key: String = effect.resource_path if not effect.resource_path.is_empty() else str(effect.get_instance_id())
			key = str(effect.get_meta("stack_id", key))
			if not fires.has(key):
				var new_fire: StatusEffect = effect.duplicate()
				new_fire.damage = 0.0
				new_fire.set_meta("stack_id", "SharedCayenne_" + key)
				new_fire.set_meta("fire_contributions", [])
				fires[key] = new_fire
			var merged: StatusEffect = fires[key]
			merged.damage += effect.damage
			merged.get_meta("fire_contributions").append({"id": entry.id, "record": entry.record,
				"damage": effect.damage, "duration": effect.duration})
	for effect in fires.values(): effects.append(effect)
	return {"damage":total,"record":record,"effects":effects}
