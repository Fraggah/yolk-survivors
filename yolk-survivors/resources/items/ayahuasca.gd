extends RefCounted

static func roll_outcome(roll: float = -1.0, weights := PackedFloat32Array()) -> int:
	if weights.size() != 4: weights = PackedFloat32Array([25, 25, 25, 25])
	var total := 0.0
	for weight in weights: total += maxf(0.0, weight)
	if total <= 0.0: return 0
	var value := (randf() if roll < 0.0 else clampf(roll, 0.0, 0.999999)) * total
	for index in 4:
		value -= maxf(0.0, weights[index])
		if value < 0.0: return index
	return 3

static func eligible_primaries(player: Player) -> Array[String]:
	var result: Array[String] = []
	for stat_id: String in player.passive_items.PRIMARY:
		if player.stats.primary_display_value(stat_id) > 0.0: result.append(stat_id)
	return result

static func apply(player: Player, item: ItemPassive, test_outcome: int = -1, test_stat: String = "") -> Dictionary:
	var arena = player.get_tree().current_scene
	if not arena is Arena: return {}
	var outcome := roll_outcome(-1.0, item.ayahuasca_outcome_weights) if test_outcome < 0 else test_outcome
	var result := {"outcome": outcome, "message": ""}
	match outcome:
		0, 1:
			result["rewound"] = arena.rewind_upcoming_waves(outcome + 1)
			result.message = "Retrocedés %d oleada(s). Próxima oleada: %d.\nConservás tus armas, ítems, niveles y yemas." % [result.rewound, arena.spawner.wave_index + 1]
		2:
			arena.run_experience.grant_levels(item.ayahuasca_levels)
			result.message = "¡Ganaste %d niveles!\nAl continuar elegirás las mejoras antes de la siguiente oleada." % item.ayahuasca_levels
		3:
			var candidates := eligible_primaries(player)
			if candidates.is_empty():
				result.message = "No tenés estadísticas primarias positivas para reducir."
				return result
			var stat_id: String = candidates.pick_random() if test_stat.is_empty() else test_stat
			if not candidates.has(stat_id): return {}
			var before := player.stats.primary_display_value(stat_id)
			if not player.stats.halve_primary_stat(stat_id): return {}
			result["stat"] = stat_id
			result["before"] = before
			result["after"] = player.stats.primary_display_value(stat_id)
			result.message = "%s se redujo a la mitad: %s → %s." % [stat_id.replace("_", " ").capitalize(), ItemWeapon.format_number(before), ItemWeapon.format_number(result.after)]
	return result
