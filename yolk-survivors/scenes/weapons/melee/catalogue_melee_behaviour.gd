extends MeleBehaviour
## Catalogue attacks share damage/critical/life-steal handling, but own their motion.
enum Style { HAMMER, GRATER, FORK, LADLE, PAN, CUTTER, ELECTRIC_KNIFE, MINIPIMER, WHISK, MACE, GLOVE }
@export var style: Style = Style.HAMMER
var tuning: MeleeSettings:
	get: return weapon.data.stats.melee_settings
# Read-only compatibility access; all editable values live in the tier resource.
var glove_direct_damage: float:
	get: return tuning.direct_damage_multiplier
var hammer_final_damage: float:
	get: return tuning.final_damage_multiplier
var pan_slow_radius: float:
	get: return tuning.slow_radius
var contact_active := false
var pulse_count := 0
var rotor_angle := 0.0
var captured_enemies: Array[Enemy] = []
var attack_distance := 0.0
var swing_side := 1.0
var attack_angle := 0.0
var previous_contact := Vector2.ZERO
var grater_world_locked := false
var grater_anchor := Vector2.ZERO
var grater_offset := Vector2.ZERO
var grater_angle := 0.0
var roll_returning := false
var ladle_start_point := Vector2.ZERO
var ladle_travel_direction := Vector2.RIGHT
var ladle_secondary_target: Enemy

func _ready() -> void:
	super._ready()
	z_index = 3
	if style == Style.GRATER: hitbox.collision_layer = 0

func _process(delta: float) -> void:
	if Global.game_paused: return
	if grater_world_locked: _update_grater_anchor()
	if style == Style.CUTTER or style == Style.MINIPIMER:
		if contact_active: rotor_angle += delta * tuning.rotor_speed
		queue_redraw()

func _draw() -> void:
	if not contact_active or (style != Style.CUTTER and style != Style.MINIPIMER): return
	# A rotating blade glint keeps the grip stable while the working end spins.
	var sprite := weapon.sprite_2d
	var center := sprite.position + tuning.rotor_center.rotated(sprite.rotation) * absf(sprite.scale.x)
	var radius := tuning.rotor_radius * absf(sprite.scale.x)
	draw_arc(center, radius, rotor_angle, rotor_angle + tuning.rotor_arc, 8, tuning.rotor_color, tuning.rotor_width, true)

func _physics_process(_delta: float) -> void:
	if Global.game_paused or not contact_active: return
	if style == Style.GRATER:
		for enemy in captured_enemies:
			if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
				enemy.get_node("HurtboxComponent")._on_area_entered(hitbox)
		return
	_swept_contacts()
	# Repeated attacks can hit an enemy that remains inside the blade between pulses.
	# The activation ledger still prevents physics-entry and overlap polling duplicates.
	for area in hitbox.get_overlapping_areas():
		if area is HurtboxComponent: area._on_area_entered(hitbox)

func execute_attack() -> void:
	weapon.is_attacking = true
	pulse_count = 0
	var tween := create_attack_tween()
	match style:
		Style.HAMMER: _hammer(tween)
		Style.GRATER: _scrape(tween)
		Style.FORK: _jabs(tween)
		Style.LADLE: _ladle(tween)
		Style.PAN: _slam(tween)
		Style.CUTTER: _roll(tween)
		Style.ELECTRIC_KNIFE: _jabs(tween)
		Style.MINIPIMER: _blend(tween)
		Style.WHISK: _jabs(tween)
		Style.MACE: _mace(tween)
		Style.GLOVE: _jabs(tween)

	var stats := weapon.data.stats
	tween.tween_callback(_end_pulse)
	tween.tween_callback(_release_captured)
	tween.tween_property(weapon.sprite_2d, "position", weapon.atk_start_pos, stats.back_duration * _timing())
	tween.parallel().tween_property(weapon.sprite_2d, "rotation", 0.0, stats.back_duration * _timing())
	tween.finished.connect(func():
		weapon.is_attacking = false
		critical = false
	)

