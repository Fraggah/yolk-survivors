extends Unit
class_name Enemy

@export var flock_push := 20.0

@onready var vision_area: Area2D = $VisionArea
@onready var knockback_timer: Timer = $KnockbackTimer

var can_move := true
var knockback_dir: Vector2
var knockback_power: float

func _process(delta: float) -> void:
	if not can_move: return
	if not can_move_towards_player(): return
	
	position += (get_move_direction() + knockback_dir * knockback_power) * stats.speed * delta
	update_rotation()

func get_move_direction() -> Vector2:
	if not Global.player:
		return Vector2.ZERO
	
	var direction := global_position.direction_to(Global.player.global_position)
	for area: Area2D in vision_area.get_overlapping_areas():
		if area != self and area.is_inside_tree(): #Check
			var vector := global_position - area.global_position #Direccion opuesta a los otros enemigos
			direction += flock_push * vector.normalized() / vector.length() #Blend de direccion a player y empuje entre enemigos
	
	return direction

func apply_knockback(knock_dir: Vector2, knock_pow: float) -> void:
	knockback_dir = knock_dir
	knockback_power = knock_pow
	if knockback_timer.time_left > 0:
		knockback_timer.stop()
		reset_knockback()
		
	knockback_timer.start()

func reset_knockback() -> void:
	knockback_dir = Vector2.ZERO
	knockback_power = 0

func update_rotation() -> void:
	if not is_instance_valid(Global.player): return
	
	var player_pos := Global.player.global_position
	var moving_right := global_position.x < player_pos.x
	visuals.scale = Vector2(-.5, .5) if moving_right else Vector2(.5, .5)

func can_move_towards_player() -> bool:
	return is_instance_valid(Global.player) and\
	global_position.distance_to(Global.player.global_position) > 60


func _on_knockback_timer_timeout() -> void:
	reset_knockback()

func _on_hurtbox_component_on_damage(hitbox: HitboxComponent) -> void:
	super._on_hurtbox_component_on_damage(hitbox)
	if hitbox.knockback_power > 0:
		var dir:= hitbox.source.global_position.direction_to(global_position) #tomo la direccion del player hacia el enemigo
		apply_knockback(dir, hitbox.knockback_power)
