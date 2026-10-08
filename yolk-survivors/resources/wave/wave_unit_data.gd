extends Resource
class_name WaveUnitData

@export var unit_scene: PackedScene
@export var weight := 1.0

@export_range(0, 5) var minimum_difficulty := 0
@export_range(1, 10) var first_wave := 1

func is_eligible(difficulty: int, wave: int) -> bool:
	return unit_scene != null and weight > 0.0 and difficulty >= minimum_difficulty and wave >= first_wave
