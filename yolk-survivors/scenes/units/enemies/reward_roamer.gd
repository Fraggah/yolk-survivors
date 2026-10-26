extends "res://scenes/units/enemies/enemy.gd"
## Reward enemies travel straight, selecting a new inward heading at walls.
enum RewardKind { NONE, YOLKS, ITEM }
@export var reward_kind := RewardKind.YOLKS
@export_range(0,1000,1) var minimum_yolks := 10
@export_range(0,1000,1) var maximum_yolks := 25
@export_group("Yolk burst")
@export var burst_min_distance := 150.0
@export var burst_max_distance := 320.0
@export_range(0.1,1.5,0.05) var burst_flight_duration := 0.5
@export_group("Movement and animation")
@export_range(0.2,5.0,0.05) var bounce_period := 1.2
@export var bounce_height := 52.0
@export var wall_padding := 24.0
@export_flags_2d_physics var wall_mask := 1
var travel_direction := Vector2.RIGHT
var animation_clock := 0.0
var _texture_scale := 1.0
var _draw_half := Vector2(70,88)
var _shadow_scale := Vector2.ONE

func _ready() -> void:
	super._ready()
	movement_override_enabled = true
	flock_push = 0.0
	set_meta("incognito_reward",reward_kind==RewardKind.ITEM)
	travel_direction = Vector2.from_angle(randf()*TAU)
	desired_direction = travel_direction
	anim_player.stop()
	# Preserve source art and alpha; normalize its visible bounds at runtime.
	var used := sprite.texture.get_image().get_used_rect()
	_texture_scale = 176.0 / maxf(1.0,used.size.y)
	sprite.offset = sprite.texture.get_size()*0.5-Vector2(used.get_center())
	_draw_half = Vector2(used.size)*_texture_scale*0.5
	_shadow_scale = $Visuals/Shadow.scale
	_animate(0.0)

func roll_yolk_reward() -> int:
	if reward_kind!=RewardKind.YOLKS: return 0
	return randi_range(minimum_yolks,maxi(minimum_yolks,maximum_yolks))

func update_rotation() -> void:
	visuals.scale = Vector2.ONE*0.5*visual_scale

func get_move_direction() -> Vector2:
	return travel_direction

func _inside(point: Vector2) -> bool:
	var padding := wall_padding*visual_scale
	for direction in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
		var sample: Vector2 = point+direction*padding
		if arena_environment:
			if not arena_environment.clamp_position(sample).is_equal_approx(sample): return false
		elif not Rect2(-1000,-500,2000,985).has_point(sample): return false
	return true

func _wall_between(from: Vector2, to: Vector2) -> bool:
	var ray := PhysicsRayQueryParameters2D.create(from,to,wall_mask)
	ray.collide_with_areas = false
	return not get_world_2d().direct_space_state.intersect_ray(ray).is_empty()

func choose_heading() -> void:
	for attempt in 48:
		var candidate := Vector2.from_angle(randf()*TAU)
		var probe := global_position+candidate*maxf(60.0,wall_padding*2.0)
		if _inside(probe) and not _wall_between(global_position,probe):
			travel_direction = candidate
			desired_direction = candidate
			return
	var center := arena_environment.movement_bounds.get_center() if arena_environment else Vector2.ZERO
	travel_direction = global_position.direction_to(center)
	desired_direction = travel_direction

func _process(delta: float) -> void:
	if Global.game_paused or is_retiring or health_component.current_health<=0.0: return
	var moving := can_move and get_movement_multiplier()>0.0 and launch_left<=0.0
	if moving:
		var proposed := global_position+travel_direction*stats.speed*delta*get_movement_multiplier()
		if not _inside(proposed) or _wall_between(global_position,proposed+travel_direction*wall_padding): choose_heading()
	desired_direction = travel_direction
	crowd_steering = Vector2.ZERO
	super._process(delta)
	# Never mirror the '?' toward the player; facing does not control this movement.
	update_rotation()
	if moving: _animate(delta)

func _animate(delta: float) -> void:
	animation_clock += delta
	var phase := fposmod(animation_clock/maxf(0.2,bounce_period),1.0)
	if reward_kind==RewardKind.ITEM:
		# At 0/1 the TOP lands (PI); at 0.5 the BOTTOM lands (TAU).
		var turn := PI+TAU*phase
		var contact := pow(absf(cos(TAU*phase)),14.0)
		var stretch := Vector2(1.0+0.12*contact,1.0-0.12*contact)
		sprite.rotation = turn
		sprite.scale = Vector2.ONE*_texture_scale*stretch
		var extent := absf(cos(turn))*_draw_half.y+absf(sin(turn))*_draw_half.x
		var height := absf(sin(TAU*phase))*bounce_height
		sprite.position = Vector2(0,-extent*stretch.y-height)
		$Visuals/Shadow.scale = _shadow_scale*(1.0-0.3*height/maxf(1,bounce_height))
	else:
		var pulse := sin(animation_clock*6.0)
		sprite.rotation = 0.025*pulse
		sprite.scale = Vector2(1.0+0.035*pulse,1.0-0.035*pulse)*_texture_scale
		sprite.position = Vector2(0,-_draw_half.y*(1.0-0.035*pulse))
