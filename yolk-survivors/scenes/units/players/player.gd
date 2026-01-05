extends Unit
class_name Player

var move_dir: Vector2

@export var dash_duration := .5
@export var dash_speed_multi := 2.5
@export var dash_cooldown := 2.0

@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var collision: CollisionShape2D = $CollisionShape2D

var is_dashing: bool

func _ready() -> void:
	dash_timer.wait_time = dash_duration
	dash_cooldown_timer.wait_time = dash_cooldown


func _process(delta: float) -> void:
	move_dir = Input.get_vector("move_left","move_right","move_up","move_down")
	
	var current_velocity := move_dir * stats.speed
	if is_dashing:
		current_velocity *= dash_speed_multi

	
	position += current_velocity * delta
	
	update_animations()
	update_rotation()
	
	if can_dash():
		start_dash()

func start_dash() -> void:
	is_dashing = true
	dash_timer.start()
	visuals.modulate.a = .5
	collision.set_deferred("disabled", true)

func can_dash() -> bool:
	return not is_dashing and\
	dash_cooldown_timer.is_stopped() and\
	Input.is_action_just_pressed("dash") and\
	move_dir != Vector2.ZERO

func update_animations() -> void:
	if move_dir.length() > 0:
		anim_player.play("move")
	else:
		anim_player.play("idle")


func update_rotation() -> void:
	if move_dir == Vector2.ZERO:
		return
	
	if move_dir.x >= .1:
		visuals.scale = Vector2(-.5, .5)
	elif move_dir.x < 0:
		visuals.scale = Vector2(.5, .5)


func _on_dash_timer_timeout() -> void:
	is_dashing = false
	visuals.modulate.a = 1
	#move_dir = Vector2.ZERO reset??
	dash_cooldown_timer.start()
	collision.set_deferred("disabled", false)
