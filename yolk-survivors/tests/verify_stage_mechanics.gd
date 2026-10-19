extends SceneTree

var arena
var global
var player

func _initialize() -> void: call_deferred("verify")

func stage(id: String):
	return arena.environment_controller.stages.filter(func(resource): return str(resource.id) == id)[0]

func activate(id: String):
	arena.spawner.clear_enemies()
	arena.environment_controller.selected_stages[1] = stage(id)
	arena.spawner.wave_index = 1
	global.game_paused = false
	arena.spawner.start_wave()
	arena.spawner.spawn_timer.stop()
	arena.wave_active = true
	player.position = stage(id).play_area.movement_bounds.get_center()
	player.hit_invulnerability_left = 0
	player.health_component.setup(player.stats)
	if arena.stage_mechanics.current_mechanic: arena.stage_mechanics.current_mechanic.set_process(false)
	return arena.stage_mechanics.current_mechanic

func test_enemy(at: Vector2, hp: float = 50.0):
	var profile = load("res://resources/wave/enemies/chaser_mid.tres")
	var enemy = profile.scene.instantiate()
	arena.spawner.prepare_enemy(enemy, profile)
	enemy.stats.health = hp
	enemy.stats.block_chance = 0
	arena.add_child(enemy)
	enemy.global_position = at
	enemy.set_process(false)
	enemy.get_node("HitboxComponent").disable()
	arena.spawner.spawned_enemies.append(enemy)
	return enemy

