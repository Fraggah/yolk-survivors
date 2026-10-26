extends Resource
class_name EnemyProfile
## An enemy family shared by wave groups; additions need only a new resource.
enum Population { COMMON, HAZARD, BOSS, REWARD }
@export var id: StringName
@export var scene: PackedScene
@export var population := Population.COMMON
@export_range(0.1, 3.0) var visual_scale := 1.0
@export_range(0.0, 1.0) var knockback_resistance := 0.0
@export var spawn_margin := 80.0
@export var minimum_player_distance := 120.0
@export var health_growth_multiplier := 1.0
@export var damage_growth_multiplier := 1.0
@export var speed_growth_per_wave := 0.0
@export var resistance_growth_per_wave := 0.0

func is_valid() -> bool:
	return scene != null and not id.is_empty()
