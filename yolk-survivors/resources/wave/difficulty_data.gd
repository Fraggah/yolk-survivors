extends Resource
class_name DifficultyData

## List order defines the wave number shown in game.
@export var waves: Array[WaveData] = []

@export_group("Enemy Multipliers")
@export_range(0.01, 10.0, 0.01, "or_greater") var health_multiplier := 1.0
@export_range(0.0, 10.0, 0.01, "or_greater") var damage_multiplier := 1.0
@export_range(0.0, 10.0, 0.01, "or_greater") var speed_multiplier := 1.0
@export_range(0.0, 10.0, 0.01, "or_greater") var resistance_multiplier := 1.0
@export_range(0.01, 10.0, 0.01, "or_greater") var spawn_frequency_multiplier := 1.0

func description(display_wave_count: int = -1) -> String:
	var lines := PackedStringArray()
	for modifier in [
		["Spawn frequency", spawn_frequency_multiplier],
		["Enemy HP", health_multiplier],
		["Enemy damage", damage_multiplier],
		["Enemy speed", speed_multiplier],
		["Enemy knockback resistance", resistance_multiplier],
	]:
		var value: float = modifier[1]
		if not is_equal_approx(value, 1.0):
			lines.append("%s ×%s" % [modifier[0], String.num(value, 2)])
	if lines.is_empty():
		lines.append("Base difficulty.")
	return "%d waves · %s" % [display_wave_count if display_wave_count >= 0 else waves.size(), ", ".join(lines)]
