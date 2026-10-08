extends RefCounted

# Total bonuses, never stacked between difficulty levels.
const STAT_MULTIPLIERS := [1.0, 1.0, 1.0, 1.12, 1.26, 1.4]
# Adapted to our ten-wave run; no elite/boss enemies exist yet.
const HORDE_WAVES := [[], [], [6], [6], [4, 6, 9], [4, 6, 9]]
const HORDE_SPAWN_INTERVAL_MULTIPLIER := 0.65

static func normalize_level(level: int) -> int:
	return clampi(level, 0, STAT_MULTIPLIERS.size() - 1)

static func stat_multiplier(level: int) -> float:
	return STAT_MULTIPLIERS[normalize_level(level)]

static func is_horde(level: int, wave: int) -> bool:
	return wave in HORDE_WAVES[normalize_level(level)]

static func description(level: int) -> String:
	match normalize_level(level):
		0: return "Base difficulty."
		1: return "Shooter and Charger can appear from wave 3."
		2: return "Earlier enemies. Horde on wave 6."
		3: return "Earlier enemies. Horde on wave 6.\nEnemies have +12% HP and damage."
		4: return "Earlier enemies. Hordes on waves 4, 6 and 9.\nEnemies have +26% HP and damage."
		_: return "Earlier enemies. Hordes on waves 4, 6 and 9.\nEnemies have +40% HP and damage."
