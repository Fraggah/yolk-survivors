extends Resource
class_name StatusEffect
const FireVisualConfig = preload("res://resources/fire_visual_settings.gd")

enum Kind { FIRE, ELECTRICITY }
@export var kind := Kind.FIRE
## Damage per fire tick, or immediate electric damage; before source Effects scaling.
@export var damage := 2.0
@export_range(0.0, 30.0, 0.1) var duration := 3.0
@export_range(0.05, 10.0, 0.05) var tick_interval := 0.5
## Base world radius before entity scale; electricity spreads from primary only.
@export var chain_radius := 65.0
@export_range(0, 100) var maximum_chain_targets := 3
@export var color := Color(1.0, 0.35, 0.05)
@export_range(0.0, 1.0, 0.01) var chance := 1.0
@export_group("Fire visuals")
@export var fire_visuals: FireVisualConfig
@export_group("Electric visuals")
## Persistent sparks follow the scaled status duration; burst is cosmetic only.
@export_range(0.05, 2.0, 0.01) var electric_impact_duration := 0.38
@export_range(1, 20, 1) var electric_ray_count := 7
@export_range(0.0, 3.0, 0.05) var electric_glow_strength := 1.0
@export_range(0.25, 3.0, 0.05) var electric_visual_scale := 1.0
