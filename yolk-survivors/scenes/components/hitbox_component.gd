extends Area2D
class_name HitboxComponent

signal on_hit_hurtbox(hurtbox: HurtboxComponent)

var damage := 1.0
var critical := false
var knockback_power := 0.0
var source: Node2D
var life_steal_chance := 0.0
var continuous_contact := false
var hit_once_per_activation := false
var _hit_hurtboxes: Dictionary = {}
@export var bb: CollisionShape2D

func enable() -> void:
	_hit_hurtboxes.clear()
	set_deferred("monitoring", true)
	bb.set_deferred("disabled", false)

func disable() -> void:
	set_deferred("monitoring", false)
	bb.set_deferred("disabled", true)

func setup(p_damage: float, p_critical: bool, p_knockback: float, p_source: Node2D) -> void:
	damage = p_damage
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
	if target is Enemy and is_instance_valid(source) and source is Player:
		source.try_life_steal(life_steal_chance)
