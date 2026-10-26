extends Resource
## Incremental boss prototype. Balance and debug buffs remain editable.
@export var boss_name := "Salchichón del Infierno"
@export var arena_stage: ArenaStage
@export var boss_scene: PackedScene
@export_range(1,1000000,1) var total_health := 1000.0
@export_range(0.1,60,0.1) var vulnerable_seconds := 8.0
@export_range(0.1,60,0.1) var section_seconds := 30.0
@export_range(0,30,0.1) var initial_wait_seconds := 3.0
@export_range(0,30,0.1) var departure_wait_seconds := 2.0
@export_range(0.1,10,0.1) var landing_warning_seconds := 1.2
@export_range(0.1,3,0.05) var fall_seconds := 0.4
@export var contact_damage := 5.0
@export var landing_damage := 5.0
## Relative to the visible shadow authored in the boss scene.
@export_range(0.1,2,0.05) var landing_radius_multiplier := 1.0
@export var fall_height := 600.0
@export var landing_visual_radius_multiplier := 1.1
@export_range(0,2,0.01) var takeoff_anticipation_seconds := 0.22
@export_range(0,2,0.01) var takeoff_jump_seconds := 0.48
@export_range(0,0.5,0.01) var takeoff_compression := 0.22
@export var takeoff_height := 1800.0
@export_group("Boss squash and stretch")
@export_range(0,0.3,0.005) var idle_squash_strength := 0.045
@export_range(0.2,5,0.05) var idle_squash_period := 1.4
@export_range(0,0.5,0.01) var landing_squash_strength := 0.2
@export_range(0.1,2,0.05) var landing_squash_seconds := 0.55
@export_group("Isolated test character")
@export var test_health := 85.0
@export var test_regen := 0.0
@export var test_ranged_damage := 15.0
@export var test_damage_percent := 40.0
@export var test_armor := 15.0
@export var test_block_chance := 20.0
@export var test_life_steal := 20.0

@export_group("Phase 1 - static fire lines")
@export var static_line_patterns: Array[Resource] = []
@export_range(1,160,1) var line_width := 72.0
@export var line_damage := 10.0
@export_group("Laser glow")
@export_range(0,1000,10) var laser_end_overscan := 240.0
@export var laser_glow_strength := 1.0
@export var laser_flash_strength := 1.225
@export_range(0.05,1,0.01) var laser_flash_seconds := 0.22
@export_group("Phase 1 - static fire lines")
## Snap one stripe to the player when the warning begins; it stays fixed afterward.
@export var line_target_player := true
@export_range(0.1,10,0.1) var line_warning_seconds := 1.2
@export_range(0.1,20,0.1) var line_active_seconds := 1.0
@export_range(0,20,0.1) var line_rest_seconds := 0.8
@export_group("Phase 1 - fixed turrets")
@export var turret_scene: PackedScene
@export_range(0.1,30,0.1) var turret_batch_interval := 2.0
@export_range(0.1,30,0.1) var turret_lifetime := 4.0
@export_range(0.1,10,0.1) var turret_warning_seconds := 1.2
## One turret per batch aligns a fixed beam with the player at birth.
@export var turret_target_player := true
@export var turret_line_width := 72.0
@export var turret_line_damage := 10.0
@export var turret_contact_damage := 5.0
## Minimum center-to-center separation when any turret appears.
@export_range(100,600,10) var turret_spawn_min_distance := 220.0
@export var turret_contact_radius := 42.0
@export var turret_visual_height := 140.0
## Three points per batch, normalized against the playable arena; batches wrap.
@export var turret_positions := PackedVector2Array([
	Vector2(0.18,0.23),Vector2(0.52,0.2),Vector2(0.82,0.32),
	Vector2(0.25,0.76),Vector2(0.62,0.7),Vector2(0.87,0.8),
	Vector2(0.12,0.55),Vector2(0.45,0.42),Vector2(0.78,0.16),
	Vector2(0.31,0.15),Vector2(0.6,0.85),Vector2(0.88,0.51)])
