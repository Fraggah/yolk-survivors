extends Resource
class_name WeaponStats

@export var damage := 1.0
@export_range(0.0, 3.0, 0.05) var damage_scaling := 1.0
@export_range(.0, 1.0) var accuracy := 1.0
@export_range(.05, 3.0, .01) var cooldown := 1.0
@export_range(.0, 1.0) var crit_chance := .05
@export var crit_damage := 1.5
@export var max_range := 150.0
## Removes projectile travel cap only; max_range still controls target detection.
@export var unlimited_range := false
@export var unlimited_piercing := false
@export var knockback := .0
@export_range(0.0, 10.0, 0.05) var slow_duration := 0.5
@export_range(0, 100, 1) var piercing := 0
@export_range(0, 100, 1) var bounces := 0
@export_range(.0, 1.0) var life_steal := .0
@export var recoil := 25.0
@export_range(.01, 3.0, .01) var recoil_duration := .1
@export_range(.1, 3.0) var attack_duration := .2
@export_range(.1, 3.0) var back_duration := .15
@export var projectile_scene: PackedScene
@export var projectile_speed := 1500.0
@export_group("Ranged effects")
@export var ranged_settings: RangedSettings
@export_group("Spicy aura")
@export var aura_settings: SpicyAuraSettings
@export var spicy_explosion_settings: SpicyExplosionSettings
@export var spicy_pattern: SpicyPatternSettings
@export_group("Melee effects and animation")
@export var melee_settings: MeleeSettings = MeleeSettings.new()
@export_range(0.1, 1.0, 0.01) var animation_cooldown_fraction := 0.9