func _timing() -> float:
	# All profiles are at most 0.95 seconds before recovery; attack speed scales
	# their whole cycle, including intervals between individual contact pulses.
	var timing := weapon.get_animation_time_scale(tuning.timing_reference + weapon.data.stats.back_duration)
	return timing / maxf(0.01, tuning.animation_speed)

func _tip(distance: float) -> Vector2:
	return weapon.atk_start_pos + Vector2(distance, 0)

func _begin_pulse(damage_multiplier: float = 1.0, knockback: float = -1.0) -> void:
	if style == Style.GLOVE: damage_multiplier *= tuning.direct_damage_multiplier
	hitbox.setup(get_base_damage() * damage_multiplier, false, weapon.data.stats.knockback if knockback < 0.0 else knockback, weapon.get_parent())
	configure_hit_criticals(hitbox)
	hitbox.life_steal_chance = get_life_steal_chance()
	hitbox.weapon_damage_record = weapon.damage_record
	hitbox.launch_on_hit = style == Style.GLOVE
	hitbox.launch_speed = tuning.launch_speed
	hitbox.launch_duration = tuning.launch_duration
	hitbox.launch_damage = get_base_damage() * tuning.collision_damage_multiplier if style == Style.GLOVE else 0.0
	hitbox.cancel_knockback_on_hit = style == Style.HAMMER and knockback == 0.0
	hitbox.enable()
	contact_active = true
	previous_contact = hitbox.bb.global_position
	pulse_count += 1

func _end_pulse() -> void:
	if contact_active and style != Style.GRATER and not Global.game_paused: _swept_contacts()
	contact_active = false
	hitbox.disable()

func _swept_contacts() -> void:
	var current := hitbox.bb.global_position
	var travel := current - previous_contact
	var radius := 8.0
	if hitbox.bb.shape is RectangleShape2D:
		var extent := (hitbox.bb.shape as RectangleShape2D).size * hitbox.bb.global_scale.abs()
		radius = minf(extent.x, extent.y) * 0.5
	var shape := CapsuleShape2D.new()
	shape.radius = maxf(2.0, radius)
	shape.height = travel.length() + shape.radius * 2.0
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(travel.angle() - PI / 2.0, previous_contact + travel * 0.5)
	query.collision_mask = 8
	query.collide_with_areas = true
	query.collide_with_bodies = false
	for result in weapon.get_world_2d().direct_space_state.intersect_shape(query, 64):
		var area = result.collider
		if area is HurtboxComponent and area.get_parent() is Enemy: area._on_area_entered(hitbox)
	previous_contact = current

func _slam(tween: Tween) -> void:
	var timing := _timing()
	tween.tween_property(weapon.sprite_2d, "rotation", deg_to_rad(tuning.raised_angle), tuning.preparation_duration * timing).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(weapon.sprite_2d, "position", _tip(tuning.windup_offset), tuning.preparation_duration * timing)
	tween.tween_callback(_begin_pulse)
	tween.tween_callback(_hit_near_start)
	tween.tween_property(weapon.sprite_2d, "position", _tip(weapon.data.stats.max_range * tuning.reach_multiplier), tuning.forward_duration * timing).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(weapon.sprite_2d, "rotation", 0.0, tuning.forward_duration * timing)
	tween.tween_callback(_pan_impact)
	tween.tween_interval(tuning.contact_duration * timing)
	tween.tween_callback(_end_pulse)

