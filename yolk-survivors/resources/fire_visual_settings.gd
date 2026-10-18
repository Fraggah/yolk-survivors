extends Resource
class_name FireVisualSettings

@export_range(1, 20, 1) var flame_count := 12
@export_range(0.0, 1.0, 0.05) var flame_opacity := 0.85
@export_range(0.5, 2.0, 0.05) var coverage := 1.1
@export_range(0.0, 3.0, 0.05) var flicker_speed := 1.0
@export var core_color := Color("ffd16a")
@export_range(0, 32, 1) var ember_count := 16
@export_range(0.002, 0.04, 0.001) var ember_size := 0.008
@export_range(0.0, 1.0, 0.05) var ember_opacity := 0.65
@export_range(0.0, 1.0, 0.01) var heat_opacity := 0.16
@export_range(0.01, 1.0, 0.01) var fade_duration := 0.2

@export_group("Flame sprites")
@export var flame_texture: Texture2D
@export_range(0.0, 1.0, 0.05) var lower_body_fraction := 0.8
## Fraction of the burning unit's sprite height.
@export_range(0.1, 0.8, 0.01) var flame_sprite_height := 0.36
@export_range(0.0, 0.5, 0.01) var size_pulse := 0.22
@export_range(0.1, 3.0, 0.05) var flip_interval_min := 0.35
@export_range(0.1, 3.0, 0.05) var flip_interval_max := 0.9
@export_range(0.0, 0.1, 0.001) var distortion_strength := 0.018
@export_range(1.0, 100.0, 1.0) var distortion_frequency := 38.0
@export_range(0.0, 10.0, 0.1) var distortion_speed := 2.2

@export_group("Background flame")
@export_range(0.0, 1.0, 0.05) var background_flame_opacity := 0.35
@export_range(0.5, 2.0, 0.05) var background_flame_height := 1.3
@export_range(0.5, 2.0, 0.05) var background_flame_width := 1.4
