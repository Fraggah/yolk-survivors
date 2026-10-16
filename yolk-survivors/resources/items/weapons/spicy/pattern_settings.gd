extends Resource
class_name SpicyPatternSettings

enum Mode { TRAIL, ORBIT, TORNADO, CLOUD, SPIRAL, MINE, SHOCKWAVE }
@export var mode := Mode.TRAIL
@export_range(1, 20) var count := 1
@export var radius := 55.0
@export_range(0.1, 1.0, 0.01) var area_y_ratio := 0.6
@export var lifetime := 3.0
@export_range(0.05, 5.0, 0.05) var tick_interval := 0.5
@export var fire_ticks := false
@export var movement_speed := 120.0
@export var orbit_speed := 2.4
@export var trail_spacing := 24.0
@export var arming_time := 0.6
@export var trigger_radius := 40.0
@export var spiral_step_degrees := 22.5
@export var spiral_seed_gap_degrees := 15.0
@export var wave_duration := 0.6
@export var wave_band := 14.0
@export_range(1, 50) var maximum_active := 8
@export var color := Color(1.0, 0.35, 0.05, 1.0)
@export_range(0.0, 1.0, 0.01) var opacity := 0.65
@export var column_height := 140.0
@export var sprite_scale := 0.22
