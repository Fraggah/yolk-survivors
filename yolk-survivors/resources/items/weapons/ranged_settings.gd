extends Resource
class_name RangedSettings

@export_range(1, 16, 1) var projectile_count := 1
@export_range(0.0, 180.0, 1.0) var spread_degrees := 0.0
@export_range(1, 12, 1) var burst_count := 1
@export_range(0.01, 1.0, 0.01) var burst_interval := 0.1
@export_group("Explosion")
@export var explodes := false
@export var explode_on_impact := true
@export_range(0.05, 10.0, 0.05) var fuse := 0.8
@export_range(1.0, 400.0, 1.0) var explosion_radius := 70.0
@export_range(0.1, 1.0, 0.05) var area_y_ratio := 0.6
@export_range(0.0, 5.0, 0.05) var explosion_damage_multiplier := 1.0
@export var explosion_texture: Texture2D
@export var explosion_color := Color("f6bc65")
@export_range(0.05, 2.0, 0.01) var explosion_visual_duration := 0.18
@export_group("Contact remnant")
@export var leaves_pit := false
@export var pit_texture: Texture2D
@export_range(0.1, 20.0, 0.1) var pit_duration := 3.0
@export_range(1.0, 100.0, 1.0) var pit_radius := 16.0
@export_range(0.0, 3.0, 0.05) var pit_damage_multiplier := 0.5
@export_range(0.05, 3.0, 0.05) var pit_hit_interval := 0.5
