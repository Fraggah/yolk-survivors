extends Node2D
class_name WeaponBehaviour

@export var weapon: Weapon

var critical: bool
var lock_aim_during_attack := false
var attack_tween: Tween

func create_attack_tween() -> Tween:
	if attack_tween and attack_tween.is_valid(): attack_tween.kill()
	attack_tween = create_tween()
	return attack_tween

func reset_attack() -> void:
	if attack_tween and attack_tween.is_valid(): attack_tween.kill()
	weapon.sprite_2d.position = weapon.atk_start_pos
	weapon.sprite_2d.rotation = 0.0
	weapon.is_attacking = false
	critical = false
	weapon.cooldown_timer.stop()


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
