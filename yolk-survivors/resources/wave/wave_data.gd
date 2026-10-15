extends Resource
class_name WaveData

enum WaveType { NORMAL, HORDE, SPECIAL, BOSS }
@export_range(1, 100) var number := 1
@export var wave_time := 20.0
@export var wave_type := WaveType.NORMAL
## Zero uses the temporary crowd test; a positive value overrides it.
@export_range(0, 10) var density_multiplier := 0
@export var groups: Array[SpawnGroup] = []
@export var events: Array[SpawnGroup] = []
@export_range(1, 500) var common_limit := 35
@export_range(0, 10) var hazard_limit := 0
@export_range(0, 10) var boss_limit := 0
@export var health_multiplier := 1.0
@export var damage_multiplier := 1.0
@export var speed_multiplier := 1.0
@export var resistance_multiplier := 1.0

func is_valid_index(index: int) -> bool:
	return number == index
