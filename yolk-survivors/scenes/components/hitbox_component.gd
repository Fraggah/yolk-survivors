extends Area2D
class_name HitboxComponent

signal on_hit_hurtbox(hurtbox: HurtboxComponent)

var damage := 1.0
var critical := false
var roll_critical_per_target := false
var critical_chance := 0.0
var critical_multiplier := 1.0
var base_damage := 1.0
var knockback_power := 0.0
var source: Node2D
var grants_enemy_rewards := true
var weapon_damage_record: Dictionary = {}
var life_steal_chance := 0.0
var continuous_contact := false
var hit_once_per_activation := false
var _hit_hurtboxes: Dictionary = {}
var launch_on_hit := false
var launch_speed := 520.0
var launch_duration := 0.45
var launch_damage := 0.0
var cancel_knockback_on_hit := false
@export var bb: CollisionShape2D

func enable() -> void:
	_hit_hurtboxes.clear()
	set_deferred("monitoring", true)
	if is_instance_valid(bb): bb.set_deferred("disabled", false)

func disable() -> void:
	set_deferred("monitoring", false)
	if is_instance_valid(bb): bb.set_deferred("disabled", true)

func setup(p_damage: float, p_critical: bool, p_knockback: float, p_source: Node2D) -> void:
	damage = p_damage
	base_damage = p_damage
	roll_critical_per_target = false
	critical = p_critical
	knockback_power = p_knockback
	source = p_source


func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		on_hit_hurtbox.emit(area)

func claim_hit(hurtbox: HurtboxComponent) -> bool:
	if not hit_once_per_activation: return true
	var target_id := hurtbox.get_instance_id()
	if _hit_hurtboxes.has(target_id): return false
	_hit_hurtboxes[target_id] = true
	return true

func report_damage(target: Unit, amount: float) -> void:
	if amount <= 0.0 or Global.game_paused: return
	if target is Enemy and not weapon_damage_record.is_empty():
		weapon_damage_record.wave_damage += amount
		weapon_damage_record.total_damage += amount
	if target is Enemy and is_instance_valid(source) and source is Player:
		source.try_life_steal(life_steal_chance)

func roll_target_critical() -> void:
	if not roll_critical_per_target: return
	critical = Global.get_chance_succes(critical_chance)
	damage = base_damage * (critical_multiplier if critical else 1.0)