func verify() -> void:
	load("res://tests/progression_fixture.gd").prepare(root)
	arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	global = root.get_node("Global")
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = arena.weapon_selection_panel.weapons_list[0]
	arena.start_panel.hide()
	arena._on_level_selected(0)
	player = global.player
	player.stats.health = 100.0
	player.stats.block_chance = 0
	player.set_process(false)
	player.get_node("HPTimer").stop()
	for weapon in player.current_weapons: weapon.set_process(false)
	await process_frame
	assert(activate("neutral_plate") == null)
	for wave in arena.spawner.waves_data:
		assert(wave.hazard_limit == 0)
		for group in wave.groups + wave.events:
			for profile in group.enemies: assert(str(profile.id) != "fueguito")
	var pan = activate("nonstick_pan")
	pan._process(0.99)
	assert(pan.pending == 0 and pan.hazards.is_empty())
	pan._process(0.02)
	assert(pan.pending == 1 and pan.state == pan.State.ENTERING)
	assert(pan.get_child_count() == 1 and pan.get_children()[0].get_child_count() == 1)
	pan._process(pan.flare_duration - 0.01)
	assert(pan.hazards.is_empty())
	pan._process(0.02)
	assert(pan.hazards.size() == 1)
	var flame = pan.hazards[0]
	assert(not flame.targetable and not flame.is_in_group("combat_enemies"))
	var hp: float = flame.health_component.current_health
	flame.health_component.take_damage(10000)
	assert(flame.health_component.current_health == hp)
	assert(flame.stats.coin_drop == 0 and flame.stats.experience_reward == 0)
	pan._process(4.99)
	assert(pan.hazards.size() == 1)
	global.game_paused = true
	pan._process(2)
	assert(pan.hazards.size() == 1)
	global.game_paused = false
	pan._process(0.02)
	assert(pan.hazards.is_empty() and flame.is_retiring and not flame.visible)
	assert(pan.state == pan.State.EXITING)
	pan._process(pan.flare_duration)
	assert(pan.state == pan.State.RESTING)
	pan._process(pan.rest_duration - pan.flare_duration * 2 + 0.001)
	assert(pan.pending == 2 and pan.batch_size == 2 and pan.hazards.is_empty())
	pan._process(pan.flare_duration)
	assert(pan.hazards.size() == 2)
	pan.hazards[0].set_process(false)
	pan.hazards[1].set_process(false)
	var together: Vector2 = player.position + Vector2(150, 0)
	pan.hazards[0].position = together
	pan.hazards[1].position = together
	pan.separate_hazards(0.1)
	assert(pan.hazards[0].position.distance_to(pan.hazards[1].position) > 0)
	pan._process(5)
	pan._process(pan.flare_duration)
	pan._process(pan.rest_duration - pan.flare_duration * 2 + 0.001)
	assert(pan.pending == 3 and pan.batch_size == 3)
	pan._process(pan.flare_duration)
	assert(pan.hazards.size() == 3)
	pan._process(5)
	pan._process(pan.flare_duration)
	pan._process(pan.rest_duration - pan.flare_duration * 2 + 0.001)
	assert(pan.pending == 4)
	arena.spawner.clear_enemies()
	await process_frame
	assert(not is_instance_valid(flame) and get_nodes_in_group("spawn_effects").is_empty())
	assert(arena.stage_mechanics.get_child_count() == 0)
	assert(activate("neutral_plate") == null)
	var pot = activate("cooking_pot")
	for index in 3:
		var bubble = pot.spawn_bubble(index)
		assert(bubble != null and bubble.radius == pot.radii[index])
		assert(bubble.damage == pot.damages[index] and is_equal_approx(bubble.warning_duration, pot.explosion_times[index] / 1.5))
		assert(bubble.dome.scale.x < bubble.sprite_scale * 0.2 and not bubble.splash.visible)
		bubble.set_process(false)
		bubble.queue_free()
		await process_frame
	var bubble = pot.spawn_bubble(1)
	bubble.set_process(false)
	player.position = bubble.global_position
	var enemy = test_enemy(bubble.global_position, 3)
	var outside = test_enemy(bubble.global_position + Vector2(200, 0))
	var previous_xp: int = arena.run_experience.experience
	var previous_gold: int = arena.gold_list.size()
	var record = player.current_weapons[0].damage_record
	var weapon_damage: float = record.total_damage
	bubble._process(bubble.warning_duration * 0.74)
	assert(player.health_component.current_health == 100 and enemy.health_component.current_health == 3)
	global.game_paused = true
	bubble._process(5)
	assert(not bubble.exploded)
	global.game_paused = false
	bubble._process(bubble.warning_duration * 0.02)
	assert(bubble.exploded and player.health_component.current_health == 96)
	assert(bubble.elapsed < bubble.warning_duration, "Red bubble detonates early when stepped on")
	assert(bubble.splash.visible and not bubble.dome.visible)
	assert(is_equal_approx(bubble.burst_duration, 0.05))
	assert(enemy.health_component.current_health == 0 and outside.health_component.current_health == 50)
	assert(arena.run_experience.experience == previous_xp and arena.gold_list.size() == previous_gold and record.total_damage == weapon_damage)
	await process_frame
	# Environmental damage must not suppress rewards for a later real weapon kill.
	outside.global_position = bubble.global_position
	bubble.damage_units()
	assert(not outside.last_hit_grants_rewards and outside.health_component.current_health == 46)
	var normal = load("res://scenes/components/hitbox_component.gd").new()
	normal.setup(100, false, 0, player)
	outside._on_hurtbox_component_on_damage(normal)
	assert(arena.run_experience.experience == previous_xp + outside.stats.experience_reward)
	normal.free()
	var red_preview = pot.spawn_bubble(0)
	red_preview.set_process(false)
	var player_before_red: Vector2 = player.global_position
	player.global_position = red_preview.global_position + Vector2(red_preview.radius+100,0)
	red_preview._process(red_preview.warning_duration*0.8)
	assert(red_preview.is_red() and not red_preview.exploded)
	assert(red_preview.dome.modulate == Color("f05b53"))
	red_preview._process(red_preview.warning_duration*0.21)
	assert(red_preview.exploded, "Untouched red bubble still explodes on schedule")
	red_preview.queue_free()
	player.global_position = player_before_red
	var crowded = activate("cooking_pot")
	for attempt in 40: crowded.spawn_bubble()
	assert(crowded.live_effect_count() == 12)
	var bubbles = crowded.get_children().filter(func(child): return child.has_method("damage_units"))
	for i in bubbles.size():
		for j in range(i + 1, bubbles.size()):
			assert(bubbles[i].global_position.distance_to(bubbles[j].global_position) >= bubbles[i].radius + bubbles[j].radius + crowded.minimum_gap)
	var griddle = activate("iron_griddle")
	assert(griddle.initial_delay == 0.8 and griddle.minimum_interval == 0.9 and griddle.maximum_interval == 1.5)
	griddle._process(0.79)
	assert(griddle.live_effect_count() == 0)
	griddle._process(0.02)
	assert(griddle.live_effect_count() == 1 and griddle.next_zone >= 0.9 and griddle.next_zone <= 1.5)
	for child in griddle.get_children():
		if child.has_method("damage_units"): child.queue_free()
	await process_frame
	var zone = griddle.spawn_zone()
	zone.set_process(false)
	assert(zone.radius == 350 and zone.active_duration == 12 and griddle.maximum_zones == 6)
	assert(zone.air.size.y == 880 and zone.air.z_index == 5 and not zone.air.visible)
	assert(zone.air.material.get_shader_parameter("strength_pixels") == griddle.distortion_strength_pixels)
	assert(zone.ground.material.get_shader_parameter("shape_phase") == zone.shape_phase)
	for step in 32:
		var angle := TAU * step / 32.0
		var edge: float = zone.radius * zone.shape_radius(angle) * zone.damage_core_ratio
		assert(zone.contains_point(zone.global_position + Vector2.from_angle(angle) * edge * 0.99))
		assert(not zone.contains_point(zone.global_position + Vector2.from_angle(angle) * edge * 1.01))
		assert(not zone.contains_point(zone.global_position + Vector2.from_angle(angle) * zone.radius * zone.shape_radius(angle) * 0.8), "Visual halo must not deal damage")
	zone.elapsed = 0.2
	zone.update_visuals()
	var breath_start = zone.ground.material.get_shader_parameter("breath")
	zone.elapsed += zone.breathing_period * 0.5
	zone.update_visuals()
	assert(is_equal_approx(zone.ground.material.get_shader_parameter("breath"), 1.0 - breath_start))
	zone.elapsed = 0
	zone.update_visuals()
	# Leave enough space for a second large patch in this fixture.
	zone.global_position = Vector2(griddle.area.movement_bounds.position.x + zone.radius + 20, griddle.area.movement_bounds.get_center().y)
	griddle.maximum_zones = 2
	var second_zone = griddle.spawn_zone()
	assert(second_zone != null and griddle.spawn_zone() == null)
	second_zone.set_process(false)
	assert(zone.global_position.distance_to(second_zone.global_position) >= zone.radius * zone.damage_core_ratio + second_zone.radius * second_zone.damage_core_ratio + griddle.minimum_zone_gap)
	assert(not griddle.is_zone_position_free(zone.global_position, 20))
	assert(not griddle.is_zone_position_free(second_zone.global_position, 350))
	second_zone.queue_free()
	assert(griddle.is_zone_position_free(second_zone.global_position, 350))
	griddle.radius = 1000
	assert(griddle.spawn_zone() == null)
	griddle.radius = 350
	griddle.maximum_zones = 6
	player.position = zone.global_position
	enemy = test_enemy(zone.global_position)
	var halo_enemy = test_enemy(zone.global_position + Vector2.RIGHT * zone.radius * zone.shape_radius(0) * 0.8)
	zone._process(0.99)
	assert(player.health_component.current_health == 100)
	player.is_dashing = true
	zone._process(0.02)
	assert(zone.air.visible)
	global.game_paused = true
	var phase = zone.air.material.get_shader_parameter("phase")
	zone._process(3)
	assert(zone.air.material.get_shader_parameter("phase") == phase)
	global.game_paused = false
	assert(player.health_component.current_health == 100 and enemy.health_component.current_health == 48)
	assert(halo_enemy.health_component.current_health == 50, "Heat outside the bright core must be harmless")
	player.is_dashing = false
	zone._process(0.2)
	assert(enemy.health_component.current_health == 48)
	# Block chance is capped at 70%; the default block mitigates 50%, not all damage.
	player.stats.block_chance = 100
	player.stats.block_effectiveness = 50
	zone._process(0.56)
	assert(player.health_component.current_health in [98.0, 99.0] and enemy.health_component.current_health == 46)
	player.health_component.current_health = 100
	player.hit_invulnerability_left = 0.0
	player.stats.block_chance = 0
	zone._process(0.76)
	assert(player.health_component.current_health == 98 and enemy.health_component.current_health == 44)
	zone._process(zone.active_duration)
	assert(zone.state == zone.State.COOLING and player.health_component.current_health == 98)
	var dense_heat = activate("iron_griddle")
	for attempt in 40: dense_heat.spawn_zone()
	assert(dense_heat.live_effect_count() >= 4 and dense_heat.live_effect_count() <= 6)
	var heat_zones = dense_heat.get_children().filter(func(child): return child.has_method("damage_units"))
	for i in heat_zones.size():
		for j in range(i + 1, heat_zones.size()):
			assert(heat_zones[i].global_position.distance_to(heat_zones[j].global_position) >= (heat_zones[i].radius + heat_zones[j].radius) * dense_heat.damage_core_ratio + dense_heat.minimum_zone_gap)
	var wok = activate("deep_wok")
	var center: Vector2 = wok.area.movement_bounds.get_center()
	assert(wok.force_at(center) == Vector2.ZERO)
	var radii: Vector2 = wok.area.movement_bounds.size * 0.5
	# The light floor is neutral; the newly playable dark slope applies force.
	var floor_center: Vector2 = wok.safe_zone_bounds.get_center()
	var floor_radii: Vector2 = wok.safe_zone_bounds.size * 0.5
	for step in 32:
		var direction := Vector2.from_angle(TAU * step / 32.0)
		assert(wok.force_at(floor_center + direction * floor_radii * 0.99) == Vector2.ZERO)
		var slope := floor_center + direction * floor_radii * 1.12
		assert(wok.area.clamp_position(slope).is_equal_approx(slope))
		assert(wok.force_at(slope).dot(floor_center - slope) > 0)
	var near: Vector2 = center + Vector2(radii.x * 0.75, 0)
	var edge: Vector2 = center + Vector2(radii.x * 0.98, 0)
	assert(wok.force_at(edge).length() > wok.force_at(near).length() and wok.force_at(edge).x < 0)
	player.position = edge
	enemy = test_enemy(edge + Vector2(0, 15))
	enemy.knockback_dir = Vector2.RIGHT
	enemy.knockback_power = 0.7
	var before: Vector2 = player.position
	player.is_dashing = true
	wok._process(0.1)
	assert(player.position.x < before.x and player.position.distance_to(before) <= wok.maximum_force * 0.1 + 0.01)
	assert(enemy.position.x < edge.x and enemy.knockback_power == 0.7)
	assert(wok.maximum_force == 450 and wok.force_at(edge).length() > player.stats.speed)
	var previous_strength := 0.0
	for fraction in [0.70, 0.75, 0.80, 0.90, 0.98]:
		var strength: float = wok.force_at(center + Vector2(radii.x * fraction, 0)).length()
		assert(strength > previous_strength)
		previous_strength = strength
	player.position = edge
	wok.apply_force(player, 0.1)
	assert(is_equal_approx(player.position.distance_to(edge), wok.force_at(edge).length() * 0.1))
	global.game_paused = true
	before = player.position
	wok._process(1)
	assert(player.position == before)
	global.game_paused = false
	player.is_dashing = false
	var tray = activate("oven_tray")
	assert(tray.initial_delay == 1.5 and tray.minimum_interval == 2 and tray.maximum_interval == 3)
	tray.begin_strike()
	assert(tray.contains_head(player.position), "Tracking must aim a solid strip at the player")
	assert(tray.shadow.visible and tray.spatula.visible and tray.state == tray.State.TRACKING)
	var initial_target: Vector2 = tray.impact.position
	player.position += Vector2(150, 80)
	tray._process(0.4)
	assert(tray.impact.position != initial_target and tray.pushes.is_empty())
	assert(tray.impact.position.distance_to(tray.target_position()) > 1, "Following must lag behind movement")
	tray._process(tray.tracking_duration)
	assert(tray.state == tray.State.LOCKED)
	var locked_target: Vector2 = tray.impact.position
	player.position += Vector2(100, 0)
	tray._process(0.2)
	assert(tray.impact.position == locked_target and tray.pushes.is_empty())
	assert(tray.lock_duration == 1.0 and is_equal_approx(tray.fall_duration, 0.07 / 1.5))
	var full_shadow_scale: Vector2 = tray.shadow.scale
	var still_spatula: Vector2 = tray.spatula.position
	tray._process(0.29)
	assert(tray.shadow.scale == full_shadow_scale and tray.spatula.position == still_spatula)
	assert(tray.impact.position == locked_target and tray.state == tray.State.LOCKED)
	tray._process(0.45)
	assert(tray.state == tray.State.LOCKED and tray.shadow.scale.x < full_shadow_scale.x)
	assert(tray.impact.position == locked_target and tray.pushes.is_empty())
	var shadow_head_center: Vector2 = tray.shadow.position + (tray.HEAD_PIXELS.position + tray.HEAD_PIXELS.size * 0.5) * tray.shadow.scale
	assert(shadow_head_center.is_equal_approx(tray.impact.get_center()))
	player.position = tray.impact.position + tray.impact.size * Vector2(0.37, 0.5)
	assert(tray.contains_head(player.position))
	enemy = test_enemy(player.position + Vector2(5, 20))
	assert(tray.contains_head(enemy.position))
	outside = test_enemy(tray.impact.get_center() + Vector2(tray.impact.size.x + 20, 0))
	var outside_position: Vector2 = outside.position
	assert(not tray.contains_head(tray.impact.get_center()), "Transparent central slot is not part of impact")
	before = player.position
	tray._process(tray.lock_duration)
	assert(tray.state == tray.State.FALLING and tray.pushes.is_empty())
	tray._process(tray.fall_duration + 0.01)
	assert(tray.shadow.scale.is_equal_approx(full_shadow_scale))
	assert(tray.pushes.size() == 2 and tray.camera.shake_left > 0)
	tray._process(0.1)
	assert(player.position.y < before.y)
	assert(outside.position == outside_position and player.health_component.current_health == 60 and enemy.health_component.current_health == 50)
	tray.strike()
	assert(player.health_component.current_health == 60, "Only one damage application per strike")
	global.game_paused = true
	before = player.position
	var shake_left: float = tray.camera.shake_left
	tray._process(1)
	tray.camera._process(1)
	assert(player.position == before and tray.camera.shake_left == shake_left)
	global.game_paused = false
	tray.camera._process(0.05)
	assert(tray.camera.offset != Vector2.ZERO)
	tray._process(tray.hold_duration)
	assert(tray.state == tray.State.RETRACTING)
	tray._process(tray.retract_duration)
	assert(tray.state == tray.State.WAITING and not tray.spatula.visible and not tray.shadow.visible)
	assert(tray.next_event >= 2 and tray.next_event <= 3)
	player.stats.health = 200
	player.health_component.setup(player.stats)
	player.health_component.current_health = 100
	player.hit_invulnerability_left = 0
	tray.begin_strike()
	tray.strike()
	assert(player.health_component.current_health == 20, "Damage is 40% of maximum health, not current health")
	tray.begin_strike()
	player.hit_invulnerability_left = 0
	player.is_dashing = true
	tray.strike()
	assert(player.health_component.current_health == 20, "Dash must protect against the hit")
	player.is_dashing = false
	arena.spawner.wave_timer.stop()
	arena.spawner.clear_enemies()
	await process_frame
	assert(arena.stage_mechanics.current_mechanic == null and arena.stage_mechanics.get_child_count() == 0)
	assert(arena.get_node("Camera2D").offset == Vector2.ZERO)
	# Wave completion, reset, death and retry use the real lifecycle callbacks.
	activate("iron_griddle").spawn_zone()
	arena.spawner._on_wave_timer_timeout()
	await process_frame
	assert(arena.stage_mechanics.current_mechanic == null and arena.stage_mechanics.get_child_count() == 0)
	await create_timer(1.1).timeout
	arena.upgrade_panel.hide()
	arena.shop_panel.hide()
	activate("deep_wok")
	arena.spawner.reset_run(0)
	await process_frame
	assert(arena.stage_mechanics.current_mechanic == null and arena.stage_mechanics.get_child_count() == 0)
	activate("oven_tray").begin_strike()
	player.health_component.take_damage(1000)
	await create_timer(2.1, true, false, true).timeout
	await process_frame
	assert(global.player == null and arena.stage_mechanics.current_mechanic == null and arena.stage_mechanics.get_child_count() == 0)
	arena._on_final_button_pressed()
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = arena.weapon_selection_panel.weapons_list[0]
	arena.selection_panel.hide()
	arena._on_level_selected(0)
	player = global.player
	activate("cooking_pot")
	await process_frame
	assert(arena.stage_mechanics.get_child_count() == 1)
	activate("cooking_pot").spawn_bubble()
	arena.set_wave_paused(true)
	assert(arena.stage_mechanics.current_mechanic.live_effect_count() == 1)
	arena._on_pause_panel_on_exit_pressed()
	await process_frame
	assert(arena.stage_mechanics.current_mechanic == null and arena.stage_mechanics.get_child_count() == 0)
	arena.queue_free()
	await process_frame
	print("PASS: base neutrality, exclusive/indestructible capped Fueguito, bubble warning/radii/rewards, periodic heat/dash/block, progressive wok/control/knockback, spatula tracking/lock/fall/shader slots/retreat/shake/no damage, pause and complete cleanup")
	quit()