func _jabs(tween: Tween) -> void:
	var count := tuning.hit_count
	var timing := _timing()
	var distance := weapon.data.stats.max_range * tuning.reach_multiplier
	tween.tween_property(weapon.sprite_2d, "position", _tip(tuning.windup_offset), tuning.preparation_duration * timing)
	for index in count:
		tween.tween_callback(_begin_pulse)
		var offset := Vector2(0, (1 if index % 2 == 0 else -1) * tuning.lateral_offset) if style == Style.WHISK else Vector2.ZERO
		tween.tween_property(weapon.sprite_2d, "position", _tip(distance) + offset, tuning.forward_duration * timing)
		if tuning.contact_duration > 0.0: tween.tween_interval(tuning.contact_duration * timing)
		tween.tween_callback(_end_pulse)
		tween.tween_property(weapon.sprite_2d, "position", _tip(distance * tuning.repeated_retract_multiplier if count > 1 else 0.0), tuning.return_duration * timing)

func _scrape(tween: Tween) -> void:
	var timing := _timing()
	_release_captured()
	var center := weapon.closest_target.global_position if is_instance_valid(weapon.closest_target) else hitbox.global_position
	for enemy in weapon.get_tree().get_nodes_in_group("combat_enemies"):
		if enemy is Enemy and not enemy.is_retiring and enemy.health_component.current_health > 0.0 and enemy.global_position.distance_to(center) <= tuning.capture_radius * absf(weapon.global_scale.x):
			captured_enemies.append(enemy)
			enemy.pin_for(self)
	grater_anchor = weapon.closest_target.get_node("HurtboxComponent/CollisionShape2D").global_position if is_instance_valid(weapon.closest_target) else center
	grater_angle = weapon.global_rotation
	grater_offset = Vector2.ZERO
	grater_world_locked = true
	tween.tween_method(_set_grater_offset, Vector2.ZERO, tuning.scrape_start, tuning.preparation_duration * timing)
	for index in tuning.hit_count:
		tween.tween_callback(_begin_pulse)
		tween.tween_method(_set_grater_offset, tuning.scrape_start, tuning.scrape_end, tuning.forward_duration * timing)
		tween.parallel().tween_property(weapon.sprite_2d, "rotation", tuning.scrape_rotation, tuning.forward_duration * timing)
		tween.tween_callback(_end_pulse)
		tween.tween_method(_set_grater_offset, tuning.scrape_end, tuning.scrape_start, tuning.return_duration * timing)
		tween.parallel().tween_property(weapon.sprite_2d, "rotation", -tuning.scrape_rotation, tuning.return_duration * timing)

func _ladle(tween: Tween) -> void:
	var timing := _timing()
	var point := weapon.to_local(weapon.closest_target.get_node("HurtboxComponent/CollisionShape2D").global_position) if is_instance_valid(weapon.closest_target) else Vector2(weapon.data.stats.max_range * tuning.reach_multiplier, 0)
	attack_distance = point.length()
	ladle_start_point = point
	attack_angle = point.angle()
	ladle_secondary_target = _second_ladle_target()
	ladle_travel_direction = Vector2.from_angle(attack_angle + deg_to_rad(tuning.fallback_angle))
	if is_instance_valid(ladle_secondary_target):
		var next_point := weapon.to_local(ladle_secondary_target.get_node("HurtboxComponent/CollisionShape2D").global_position)
		if next_point.distance_squared_to(point) > 0.001:
			ladle_travel_direction = point.direction_to(next_point)
	_set_ladle_progress(0.0)
	tween.tween_callback(_begin_pulse)
	tween.tween_interval(tuning.contact_duration * timing)
	tween.tween_method(_set_ladle_progress, 0.0, 1.0, tuning.forward_duration * timing)
	tween.tween_callback(_end_pulse)

func _set_ladle_angle(angle: float) -> void:
	angle += attack_angle
	var head_offset := hitbox.bb.position * absf(weapon.sprite_2d.scale.x)
	weapon.sprite_2d.position = Vector2.from_angle(angle) * attack_distance - head_offset.rotated(angle)
	weapon.sprite_2d.rotation = angle

