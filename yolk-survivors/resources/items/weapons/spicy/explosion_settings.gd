extends Resource
class_name SpicyExplosionSettings

@export_range(1, 20) var explosion_count := 3
@export_range(0.05, 3.0, 0.01) var explosion_interval := 0.32
@export var minimum_distance := 60.0
@export var explosion_radius := 95.0
@export_range(0.1, 1.0, 0.01) var area_y_ratio := 0.6
@export_range(0.0, 2.0, 0.01) var anticipation := 0.25
@export_range(0.05, 2.0, 0.01) var visual_duration := 0.3
@export var color := Color(1.0, 0.33, 0.035, 1.0)
@export_range(0.0, 1.0, 0.01) var opacity := 0.75
@export_range(0.0, 30.0, 0.1) var burn_duration := 3.0
@export_range(0.05, 5.0, 0.05) var burn_interval := 0.5
@export_range(0.0, 5.0, 0.05) var burn_damage_multiplier := 0.35

@export_group("Explosion visuals")
@export var core_color := Color("fff1ad")
@export var flame_color := Color("ff501d")
@export_range(0.0, 1.0, 0.05) var anticipation_opacity := 0.4
@export_range(0.0, 2.0, 0.05) var flame_strength := 1.0
@export_range(0, 48, 1) var ember_count := 20
@export var ember_duration := 0.4
@export var ember_travel := 0.55
@export var ember_size := 3.0
