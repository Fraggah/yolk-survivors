extends Area2D
class_name HitboxComponent

static var _breading_handler: Script

signal on_hit_hurtbox(hurtbox: HurtboxComponent)
## Emitted only after a Unit accepted damage, including lethal hits.
signal damage_dealt(target: Unit, amount: float)

var damage := 1.0
var critical := false
var critical_allowed := true
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
var projectile: Node
var launch_direction := Vector2.ZERO
var launch_on_hit := false
var launch_speed := 520.0
var launch_duration := 0.45
var launch_damage := 0.0
var cancel_knockback_on_hit := false
@export var status_effects: Array[StatusEffect] = []
var is_status_damage := false
var breading_suppressed := false
var can_be_blocked := true
var explosive_bonus_applied := false
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
	knockback_power = p_source.stats.get_push_force(p_knockback) if p_source is Unit else p_knockback
	source = p_source
	if p_source is Unit:
		for effect in p_source.stats.attack_effects:
			if effect is StatusEffect and not status_effects.has(effect): status_effects.append(effect)


func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		on_hit_hurtbox.emit(area)

func claim_hit(hurtbox: HurtboxComponent) -> bool:
	if not hit_once_per_activation: return true
	var target_id := hurtbox.get_instance_id()
	if _hit_hurtboxes.has(target_id): return false
	if is_instance_valid(projectile) and not projectile.claim_contact(hurtbox): return false
	_hit_hurtboxes[target_id] = true
	return true

func report_damage(target: Unit, amount: float) -> void:
	if amount <= 0.0 or Global.game_paused: return
	if target is Enemy and not weapon_damage_record.is_empty():
		weapon_damage_record.wave_damage += amount
		weapon_damage_record.total_damage += amount
		for share in weapon_damage_record.get("contributors",[]):
			share.record.wave_damage += amount*share.weight
			share.record.total_damage += amount*share.weight
	if target is Enemy and is_instance_valid(source) and source is Player:
		source.try_life_steal(life_steal_chance)
	damage_dealt.emit(target, amount)
	if not weapon_damage_record.is_empty():
		if _breading_handler == null: _breading_handler = load("res://effects/breading_hit.gd")
		_breading_handler.on_damage(self, target, amount)

func roll_target_critical() -> void:
	if not critical_allowed or (source is Player and not ItemWeapon.record_allows_critical(weapon_damage_record, source.stats)):
		critical = false
		damage = base_damage
		return
	if not roll_critical_per_target: return
	critical = Global.get_chance_succes(critical_chance)
	damage = base_damage * (critical_multiplier if critical else 1.0)
