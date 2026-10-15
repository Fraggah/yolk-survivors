extends Resource
class_name MeleeSettings
## Per-tier attack settings. Durations use seconds, distances use weapon-local
## units, multipliers use 1.0 = 100%; angle fields use degrees, rotations radians.
@export_group("Animation")
@export_range(0.01, 5.0, 0.01) var animation_speed := 1.0
@export_range(0.01, 10.0, 0.01) var timing_reference := 0.95
@export_range(0.0, 10.0, 0.005) var preparation_duration := 0.1
@export_range(0.001, 10.0, 0.005) var forward_duration := 0.2
@export_range(0.001, 10.0, 0.005) var return_duration := 0.1
@export_range(0.0, 10.0, 0.005) var contact_duration := 0.045
@export_range(0.0, 10.0, 0.005) var pause_duration := 0.1
@export_group("Motion")
@export var reach_multiplier := 1.0
@export var windup_offset := -12.0
@export var raised_angle := 0.0
@export var sweep_start_angle := -90.0
@export var sweep_end_angle := 90.0
@export var semicircle_radius_multiplier := 0.75
@export var fallback_angle := 60.0
@export var cutter_return_angle := 12.0
@export var repeated_retract_multiplier := 0.7
@export var lateral_offset := 12.0
@export var scrape_start := Vector2(20,-18)
@export var scrape_end := Vector2(-15,18)
@export var scrape_rotation := 0.12
@export var blend_rotation := 0.22
@export var blend_offset := 6.0
@export_group("Repeated hits")
@export_range(1, 30, 1) var hit_count := 1
@export_group("Glove")
@export_range(0.0, 5.0, 0.01) var direct_damage_multiplier := 0.15
@export_range(0.0, 10.0, 0.05) var collision_damage_multiplier := 1.0
@export var launch_speed := 520.0
@export_range(0.01, 10.0, 0.01) var launch_duration := 0.45
@export_group("Hammer")
@export var early_damage_multiplier := 0.35
@export var final_damage_multiplier := 1.75
@export var early_knockback := 2.2
@export var final_knockback := 0.0
@export_group("Grater")
@export var capture_radius := 70.0
@export_group("Pan")
@export var slow_radius := 120.0
@export_range(0.0, 1.0, 0.01) var slow_factor := 0.5
@export var close_hit_radius := 35.0
@export_group("Pan visual effect")
@export_range(0.01, 5.0, 0.005) var effect_duration := 0.125
@export_range(0.0, 1.0, 0.01) var effect_opacity := 0.3
@export_range(0.1, 1.0, 0.01) var effect_y_ratio := 0.55
@export var effect_color := Color("86a9be")
@export var ring_width := 2.0
@export var spark_width := 1.5
@export var spark_length := 10.0
@export_range(0, 64, 1) var spark_count := 16
@export var ring_start_radius := 0.3
@export var spark_start_radius := 0.45
@export var status_text := "Slowed"
@export_range(0.0, 10.0, 0.05) var status_text_duration := 1.3
@export var status_text_color := Color("86a9be")
@export_group("Rotating blade visual")
@export var rotor_speed := 12.0
@export var rotor_radius := 23.0
@export var rotor_center := Vector2(52,0)
@export var rotor_arc := 1.2
@export var rotor_width := 1.5
@export var rotor_color := Color(0.25,0.25,0.22,0.65)
