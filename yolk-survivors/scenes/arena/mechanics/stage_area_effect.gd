extends Node2D
class_name StageAreaEffect

var mechanic: StageMechanic
var radius := 100.0
var damage := 3.0
var warning_duration := 1.2
var elapsed := 0.0
var damage_hitbox: HitboxComponent

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	damage_hitbox = HitboxComponent.new()
	damage_hitbox.monitoring = false
	damage_hitbox.monitorable = false
	damage_hitbox.collision_layer = 0
	damage_hitbox.collision_mask = 0
	damage_hitbox.grants_enemy_rewards = false
	add_child(damage_hitbox)
	damage_hitbox.setup(damage, false, 0.0, self)

func damage_units() -> void:
	if not mechanic.active or Global.game_paused: return
	for unit in mechanic.live_units():
		if contains_point(unit.global_position):
			unit._on_hurtbox_component_on_damage(damage_hitbox)
			if not mechanic.active or Global.game_paused: break

func contains_point(point: Vector2) -> bool:
	return global_position.distance_squared_to(point) <= radius * radius

func running() -> bool:
	return is_instance_valid(mechanic) and mechanic.active and not Global.game_paused and not is_queued_for_deletion()
