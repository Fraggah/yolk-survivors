extends Enemy
var anchor := Vector2.ZERO
var rest_sprite_scale := Vector2.ONE
var rest_sprite_position := Vector2.ZERO
var idle_clock := 0.0
var animation_settings: Resource
var impact_age := INF
var takeoff_active := false
var takeoff_vertical := 1.0
var shadow_local_rect := Rect2()
func _ready() -> void:
	super._ready()
	anim_player.stop(true)
	rest_sprite_scale = sprite.scale
	rest_sprite_position = sprite.position
	var shadow := $Visuals/Shadow as Sprite2D
	var ink := shadow.texture.get_image().get_used_rect()
	shadow_local_rect = Rect2(shadow.get_rect().position+Vector2(ink.position),Vector2(ink.size))
	set_present(false)
func configure(settings: Resource, at: Vector2) -> void:
	animation_settings = settings
	anchor = at
	global_position = anchor
	stats.damage = settings.contact_damage
	health_component.max_health = settings.total_health
	health_component.current_health = settings.total_health
	$HitboxComponent.setup(settings.contact_damage,false,0,self)
func set_present(enabled: bool) -> void:
	targetable = enabled
	visible = enabled
	if enabled: add_to_group("combat_enemies")
	else: remove_from_group("combat_enemies")
	$HurtboxComponent.collision_layer = 8 if enabled else 0
	$HurtboxComponent.set_deferred("monitoring", enabled)
	$HurtboxComponent.set_deferred("monitorable", enabled)
	$HitboxComponent.collision_layer = 4 if enabled else 0
	# Reactivate shapes as well as masks: this refreshes stationary overlap pairs
	# when the boss returns at the same position as an earlier appearance.
	$HurtboxComponent/CollisionShape2D.set_deferred("disabled", not enabled)
	$HitboxComponent/CollisionShape2D2.set_deferred("disabled", not enabled)
	health_component.vulnerable = enabled
func _process(delta: float) -> void:
	global_position = anchor
	if Global.game_paused: return
	slow_left = maxf(0,slow_left-delta)
	launch_left = maxf(0,launch_left-delta)
	status_controller.refresh_control_text()
	if not visible: return
	idle_clock += delta
	impact_age += delta
	var vertical: float = 1.0 + animation_settings.idle_squash_strength * sin(idle_clock * TAU / animation_settings.idle_squash_period)
	if impact_age < animation_settings.landing_squash_seconds:
		var progress: float = impact_age / animation_settings.landing_squash_seconds
		vertical -= animation_settings.landing_squash_strength * cos(progress * TAU * 1.5) * pow(1.0-progress,2)
	elif not targetable:
		vertical += 0.08 # A little stretch during the fall.
	if takeoff_active: vertical = takeoff_vertical
	sprite.scale = rest_sprite_scale * Vector2(1.0/vertical,vertical)
func receive_hit(hitbox: HitboxComponent) -> bool:
	if not health_component.vulnerable or not targetable: return false
	return super.receive_hit(hitbox)
func _on_health_component_on_unit_died() -> void:
	pass

# Control states remain queryable for synergies without moving or tilting the boss.
func launch_from(hitbox: HitboxComponent) -> void:
	if not targetable or not health_component.vulnerable: return
	launch_left = maxf(launch_left,hitbox.launch_duration)
	launch_velocity = Vector2.ZERO
	status_controller.refresh_control_text()

func pin_for(controller: Node) -> void:
	if not targetable or not health_component.vulnerable: return
	pins[controller.get_instance_id()] = weakref(controller)
	status_controller.refresh_control_text()

func play_landing_squash() -> void:
	takeoff_active = false
	impact_age = 0.0

# The boss scene owns its geometry. Skip regular-enemy resize/facing corrections.
func _apply_size() -> void:
	pass

func update_rotation() -> void:
	pass

func contact_world_radius() -> float:
	var shape := $HitboxComponent/CollisionShape2D2 as CollisionShape2D
	return (shape.shape as CircleShape2D).radius * absf(shape.global_scale.x)

func shadow_world_rect() -> Rect2:
	return $Visuals/Shadow.global_transform * shadow_local_rect

func set_fall_offset(height: float) -> void:
	# Only the body falls. Keep the authored Visuals/shadow transforms untouched.
	sprite.position = rest_sprite_position + Vector2(0,-height)

func set_takeoff_pose(vertical: float, height: float) -> void:
	takeoff_active=true
	takeoff_vertical=vertical
	set_fall_offset(height)
	sprite.scale=rest_sprite_scale*Vector2(1.0/vertical,vertical)
