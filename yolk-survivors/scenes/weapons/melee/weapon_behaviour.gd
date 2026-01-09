extends Node2D
class_name WeaponBehaviour

@export var weapon: Weapon

var critical: bool


func execute_attack() -> void:
	pass

func get_damage() -> float:
	var damage := weapon.data.stats.damage + Global.player.stats.damage
	var crit_chance := weapon.data.stats.crit_chance
	if Global.get_chance_succes(crit_chance):
		critical = true
		damage = damage * weapon.data.stats.crit_damage
	return damage
