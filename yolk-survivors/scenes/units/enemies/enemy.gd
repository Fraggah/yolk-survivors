extends Unit
class_name Enemy

@export var flock_push := 20.0
@export var targetable := true
@export var visual_scale := 1.0
@export_range(0.0, 1.0) var knockback_resistance := 0.0
var arena_environment: ArenaEnvironment
var movement_override_enabled := false
var desired_direction := Vector2.ZERO
var crowd_steering := Vector2.ZERO

@onready var vision_area: Area2D = $VisionArea
@onready var knockback_timer: Timer = $KnockbackTimer

var can_move := true
var is_retiring := false
var knockback_dir: Vector2
var knockback_power: float
var pins: Dictionary = {}
var pinned_position := Vector2.ZERO
var slow_left := 0.0
var slow_factor := 1.0
var launch_left := 0.0
var launch_velocity := Vector2.ZERO
var launch_hitbox: HitboxComponent

func pin_for(controller: Node) -> void:
	if pins.is_empty(): pinned_position = global_position
	pins[controller.get_instance_id()] = weakref(controller)
	status_controller.refresh_control_text()
	EnemyCrowd.reset_steering(self)

func release_pin(controller: Node) -> void:
	pins.erase(controller.get_instance_id())
	status_controller.refresh_control_text()
	if pins.is_empty(): EnemyCrowd.reset_steering(self)

func get_movement_multiplier() -> float:
	for id in pins.keys():
		if not is_instance_valid(pins[id].get_ref()): pins.erase(id)
	return 0.0 if not pins.is_empty() else (slow_factor if slow_left > 0.0 else 1.0) * status_movement_multiplier

func apply_slow(factor: float, duration: float, _text_duration: float = 1.3, _text_color: Color = Color("86a9be"), _text_value: String = "Slowed") -> void:
	if duration <= 0.0 or factor >= 1.0: return
	slow_factor = minf(slow_factor if slow_left > 0.0 else 1.0, clampf(factor, 0.0, 1.0))
	slow_left = maxf(slow_left, duration)
	status_controller.refresh_control_text()

func launch_from(hitbox: HitboxComponent) -> void:
	if not is_instance_valid(hitbox.source): return
	var direction := hitbox.launch_direction.normalized() if not hitbox.launch_direction.is_zero_approx() else hitbox.source.global_position.direction_to(global_position)
	launch_velocity = direction * hitbox.launch_speed * (1.0 - knockback_resistance)
	launch_left = hitbox.launch_duration if launch_velocity.length_squared() > 1.0 else 0.0
	if is_instance_valid(launch_hitbox): launch_hitbox.queue_free()
	launch_hitbox = HitboxComponent.new()
	launch_hitbox.collision_layer = 0
	launch_hitbox.collision_mask = 0
	launch_hitbox.monitoring = false
	launch_hitbox.hit_once_per_activation = true
	launch_hitbox.setup(hitbox.launch_damage if hitbox.launch_damage > 0.0 else hitbox.base_damage, false, 0.0, hitbox.source)
	launch_hitbox.weapon_damage_record = hitbox.weapon_damage_record
	launch_hitbox.life_steal_chance = hitbox.life_steal_chance
	add_child(launch_hitbox)
	status_controller.refresh_control_text()

func _move_launched(delta: float) -> void:
	var previous := global_position
	global_position += launch_velocity * delta * get_movement_multiplier()
	if arena_environment: global_position = arena_environment.clamp_position(global_position)
	var travel := global_position - previous
	var radius := 29.0 * visual_scale * absf(global_scale.x)
	var shape := CapsuleShape2D.new()
	shape.radius = radius
	shape.height = travel.length() + radius * 2.0
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(travel.angle() - PI / 2.0, previous + travel * 0.5)
	query.collision_mask = 2
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.exclude = [get_rid()]
	for result in get_world_2d().direct_space_state.intersect_shape(query, 32):
		var other = result.collider
		if other is Enemy and other != self and not other.is_retiring and other.health_component.current_health > 0.0:
			other.get_node("HurtboxComponent")._on_area_entered(launch_hitbox)
	launch_left = maxf(0.0, launch_left - delta)
	if launch_left <= 0.0:
		launch_hitbox.queue_free()
		launch_velocity = Vector2.ZERO
		status_controller.refresh_control_text()

func _ready() -> void:
	super._ready()
	if targetable: add_to_group("combat_enemies")
	_apply_size()
	if targetable:
		EnemyCrowd.register_enemy(self)
		vision_area.set_deferred("monitoring",false)
		vision_area.set_deferred("collision_mask",0)
		vision_area.get_node("CollisionShape2D").set_deferred("disabled",true)
	update_rotation()
	var contact := get_node_or_null("HitboxComponent") as HitboxComponent
	if contact:
		contact.setup(stats.damage, false, 0.0, self)
		contact.continuous_contact = true
		# Player hurtboxes monitor contact hitboxes; the reverse listener is unused.
		contact.set_deferred("monitoring",false)
		contact.set_deferred("collision_mask",0)

