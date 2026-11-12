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
## Radians per second before the player attack-speed multiplier.
@export var orbit_speed := 2.4
## Base world units; keeps the orbit around the body instead of the feet.
@export var orbit_center_offset := Vector2.ZERO
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
## Fixed height in base world units.
@export var column_height := 288.0
## Presentation sampling only; damage/contact clocks continue independently.
@export_range(0.0,120.0,1.0) var column_visual_update_rate := 30.0
## Ground hit footprint, independent from the painted column width.
@export_range(1.0, 3.0, 0.05) var column_hit_radius_multiplier := 1.5
@export_group("Column short fire trail")
@export_range(0.1, 3.0, 0.05) var column_trail_lifetime := 1.1
## 1.0 matches the painted column width; this does not use its larger hitbox.
@export_range(0.1, 2.0, 0.05) var column_trail_radius_multiplier := 1.0
@export_range(4.0, 80.0, 1.0) var column_trail_spacing := 18.0
@export_range(0.0, 1.0, 0.05) var column_trail_damage_multiplier := 0.25
@export_group("")
@export var sprite_scale := 0.22

@export_group("Trail fire visuals")
## Empty uses the same visual settings as burning characters.
@export var trail_fire_visuals: Resource
@export_range(0.1, 2.0, 0.05) var trail_flame_height := 0.65
@export_range(0.01, 1.0, 0.01) var trail_fade_in := 0.12
@export_range(0.01, 2.0, 0.01) var trail_fade_out := 0.4

@export_group("Fire column visuals")
@export var column_ring_texture: Texture2D
@export var column_fill_texture: Texture2D
@export_range(0.0, 1.0, 0.01) var column_ring_center_opacity := 0.28
@export_range(0.0, 1.0, 0.01) var column_fill_opacity := 0.96
@export_range(1.0, 4.0, 0.05) var column_fill_width := 2.8
@export_range(1.0, 4.0, 0.05) var column_top_width_multiplier := 2.1
## World height to reach the widest part, independent from camera framing.
@export_range(100.0, 1200.0, 10.0) var column_flare_height := 500.0
@export_range(1.0, 3.0, 0.05) var column_ring_height_scale := 1.7
## Ring spacing is measured in base world units.
@export_range(8.0, 80.0, 1.0) var column_ring_spacing := 48.0
@export var column_top_margin := 160.0
@export_range(0.0, 1.0, 0.01) var column_ring_opacity := 0.24
@export_range(0.0, 0.2, 0.005) var column_distortion := 0.025
@export var column_flow_speed := 1.8
@export var column_core_color := Color(1.0, 0.87, 0.35, 1.0)
@export_range(0, 64) var column_base_flames := 8
@export_range(0, 64) var column_ember_count := 28
@export var column_ember_size := 2.5
@export_range(0.01, 1.0, 0.01) var column_fade_in := 0.18
@export_range(0.01, 2.0, 0.01) var column_fade_out := 0.4

@export_group("Fire column contact and heat")
@export var column_contact_texture: Texture2D
@export_range(1.0, 1.8, 0.05) var column_contact_glow_scale := 1.2
@export_range(0.0, 1.0, 0.05) var column_contact_glow_opacity := 0.3
@export_range(0.0, 1.0, 0.01) var column_contact_opacity := 0.95
@export_range(0.0, 1.0, 0.01) var column_contact_front_start := 0.56
@export_range(0.0, 2.0, 0.05) var column_heat_side_reach := 0.6
@export_range(0.0, 20.0, 0.5) var column_heat_distortion_pixels := 3.0
@export_range(0.0, 1.0, 0.01) var column_heat_opacity := 0.55

@export_group("Fire column contact sparks")
@export_range(0, 192) var column_contact_spark_count := 72
@export_range(0.1, 2.0, 0.05) var column_contact_spark_lifetime := 0.75
## Travel and leap height are fractions of the ground radius.
@export var column_contact_spark_travel := 1.2
@export var column_contact_spark_height := 0.8
@export var column_contact_spark_size := 3.2
@export_range(0.0, 1.0, 0.01) var column_contact_spark_opacity := 0.95

@export_group("Cloud visuals")
@export var cloud_texture: Texture2D
@export_range(1, 48) var cloud_layer_count := 18
@export var cloud_billow_speed := 0.65
@export_range(0.0, 0.1, 0.002) var cloud_distortion := 0.018
@export var cloud_visual_height := 0.08
@export_range(0.01, 2.0, 0.01) var cloud_fade_in := 0.35
@export_range(0.01, 2.0, 0.01) var cloud_fade_out := 0.65

@export_range(0.05, 1.0, 0.01) var cloud_puff_min_scale := 0.28
@export_range(0.05, 1.0, 0.01) var cloud_puff_max_scale := 0.48
@export_range(0.0, 1.0, 0.01) var cloud_puff_opacity := 0.42
@export_range(0.0, 0.5, 0.01) var cloud_puff_drift := 0.15
@export_range(0.3, 8.0, 0.1) var cloud_puff_lifetime := 3.0

@export_group("Cloud placement")
## Desired center spacing, as a fraction of the mean damage radius.
@export_range(0.0, 2.0, 0.05) var cloud_min_separation := 0.85
@export_range(8, 128) var cloud_spawn_attempts := 48

@export_group("Mine placement and visuals")
@export var mine_texture: Texture2D
## Optional display bounds for a dedicated sprite, without altering its PNG.
@export var mine_texture_rect := Rect2()
## Each additional equipped copy expands the placement radius by this fraction.
@export var mine_spawn_growth_per_copy := 0.2
@export var mine_visual_width := 40.0
@export_range(0.1, 1.0, 0.01) var mine_visible_fraction := 0.5
@export_range(0.0, 0.3, 0.01) var mine_squash_strength := 0.08
@export var mine_squash_speed := 3.5
@export var mine_core_color := Color(1.0, 0.95, 0.7, 1.0)
@export var mine_flame_color := Color(1.0, 0.25, 0.04, 1.0)
@export_range(0, 48) var mine_blast_flame_count := 16
@export_range(0, 96) var mine_ember_count := 32
@export var mine_ember_duration := 0.4
@export var mine_ember_travel := 0.75
@export var mine_ember_size := 3.0

@export_group("Shockwave visuals")
@export_range(0.0, 1.0, 0.01) var shockwave_visual_tail := 0.18
@export var shockwave_core_color := Color(1.0, 0.95, 0.72, 1.0)
@export_range(0.01, 0.15, 0.005) var shockwave_rim_width := 0.035
@export_range(0, 96) var shockwave_spark_count := 36
@export var shockwave_spark_size := 3.2
