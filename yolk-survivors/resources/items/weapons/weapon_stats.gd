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