func _roll(tween: Tween) -> void:
	var timing := _timing()
	roll_returning = false
	tween.tween_property(weapon.sprite_2d, "rotation", 0.0, tuning.preparation_duration * timing)
	tween.tween_callback(_begin_pulse)
	tween.tween_method(_set_roll_progress, 0.0, 1.0, tuning.forward_duration * timing)
	tween.tween_interval(tuning.pause_duration * timing)
	tween.tween_callback(_end_pulse)
	tween.tween_callback(_start_roll_return)
	tween.tween_method(_set_roll_progress, 1.0, 0.0, tuning.return_duration * timing)
	tween.tween_callback(_end_pulse)

func _set_roll_progress(progress: float) -> void:
	var reach := weapon.data.stats.max_range * tuning.reach_multiplier
	if roll_returning:
		var angle := deg_to_rad(tuning.cutter_return_angle)
		weapon.sprite_2d.position = weapon.atk_start_pos + Vector2(reach, 0) - Vector2.from_angle(angle) * reach * (1.0 - progress)
		weapon.sprite_2d.rotation = angle
	else:
		weapon.sprite_2d.position = weapon.atk_start_pos + Vector2(progress * reach, 0)
		weapon.sprite_2d.rotation = 0.0

func _start_roll_return() -> void:
	roll_returning = true
	_begin_pulse()

func _second_ladle_target() -> Enemy:
	if not is_instance_valid(Global.player): return null
	var origin := Global.player.global_position
	var radius := weapon.data.stats.max_range * absf(weapon.global_scale.x)
	var eligible: Array[Enemy] = []
	for enemy in weapon.get_tree().get_nodes_in_group("combat_enemies"):
		if enemy is Enemy and enemy.targetable and not enemy.is_queued_for_deletion() and not enemy.is_retiring and enemy.health_component.current_health > 0.0 and enemy.global_position.distance_squared_to(origin) <= radius * radius:
			eligible.append(enemy)
	eligible.sort_custom(func(a: Enemy, b: Enemy):
		var first := a.global_position.distance_squared_to(origin)
		var second := b.global_position.distance_squared_to(origin)
		return first < second if not is_equal_approx(first,second) else a.get_instance_id() < b.get_instance_id()
	)
	if eligible.size() < 2: return null
	if eligible[1] != weapon.closest_target: return eligible[1]
	# The weapon slot's nearest target can differ from the player's nearest.
	return eligible[0] if eligible[0] != weapon.closest_target else null

func _set_ladle_progress(progress: float) -> void:
	var offset := ladle_travel_direction * weapon.data.stats.max_range * progress
	var orientation := lerp_angle(attack_angle, ladle_travel_direction.angle(), progress)
	var head_offset := hitbox.bb.position * absf(weapon.sprite_2d.scale.x)
	weapon.sprite_2d.position = ladle_start_point + offset - head_offset.rotated(orientation)
	weapon.sprite_2d.rotation = orientation

func _set_grater_offset(offset: Vector2) -> void:
	grater_offset = offset
	_update_grater_anchor()

func _update_grater_anchor() -> void:
	var head_offset := hitbox.bb.position * absf(weapon.sprite_2d.scale.x)
	var world_point := grater_anchor + grater_offset.rotated(grater_angle) * absf(weapon.global_scale.x)
	weapon.sprite_2d.position = weapon.to_local(world_point) - head_offset.rotated(weapon.sprite_2d.rotation)

func _release_captured() -> void:
	grater_world_locked = false
	for enemy in captured_enemies:
		if is_instance_valid(enemy): enemy.release_pin(self)
	captured_enemies.clear()

func _hit_near_start() -> void:
	for enemy in weapon.get_tree().get_nodes_in_group("combat_enemies"):
		if enemy is Enemy and enemy.global_position.distance_to(weapon.global_position) <= tuning.close_hit_radius * absf(weapon.global_scale.x):
			enemy.get_node("HurtboxComponent")._on_area_entered(hitbox)

