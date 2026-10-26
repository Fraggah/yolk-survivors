extends Node2D
class_name ChargeAttackBehaviour

enum State { PURSUIT, PREPARING, CHARGING, RECOVERING }
@export var enemy: Enemy
@export var anim_player: AnimationPlayer
@export var cooldown := 3.0
@export var preparation_duration := 0.8
@export var recovery_duration := 0.7
@export var charge_speed_multiplier := 5.0
@export var maximum_charge_distance := 650.0
var state := State.PURSUIT
var current_cooldown := 0.0
var state_time := 0.0
var charge_atk_position: Vector2
var charge_direction := Vector2.ZERO
var is_charging: bool:
	get: return state == State.CHARGING

func _ready() -> void:
	current_cooldown = cooldown

func _process(delta: float) -> void:
	if Global.game_paused or enemy.is_retiring or not is_instance_valid(Global.nearest_player(enemy.global_position)): return
	if enemy.get_movement_multiplier() <= 0.0 or enemy.launch_left > 0.0: return
	match state:
		State.PURSUIT:
			current_cooldown -= delta
			if current_cooldown <= 0.0: start_charge()
		State.PREPARING:
			state_time -= delta
			if state_time <= 0.0:
				charge_direction = enemy.global_position.direction_to(Global.nearest_player(enemy.global_position).global_position)
				var distance := minf(maximum_charge_distance, enemy.global_position.distance_to(Global.nearest_player(enemy.global_position).global_position))
				charge_atk_position = enemy.global_position + charge_direction * distance
				if enemy.arena_environment: charge_atk_position = enemy.arena_environment.clamp_position(charge_atk_position)
				enemy.update_rotation()
				state = State.CHARGING
				enemy.sprite.modulate = Color.WHITE
		State.CHARGING:
			enemy.global_position = enemy.global_position.move_toward(charge_atk_position, enemy.stats.speed * charge_speed_multiplier * delta * enemy.get_movement_multiplier())
			if enemy.global_position.distance_to(charge_atk_position) <= 2.0: end_charge()
		State.RECOVERING:
			state_time -= delta
			if state_time <= 0.0:
				state = State.PURSUIT
				current_cooldown = cooldown
				enemy.can_move = true

func start_charge() -> void:
	enemy.can_move = false
	state = State.PREPARING
	state_time = maxf(0.05, preparation_duration)
	# Reuse the existing flashing preparation, retimed to the editable duration.
	anim_player.play("cherge", -1.0, 0.7 / state_time)

func end_charge() -> void:
	state = State.RECOVERING
	state_time = maxf(0.05, recovery_duration)
	enemy.can_move = false
