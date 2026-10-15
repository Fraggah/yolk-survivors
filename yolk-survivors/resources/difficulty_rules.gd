extends RefCounted

# Total bonuses, never stacked between difficulty levels.
const STAT_MULTIPLIERS := [1.0, 1.0, 1.0, 1.12, 1.26, 1.4]
# Density changes never inject enemy families outside the wave allow-list.
const DENSITY_MULTIPLIERS := [1.0, 1.08, 1.16, 1.16, 1.24, 1.32]
static func density_multiplier(level: int) -> float:
	return DENSITY_MULTIPLIERS[normalize_level(level)]

static func normalize_level(level: int) -> int:
	return clampi(level, 0, STAT_MULTIPLIERS.size() - 1)

static func stat_multiplier(level: int) -> float:
	return STAT_MULTIPLIERS[normalize_level(level)]

static func description(level: int) -> String:
	match normalize_level(level):
		0: return "Base difficulty."
		1: return "Enemies appear 8% more frequently."
		2: return "Enemies appear 16% more frequently."
		3: return "Enemies appear 16% more frequently.\nEnemies have +12% HP and damage."
		4: return "Enemies appear 24% more frequently.\nEnemies have +26% HP and damage."
		_: return "Enemies appear 32% more frequently.\nEnemies have +40% HP and damage."