@export_group("Phase 1 - hot zones and Fueguitos")
@export var fueguito_profile: EnemyProfile
@export_range(0.1,30,0.1) var fueguito_interval := 3.0
@export_range(0.05,3,0.05) var fueguito_flare_seconds := 0.45
@export_range(0.1,30,0.1) var hot_zone_interval := 5.0
@export_range(1,24,1) var hot_zone_count := 12
@export var hot_zone_radius := 350.0
@export var hot_zone_damage := 2.0
@export_range(0.05,5,0.05) var hot_zone_damage_interval := 0.75
@export_range(0.05,5,0.05) var hot_zone_warning_seconds := 1.0
@export_range(0.05,5,0.05) var hot_zone_cooling_seconds := 1.2
@export_group("Phase 2 - persistent Fueguito")
@export var phase_two_fueguito_enabled := true
@export_group("Phase 2 - moving lines")
@export_range(0.1,10,0.1) var moving_line_interval := 3.0
@export_range(0.05,5,0.05) var moving_line_warning_seconds := 0.6
@export_range(0.1,10,0.1) var moving_line_travel_seconds := 2.4
@export var moving_line_width := 72.0
@export var moving_line_damage := 10.0
## Travel directions, not the orientation of the perpendicular fire barrier.
@export var moving_line_directions := PackedVector2Array([
	Vector2.UP,Vector2.DOWN,Vector2(1,-1),Vector2.LEFT,Vector2.RIGHT,
	Vector2(-1,-1),Vector2.RIGHT,Vector2(1,1),Vector2(-1,1),Vector2.UP])
## One-based attack numbers: add a simultaneous perpendicular barrier.
@export var moving_line_double_attacks := PackedInt32Array([5,10])
@export_range(1,100,1) var moving_line_triple_from := 6
## Center-to-center distance between the three parallel barriers.
@export var moving_line_triple_spacing := 108.0
@export_range(1,12,1) var moving_line_parallel_count := 3
@export_group("Phase 2 - rotating turrets")
@export_range(0.1,30,0.1) var rotating_turret_interval := 3.0
@export_range(0.1,30,0.1) var rotating_turret_lifetime := 3.0
@export_range(0.05,5,0.05) var rotating_turret_warning_seconds := 1.2
@export_range(0,360,1) var rotating_turret_degrees_per_second := 30.0
@export_group("Phase 2 - intensified lines")
@export_range(0.1,10,0.1) var intensified_line_interval := 2.0
## Fraction of each axis retained from the Phase 1 static patterns.
@export_range(0.025,1,0.025) var intensified_line_density := 0.375
@export_group("Phase 3 - complex lines")
@export_range(0.1,10,0.1) var complex_line_interval := 2.5
@export_range(0.05,5,0.05) var complex_moving_warning_seconds := 0.5
@export_range(0.1,10,0.1) var complex_moving_travel_seconds := 1.5
@export_range(1,12,1) var complex_moving_parallel_count := 5
@export var complex_moving_spacing := 108.0
@export_group("Phase 3 - mobile or rotating turrets")
## Normalized A/B pairs. Timing, rotation and damage reuse the rotating turrets.
@export var mobile_turret_start_positions := PackedVector2Array([
	Vector2(0.18,0.25),Vector2(0.82,0.75),Vector2(0.2,0.75),
	Vector2(0.8,0.25),Vector2(0.5,0.2),Vector2(0.15,0.5)])
@export var mobile_turret_end_positions := PackedVector2Array([
	Vector2(0.82,0.25),Vector2(0.18,0.75),Vector2(0.8,0.25),
	Vector2(0.2,0.75),Vector2(0.5,0.8),Vector2(0.85,0.5)])
@export_group("Phase 3 - final mixed mechanics")
@export_range(0.1,10,0.1) var mixed_mechanic_interval := 2.5
## Internal composition limit; zero keeps normal repeating turret sections.
@export_storage var rotating_turret_spawn_limit := 0
@export_storage var rotating_turret_sequence_offset := 0
@export_group("Development")
@export var test_static_lines_first := false
@export var test_moving_lines_first := false
@export var test_complex_lines_first := false
