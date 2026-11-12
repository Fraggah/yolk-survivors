extends Resource
class_name WaveData
const ScheduledSpawnResource = preload("res://resources/wave/scheduled_spawn.gd")
const BossEncounterResource = preload("res://resources/bosses/boss_encounter_settings.gd")

enum WaveType { NORMAL, HORDE, SPECIAL, BOSS }
## Kept for existing resources. The difficulty list sets the in-game wave number.
@export_storage var number := 1
@export_range(0.1, 600.0, 0.1) var wave_time := 30.0
@export var wave_type := WaveType.NORMAL
## Assign the encounter to use its boss, arena and mechanics for this wave.
## An assigned encounter takes precedence over Wave Type and Arena Mode.
@export var boss_encounter: BossEncounterResource
## Empty inherits arena/default music. One entry forces a track; several randomize.
@export var music_tracks: Array[AudioStream] = []

## Horde controls enemy composition; arena selection is independent.
enum ArenaMode { BASE, FIXED, RANDOM_SPECIAL }
@export var arena_mode := ArenaMode.BASE
@export var fixed_arena: ArenaStage
@export var scheduled_spawns: Array[ScheduledSpawnResource] = []
## Zero uses the temporary crowd test; a positive value overrides it.
@export_range(0, 10) var density_multiplier := 0
@export var groups: Array[SpawnGroup] = []
@export var events: Array[SpawnGroup] = []
@export_range(1, 500) var common_limit := 35
@export_range(0, 10) var hazard_limit := 0
@export_range(0, 10) var boss_limit := 0
@export_range(0, 20) var reward_limit := 2
@export var health_multiplier := 1.0
@export var damage_multiplier := 1.0
@export var speed_multiplier := 1.0
@export var resistance_multiplier := 1.0

func has_boss_encounter() -> bool:
	return boss_encounter != null and boss_encounter.arena_stage != null and boss_encounter.boss_scene != null
