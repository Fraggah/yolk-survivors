extends Area2D
class_name HurtboxComponent

signal on_damage(hitbox: HitboxComponent)

const CONTACT_INTERVAL := 0.5
var contact_cooldowns: Dictionary = {}

func _physics_process(delta: float) -> void:
	if Global.game_paused or not monitoring: return
	var present: Array = []
	for area in get_overlapping_areas():
		if not area is HitboxComponent or not area.continuous_contact: continue
		if not is_instance_valid(area.source) or area.source.is_queued_for_deletion(): continue
		if area.source.health_component.current_health <= 0.0: continue
		var key: int = area.get_instance_id()
		present.append(key)
		contact_cooldowns[key] = maxf(0.0, contact_cooldowns.get(key, 0.0) - delta)
		if contact_cooldowns[key] <= 0.0: _contact_hit(area)
	for key in contact_cooldowns.keys():
		if not present.has(key): contact_cooldowns.erase(key)

func _contact_hit(hitbox: HitboxComponent) -> void:
	if owner is Player and (owner.is_dashing or owner.hit_invulnerability_left > 0.0): return
	contact_cooldowns[hitbox.get_instance_id()] = CONTACT_INTERVAL
	on_damage.emit(hitbox)

func _on_area_entered(area: Area2D) -> void:
	if Global.game_paused or not area is HitboxComponent: return
	if area.continuous_contact: _contact_hit(area)
	else: on_damage.emit(area)
