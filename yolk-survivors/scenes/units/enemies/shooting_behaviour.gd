extends Node2D
class_name ShootingBehaviour

enum State { MOVING, PREPARING, RECOVERING }
@export var enemy: Enemy
@export var fire_pos: Marker2D
@export var cooldown := 2.0
@export_range(1, 20) var projectile_count := 1
@export var arc_angle := 45.0
@export var projectile_scene: PackedScene
@export var projectile_speed := 400.0
@export var projectile_range := 700.0
@export var projectile_damage := 3.0
@export var projectile_damage_per_wave := 0.4
@export var preferred_min_distance := 320.0
@export var preferred_max_distance := 400.0
@export var minimum_firing_distance := 180.0
@export var preparation_duration := 0.5
@export var recovery_duration := 0.35
var damage_multiplier := 1.0
var wave_offset := 0
var state := State.MOVING
var current_cooldown := 0.0
var state_time := 0.0

func _ready() -> void:
	current_cooldown = cooldown
	enemy.movement_override_enabled = true

func _process(delta: float) -> void:
	if Global.game_paused or enemy.is_retiring or not is_instance_valid(Global.player): return
	if enemy.get_movement_multiplier() <= 0.0 or enemy.launch_left > 0.0: return
	var direction := enemy.global_position.direction_to(Global.player.global_position)
	var distance := enemy.global_position.distance_to(Global.player.global_position)
	match state:
		State.MOVING:
			enemy.can_move = true
			enemy.desired_direction = -direction if distance < preferred_min_distance else direction if distance > preferred_max_distance else Vector2.ZERO
			current_cooldown -= delta
			if current_cooldown <= 0.0 and in_firing_position(distance):
				state = State.PREPARING
				state_time = maxf(0.05, preparation_duration)
				enemy.can_move = false
				enemy.sprite.modulate = Color(1.0, 0.8, 0.55)
		State.PREPARING:
			state_time -= delta
			if not in_firing_position(distance):
				finish_shot()
				enemy.desired_direction = -direction if distance < preferred_min_distance else direction
			elif state_time <= 0.0:
				shoot()
				state = State.RECOVERING
				state_time = maxf(0.05, recovery_duration)
				enemy.sprite.modulate = Color.WHITE
		State.RECOVERING:
			if distance < preferred_min_distance:
				finish_shot()
				enemy.desired_direction = -direction
				return
			state_time -= delta
			if state_time <= 0.0: finish_shot()

func finish_shot() -> void:
	state = State.MOVING
	current_cooldown = cooldown
	enemy.can_move = true
	enemy.sprite.modulate = Color.WHITE

func shoot() -> void:
	if not is_instance_valid(Global.player) or enemy.is_retiring or not projectile_scene: return
	if not in_firing_position(enemy.global_position.distance_to(Global.player.global_position)): return
	var direction := fire_pos.global_position.direction_to(Global.player.global_position)
	var start_angle := -arc_angle / 2.0 if projectile_count > 1 else 0.0
	var step_angle := arc_angle / float(projectile_count - 1) if projectile_count > 1 else 0.0
	for i in projectile_count:
		var projectile := projectile_scene.instantiate() as Projectile
		get_tree().current_scene.add_child(projectile)
		projectile.global_position = fire_pos.global_position
		var velocity := direction.rotated(deg_to_rad(start_angle + step_angle * i)) * projectile_speed
		projectile.setup_projectile(velocity, (projectile_damage + projectile_damage_per_wave * wave_offset) * damage_multiplier, false, 0, enemy, projectile_range)

func in_firing_position(distance: float) -> bool:
	return distance >= maxf(minimum_firing_distance, preferred_min_distance) and distance <= minf(projectile_range, preferred_max_distance)