func _process(delta: float) -> void:
	if Global.game_paused: return
	if is_retiring or health_component.current_health <= 0.0: return
	slow_left = maxf(0.0, slow_left - delta)
	var movement_multiplier := get_movement_multiplier()
	if movement_multiplier <= 0.0:
		if not pins.is_empty(): global_position = pinned_position
		return
	if launch_left > 0.0:
		_move_launched(delta)
		return

	if not can_move: return
	var player := Global.player
	var player_valid := is_instance_valid(player)
	var origin := global_position
	var player_position := player.global_position if player_valid else origin
	var offset := player_position-origin
	var stop_distance := 60.0*visual_scale
	if not movement_override_enabled and (not player_valid or offset.length_squared()<=stop_distance*stop_distance) and knockback_power<=0.0: return
	var direction := Vector2.ZERO
	if player_valid:
		direction = desired_direction if movement_override_enabled else offset.normalized()
		if targetable: direction = (direction+crowd_steering).limit_length(1.0)
	var next_position := origin + (direction + knockback_dir * knockback_power) * stats.speed * delta * movement_multiplier
	if arena_environment:
		next_position = arena_environment.clamp_position(next_position)
	# One transform write also avoids moving all attached physics Areas twice.
	global_position = next_position
	if player_valid:
		var facing_scale := Vector2(-0.5,0.5)*visual_scale if next_position.x<player_position.x else Vector2(0.5,0.5)*visual_scale
		if visuals.scale != facing_scale: visuals.scale = facing_scale

func _apply_size() -> void:
	# Scale the visual container, outside animation tracks; root movement stays unchanged.
	visuals.scale = Vector2.ONE * 0.5 * visual_scale
	for path in ["CollisionShape2D", "VisionArea/CollisionShape2D", "HurtboxComponent/CollisionShape2D", "HitboxComponent/CollisionShape2D2"]:
		var collision := get_node_or_null(path) as CollisionShape2D
		if not collision or not collision.shape: continue
		collision.shape = collision.shape.duplicate()
		collision.position *= visual_scale
		if collision.shape is CircleShape2D:
			(collision.shape as CircleShape2D).radius *= visual_scale
	# The root represents the separation body, rather than the former tiny point.
	var body := get_node("CollisionShape2D") as CollisionShape2D
	(body.shape as CircleShape2D).radius = 29.0 * visual_scale
	flock_push *= visual_scale

func get_move_direction() -> Vector2:
	if not is_instance_valid(Global.player):
		return Vector2.ZERO

	var direction := desired_direction if movement_override_enabled else global_position.direction_to(Global.player.global_position)
	if targetable: direction = (direction+crowd_steering).limit_length(1.0)

	return direction

func apply_knockback(knock_dir: Vector2, knock_pow: float) -> void:
	knockback_dir = knock_dir.normalized()
	knockback_power = maxf(0.0, knock_pow) * (1.0 - knockback_resistance)
	knockback_timer.start()

func reset_knockback() -> void:
	knockback_dir = Vector2.ZERO
	knockback_power = 0

func update_rotation() -> void:
	if not is_instance_valid(Global.player): return

	var player_pos := Global.player.global_position
	var moving_right := global_position.x < player_pos.x
	var facing_scale := Vector2(-.5, .5) * visual_scale if moving_right else Vector2(.5, .5) * visual_scale
	if visuals.scale != facing_scale: visuals.scale = facing_scale

func can_move_towards_player() -> bool:
	return is_instance_valid(Global.player) and\
	global_position.distance_squared_to(Global.player.global_position) > pow(60 * visual_scale,2)

func destroy_enemy() -> void:
	if is_retiring or is_queued_for_deletion(): return
	is_retiring = true
	can_move = false
	health_component.current_health = 0.0
	for path in ["ChargeAttackBehaviour", "ShootingBehaviour"]:
		var behavior := get_node_or_null(path)
		if behavior: behavior.process_mode = Node.PROCESS_MODE_DISABLED
	# Cleanup may animate during a paused intermission, without combat collisions.
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	for component in [get_node("HurtboxComponent"), get_node("HitboxComponent")]:
		component.set_deferred("monitoring", false)
		component.set_deferred("monitorable", false)
	anim_player.stop()
	get_node("HealthBar").hide()
	var retirement := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	retirement.set_ignore_time_scale(true)
	retirement.tween_property(self, "scale", Vector2.ZERO, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await retirement.finished
	load("res://effects/arena_bursts.gd").emit_at(self, global_position)
	queue_free()


func _on_knockback_timer_timeout() -> void:
	reset_knockback()

func _on_hurtbox_component_on_damage(hitbox: HitboxComponent) -> void:
	if not receive_hit(hitbox): return
	if hitbox.cancel_knockback_on_hit: reset_knockback()
	if hitbox.launch_on_hit and health_component.current_health > 0.0: launch_from(hitbox)
	var impact_direction := Vector2.RIGHT
	if is_instance_valid(hitbox.source):
		impact_direction = hitbox.source.global_position.direction_to(global_position)
		if impact_direction.is_zero_approx(): impact_direction = Vector2.RIGHT
	EnemyHitFeedback.emit_hit(get_instance_id(), sprite.global_position, impact_direction, hitbox.critical)
	if hitbox.knockback_power > 0 and is_instance_valid(hitbox.source):
		var dir:= hitbox.source.global_position.direction_to(global_position) #tomo la direccion del player hacia el enemigo
		apply_knockback(dir, hitbox.knockback_power)


func _on_health_component_on_unit_died() -> void:
	Global.on_enemy_died.emit(self)