func _pan_impact() -> void:
	var center := hitbox.bb.global_position
	var radius := pan_slow_radius * absf(weapon.global_scale.x)
	var effect = load("res://effects/pan_slow_burst.gd")
	for enemy in weapon.get_tree().get_nodes_in_group("combat_enemies"):
		if enemy is Enemy and not enemy.is_retiring and effect.contains_offset(enemy.global_position - center, radius, tuning.effect_y_ratio):
			enemy.apply_slow(tuning.slow_factor, weapon.data.stats.slow_duration, tuning.status_text_duration, tuning.status_text_color, tuning.status_text)
	var burst = effect.new()
	weapon.get_tree().current_scene.add_child(burst)
	burst.global_position = center
	burst.radius = radius
	burst.duration = tuning.effect_duration
	burst.opacity = tuning.effect_opacity
	burst.y_ratio = tuning.effect_y_ratio
	burst.color = tuning.effect_color
	burst.ring_width = tuning.ring_width
	burst.spark_width = tuning.spark_width
	burst.spark_length = tuning.spark_length
	burst.spark_count = tuning.spark_count
	burst.ring_start_radius = tuning.ring_start_radius
	burst.spark_start_radius = tuning.spark_start_radius

func _hammer(tween: Tween) -> void:
	var timing := _timing()
	tween.tween_property(weapon.sprite_2d, "rotation", deg_to_rad(tuning.raised_angle), tuning.preparation_duration * timing)
	tween.parallel().tween_property(weapon.sprite_2d, "position", _tip(tuning.windup_offset), tuning.preparation_duration * timing)
	tween.tween_callback(_begin_pulse.bind(tuning.early_damage_multiplier, tuning.early_knockback))
	tween.tween_property(weapon.sprite_2d, "position", _tip(weapon.data.stats.max_range * tuning.reach_multiplier), tuning.forward_duration * timing)
	tween.parallel().tween_property(weapon.sprite_2d, "rotation", 0.0, tuning.forward_duration * timing)
	tween.tween_callback(_end_pulse)
	tween.tween_callback(_begin_pulse.bind(tuning.final_damage_multiplier, tuning.final_knockback))
	tween.tween_interval(tuning.contact_duration * timing)
	tween.tween_callback(_end_pulse)

func _mace(tween: Tween) -> void:
	var timing := _timing()
	attack_distance = weapon.data.stats.max_range * tuning.reach_multiplier
	attack_angle = weapon.to_local(weapon.closest_target.get_node("HurtboxComponent/CollisionShape2D").global_position).angle() if is_instance_valid(weapon.closest_target) else 0.0
	tween.tween_method(_set_ladle_angle, 0.0, deg_to_rad(tuning.sweep_start_angle), tuning.preparation_duration * timing)
	tween.tween_callback(_begin_pulse)
	tween.tween_method(_set_ladle_angle, deg_to_rad(tuning.sweep_start_angle), deg_to_rad(tuning.sweep_end_angle), tuning.forward_duration * timing)
	tween.tween_callback(_end_pulse)

func _blend(tween: Tween) -> void:
	var timing := _timing()
	var contact := _tip(weapon.data.stats.max_range * tuning.reach_multiplier)
	tween.tween_property(weapon.sprite_2d, "position", contact, tuning.preparation_duration * timing)
	for index in tuning.hit_count:
		tween.tween_callback(_begin_pulse)
		tween.tween_property(weapon.sprite_2d, "rotation", tuning.blend_rotation, tuning.forward_duration * timing)
		tween.parallel().tween_property(weapon.sprite_2d, "position", contact + Vector2(0, tuning.blend_offset), tuning.forward_duration * timing)
		tween.tween_property(weapon.sprite_2d, "rotation", -tuning.blend_rotation, tuning.return_duration * timing)
		tween.parallel().tween_property(weapon.sprite_2d, "position", contact - Vector2(0, tuning.blend_offset), tuning.return_duration * timing)
		tween.tween_callback(_end_pulse)

func reset_attack() -> void:
	contact_active = false
	roll_returning = false
	_release_captured()
	rotor_angle = 0.0
	queue_redraw()
	super.reset_attack()

func _exit_tree() -> void:
	_release_captured()
