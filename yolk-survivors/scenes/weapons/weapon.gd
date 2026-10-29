extends Node2D
class_name Weapon

const VISUAL_SCALE := 0.75
@export var attack_sound: AudioStream
@export var impact_sound: AudioStream
@export var continuous_sound: AudioStream

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = %CollisionShape2D
@onready var range_area: Area2D = $RangeArea
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var weapon_behaviour: WeaponBehaviour = $WeaponBehaviour

var data: ItemWeapon
static var damage_records: Array[Dictionary] = []
var damage_record: Dictionary = {}

static func begin_damage_wave() -> void:
	for record in damage_records: record.wave_damage = 0.0

static func finish_damage_wave() -> void:
	for record in damage_records: record.last_wave_damage = record.wave_damage
var is_attacking := false
var sprite_base_scale: Vector2
var atk_start_pos : Vector2
var weapon_spread: float

var targets: Array[Enemy]
var closest_target: Enemy
var spatial_target: Enemy
var spatial_target_deadline := 0.0

func _ready() -> void:
	range_area.set_deferred("monitoring",false)
	range_area.set_deferred("collision_mask",0)
	collision.set_deferred("disabled",true)
	sprite_2d.scale *= VISUAL_SCALE
	sprite_2d.position *= VISUAL_SCALE
	sprite_base_scale = sprite_2d.scale
	atk_start_pos = sprite_2d.position
	center_range_on_weapon()

func _physics_process(_delta: float) -> void:
	center_range_on_weapon()

func center_range_on_weapon() -> void:
	range_area.position = Vector2.ZERO

func _process(_delta: float) -> void:
	var started := Time.get_ticks_usec() if FireContacts.profile_enabled else 0
	_advance_weapon(_delta)
	FireContacts.finish_profile("weapon_updates",started)

func _advance_weapon(_delta: float) -> void:
	center_range_on_weapon()
	if Global.game_paused: return
	
	update_closest_target()
	
	rotate_to_target()
	update_visuals()
	
	if can_use_weapon():
		use_weapon()

func setup_weapon(weapon_data: ItemWeapon) -> void:
	self.data = weapon_data
	if damage_record.is_empty():
		damage_record = {"weapon": weapon_data, "instance_id": get_instance_id(), "wave_damage": 0.0, "last_wave_damage": 0.0, "total_damage": 0.0}
		damage_records.append(damage_record)
	damage_record["impact_sound"] = impact_sound
	damage_record["impact_event"] = "weapon_impact:"+scene_file_path
	collision.shape = collision.shape.duplicate()
	_refresh_range()
	if get_parent() is Unit and not get_parent().stats.stats_changed.is_connected(_refresh_range):
		get_parent().stats.stats_changed.connect(_refresh_range)
	center_range_on_weapon()
	apply_tier_outline()
	load("res://effects/golden_visual.gd").apply_weapon(self)

func get_effective_range() -> float:
	return data.get_effective_range(get_parent().stats if get_parent() is Unit else null)

func _refresh_range() -> void:
	collision.shape.radius = get_effective_range()
	spatial_target_deadline = 0.0

func can_use_weapon() -> bool:
	return cooldown_timer.is_stopped() and not is_attacking and is_instance_valid(closest_target)

func use_weapon() -> void:
	SoundManager.play_weapon_attack(self)
	calculate_spread()
	weapon_behaviour.execute_attack()
	cooldown_timer.wait_time = get_effective_cooldown()
	cooldown_timer.start()

func get_effective_cooldown() -> float:
	return data.get_effective_cooldown(get_parent().stats)

func get_animation_time_scale(animation_duration: float) -> float:
	# Leave a small margin so animation completion never delays the next attack.
	return minf(1.0, get_effective_cooldown() * data.stats.animation_cooldown_fraction / maxf(animation_duration, 0.001))

func rotate_to_target() -> void:
	if is_attacking and weapon_behaviour.lock_aim_during_attack:
		return
	if is_attacking:
		rotation = get_custom_rotation_to_target()
	else:
		rotation = get_rotation_to_target()

func get_custom_rotation_to_target() -> float:
	if not closest_target or not is_instance_valid(closest_target):
		return rotation
	
	var rot := global_position.direction_to(closest_target.get_aim_position()).angle()
	return rot + weapon_spread

func get_rotation_to_target() -> float:
	if not is_instance_valid(closest_target):
		return get_idle_rotation()
	
	var rot := global_position.direction_to(closest_target.get_aim_position()).angle()
	return rot


func get_idle_rotation() -> float:
	if get_parent().is_facing_right():
		return 0
	else:
		return PI

func update_closest_target() -> void:
	if is_attacking and weapon_behaviour.lock_aim_during_attack: return
	closest_target = get_closest_target()

func get_closest_target() -> Enemy:
	var origin := global_position
	var nearest: Enemy = null
	var nearest_distance_squared := INF
	var world_range := get_effective_range() * absf(collision.global_scale.x)
	var range_squared := world_range * world_range
	if targets.is_empty():
		if EnemyCrowd.clock<spatial_target_deadline and is_instance_valid(spatial_target) and spatial_target.targetable and not spatial_target.is_queued_for_deletion() and not spatial_target.is_retiring and spatial_target.health_component.current_health>0 and origin.distance_squared_to(spatial_target.global_position)<=range_squared:
			return spatial_target
		spatial_target = EnemyCrowd.nearest(origin,world_range) as Enemy
		spatial_target_deadline = EnemyCrowd.clock+0.06
		return spatial_target
	for index in range(targets.size() - 1, -1, -1):
		var target = targets[index]
		if not is_instance_valid(target) or target.is_queued_for_deletion():
			targets.remove_at(index)
			continue
		if not target.targetable or target.is_retiring: continue
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
		sprite_2d.scale.y = -absf(sprite_base_scale.y)
	else:
		sprite_2d.scale.y = absf(sprite_base_scale.y)

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
