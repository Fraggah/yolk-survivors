extends Node2D
class_name Weapon

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = %CollisionShape2D
@onready var range_area: Area2D = $RangeArea
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var weapon_behaviour: WeaponBehaviour = $WeaponBehaviour

var data: ItemWeapon
var is_attacking := false
var atk_start_pos : Vector2
var weapon_spread: float

var targets: Array[Enemy]
var closest_target: Enemy

func _ready() -> void:
	atk_start_pos = sprite_2d.position
	center_range_on_player()

func _physics_process(_delta: float) -> void:
	center_range_on_player()

func center_range_on_player() -> void:
	if is_instance_valid(Global.player):
		range_area.global_position = Global.player.global_position

func _process(_delta: float) -> void:
	center_range_on_player()
	if Global.game_paused: return
	
	update_closest_target()
	
	rotate_to_target()
	update_visuals()
	
	if can_use_weapon():
		use_weapon()

func setup_weapon(weapon_data: ItemWeapon) -> void:
	self.data = weapon_data
	collision.shape.radius = weapon_data.stats.max_range
	center_range_on_player()
	apply_tier_outline()

func can_use_weapon() -> bool:
	return cooldown_timer.is_stopped() and not is_attacking and is_instance_valid(closest_target)

func use_weapon() -> void:
	calculate_spread()
	weapon_behaviour.execute_attack()
	cooldown_timer.wait_time = get_effective_cooldown()
	cooldown_timer.start()

func get_effective_cooldown() -> float:
	return data.get_effective_cooldown(Global.player.stats)

func get_animation_time_scale(animation_duration: float) -> float:
	# Leave a small margin so animation completion never delays the next attack.
	return minf(1.0, get_effective_cooldown() * 0.9 / maxf(animation_duration, 0.001))

func rotate_to_target() -> void:
	if is_attacking:
		rotation = get_custom_rotation_to_target()
	else:
		rotation = get_rotation_to_target()

func get_custom_rotation_to_target() -> float:
	if not closest_target or not is_instance_valid(closest_target):
		return rotation
	
	var rot := global_position.direction_to(closest_target.global_position).angle()
	return rot + weapon_spread

func get_rotation_to_target() -> float:
	if not is_instance_valid(closest_target):
		return get_idle_rotation()
	
	var rot := global_position.direction_to(closest_target.global_position).angle()
	return rot


func get_idle_rotation() -> float:
	if Global.player.is_facing_right():
		return 0
	else:
		return PI

func update_closest_target() -> void:
	closest_target = get_closest_target()

func get_closest_target() -> Enemy:
	# Targets come from this weapon's range area; prioritize distance to the
	# player in world coordinates, regardless of the weapon's local slot.
	var origin := Global.player.global_position if is_instance_valid(Global.player) else global_position
	var nearest: Enemy = null
	var nearest_distance_squared := INF
	var world_range := data.stats.max_range * absf(collision.global_scale.x)
	var range_squared := world_range * world_range
	for index in range(targets.size() - 1, -1, -1):
		var target = targets[index]
		if not is_instance_valid(target) or target.is_queued_for_deletion():
			targets.remove_at(index)
			continue
		if target.health_component.current_health <= 0.0:
			continue
		var distance_squared := origin.distance_squared_to(target.global_position)
		if distance_squared > range_squared:
			continue
		if distance_squared < nearest_distance_squared:
			nearest = target
			nearest_distance_squared = distance_squared
	return nearest

func calculate_spread() -> void:
	weapon_spread = randf_range(-1 + data.stats.accuracy, 1 - data.stats.accuracy)
	rotation += weapon_spread

func update_visuals() -> void:
	if abs(rotation) > PI/2:
		sprite_2d.scale.y = -.5
	else:
		sprite_2d.scale.y = .5

func apply_tier_outline() -> void:
	if data.item_tier == Global.UpgradeTier.COMMON:
		sprite_2d.material = null
		return
	
	var outline_color := Global.TIER_COLORS[data.item_tier]
	sprite_2d.material.set_shader_parameter("outline_color", outline_color)

func _on_range_area_area_entered(area: Area2D) -> void:
	if area is Enemy and not targets.has(area):
		targets.push_back(area)


func _on_range_area_area_exited(area: Area2D) -> void:
	targets.erase(area)
	update_closest_target()
