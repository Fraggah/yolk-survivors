extends Node2D
class_name WeaponBehaviour

@export var weapon: Weapon

var critical: bool


func execute_attack() -> void:
	pass

func get_damage() -> float:
	critical = false
	var damage := weapon.data.get_effective_damage(Global.player.stats)
	var crit_chance := weapon.data.stats.crit_chance
	if Global.get_chance_succes(crit_chance):
		critical = true
		damage = damage * weapon.data.stats.crit_damage
	return damage

func get_life_steal_chance() -> float:
	if not is_instance_valid(Global.player): return 0.0
	return clampf(Global.player.stats.life_steal / 100.0 + weapon.data.stats.life_steal, 0.0, 1.0)
