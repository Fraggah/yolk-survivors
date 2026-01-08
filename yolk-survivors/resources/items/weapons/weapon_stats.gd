extends Resource
class_name WeaponStats

@export var damage := 1
@export_range(.0, 1.0) var accuracy := .8
@export_range(.5, 3.0) var cooldown := 1.0
@export_range(.0, 1.0) var crit_chance := .05
@export var crit_damage := 1.5
@export var max_range := 150.0
@export var knockback := .0
@export_range(.0, 1.0) var life_steal := .0
@export var recoil := 25.0
@export_range(.1, 3.0) var recoil_duration := .1
@export_range(.1, 3.0) var attack_duration := .2
@export_range(.1, 3.0) var back_duration := .15
@export var projectile_scene: PackedScene
@export var projectile_speed := 1500.0
