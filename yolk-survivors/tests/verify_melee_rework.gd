extends SceneTree
var arena
var global
func _initialize(): call_deferred("verify")
func make_weapon(id: String, prefix: String = ""):
	if prefix.is_empty(): prefix = id
	var item = load("res://resources/items/weapons/melee/%s/item_%s_1.tres" % [id,prefix]).duplicate()
	item.stats = item.stats.duplicate()
	item.stats.crit_chance = 0.0
	var weapon = item.scene.instantiate()
	global.player.add_child(weapon)
	weapon.setup_weapon(item)
	weapon.position = Vector2(220,0)
	weapon.set_process(false)
	return weapon
func make_enemy(at: Vector2):
	var enemy = load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	arena.add_child(enemy)
	enemy.set_process(false)
	enemy.can_move = false
	enemy.stats = enemy.stats.duplicate()
	enemy.stats.block_chance = 0
	enemy.health_component.current_health = 1000
	enemy.health_component.max_health = 1000
	enemy.global_position = at
	enemy.get_node("HitboxComponent").disable()
	return enemy
func clear(weapon, enemies: Array) -> void:
	weapon.weapon_behaviour.reset_attack()
	weapon.queue_free()
	for enemy in enemies: enemy.queue_free()
	await process_frame
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	global = root.get_node("Global")
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = arena.weapon_selection_panel.weapons_list[0]
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	arena.stage_mechanics.stop()
	global.player.set_process(false)
	global.player.stats.critical_chance = 0
	global.player.health_component.debug_invulnerable = true
	for equipped in global.player.current_weapons:
		equipped.set_process(false)
		equipped.weapon_behaviour.reset_attack()
	var weapon = make_weapon("mace")
	var motion = weapon.weapon_behaviour
	assert(motion.style == 9)
	var enemy = make_enemy(weapon.to_global(Vector2(105,0)))
	weapon.closest_target = enemy
	motion.execute_attack()
	await create_timer(0.18).timeout
	assert(not is_zero_approx(weapon.sprite_2d.rotation), "Mace sweeps an arc")
	await create_timer(0.8).timeout
	assert(enemy.health_component.current_health < 1000)
	await clear(weapon,[enemy])
	weapon = make_weapon("mitten")
	motion = weapon.weapon_behaviour
	var launched = make_enemy(global.player.global_position + Vector2(180,0))
	var struck = make_enemy(global.player.global_position + Vector2(280,0))
	await physics_frame
	await physics_frame
	motion._begin_pulse()
	launched.get_node("HurtboxComponent")._on_area_entered(motion.hitbox)
	motion._end_pulse()
	assert(launched.launch_left > 0)
	launched.set_process(true)
	await create_timer(0.3).timeout
	print("launch target hp/pos ", struck.health_component.current_health, " ", launched.global_position, " remaining ",launched.launch_left, " record ", weapon.damage_record.wave_damage)
	assert(struck.health_component.current_health == 1000 - weapon.data.stats.damage, "Launched body damages each struck enemy once")
	assert(is_equal_approx(weapon.damage_record.wave_damage, weapon.data.stats.damage * (1.0 + motion.glove_direct_damage)))
	await create_timer(0.3).timeout
	assert(launched.launch_left == 0)
	await clear(weapon,[launched,struck])
	weapon = make_weapon("tenderizer")
	motion = weapon.weapon_behaviour
	var early = make_enemy(weapon.to_global(Vector2(20,-10)))
	var final = make_enemy(weapon.to_global(Vector2(weapon.atk_start_pos.x + weapon.data.stats.max_range * 0.85 + 14,0)))
	motion.execute_attack()
	await create_timer(0.7).timeout
	var weak_damage: float = 1000 - early.health_component.current_health
	var strong_damage: float = 1000 - final.health_component.current_health
	print("hammer early/final ",weak_damage,"/",strong_damage)
	assert(weak_damage > 0 and weak_damage < weapon.data.stats.damage)
	assert(strong_damage >= weapon.data.stats.damage * motion.hammer_final_damage)
	assert(motion.hitbox.knockback_power == 0 and final.knockback_power == 0)
	await clear(weapon,[early,final])
	weapon = make_weapon("grater")
	motion = weapon.weapon_behaviour
	enemy = make_enemy(weapon.to_global(Vector2(65,0)))
	var second = make_enemy(enemy.global_position + Vector2(35,0))
	var outside = make_enemy(enemy.global_position + Vector2(180,0))
	weapon.closest_target = enemy
	var locked_position: Vector2 = enemy.global_position
	enemy.can_move = true
	enemy.set_process(true)
	motion.execute_attack()
	global.player.position += Vector2(60,25)
	motion._update_grater_anchor()
	assert(motion.hitbox.bb.global_position.distance_to(motion.grater_anchor) < 1.0, "Grater remains at captured world position when player moves")
	assert(enemy.get_movement_multiplier() == 0 and second.get_movement_multiplier() == 0)
	await create_timer(0.35).timeout
	assert(enemy.global_position.is_equal_approx(locked_position))
	await create_timer(0.65).timeout
	assert(enemy.health_component.current_health == 1000 - weapon.data.stats.damage * 3)
	assert(second.health_component.current_health == 1000 - weapon.data.stats.damage * 3)
	assert(outside.health_component.current_health == 1000)
	assert(enemy.get_movement_multiplier() == 1 and second.get_movement_multiplier() == 1)
	motion.execute_attack()
	var other_grater = make_weapon("grater")
	other_grater.closest_target = enemy
	other_grater.weapon_behaviour.execute_attack()
	motion.reset_attack()
	assert(enemy.get_movement_multiplier() == 0, "A second grater keeps its captured enemies pinned")
	other_grater.weapon_behaviour.reset_attack()
	other_grater.queue_free()
	assert(enemy.pins.is_empty() and second.pins.is_empty())
	await clear(weapon,[enemy,second,outside])
	weapon = make_weapon("carving_fork")
	motion = weapon.weapon_behaviour
	motion.execute_attack()
	await create_timer(0.12).timeout
	assert(not motion.contact_active and weapon.is_attacking, "Fork cannot damage on return")
	await clear(weapon,[])
	for distance in [15.0,140.0]:
		weapon = make_weapon("ladle")
		motion = weapon.weapon_behaviour
		enemy = make_enemy(weapon.to_global(Vector2(distance,0)))
		weapon.closest_target = enemy
		motion.execute_attack()
		assert(motion.hitbox.bb.global_position.distance_to(enemy.get_node("HurtboxComponent/CollisionShape2D").global_position) < 1.0, "Ladle starts at target at either distance")
		await create_timer(0.8).timeout
		assert(enemy.health_component.current_health < 1000, "Ladle hits near and far enemies")
		await clear(weapon,[enemy])
	weapon = make_weapon("frying_pan")
	motion = weapon.weapon_behaviour
	enemy = make_enemy(weapon.to_global(Vector2(15,0)))
	second = make_enemy(weapon.to_global(Vector2(150,35)))
	outside = make_enemy(weapon.to_global(Vector2(450,0)))
	motion.execute_attack()
	await create_timer(0.35).timeout
	assert(enemy.health_component.current_health < 1000, "Pan hits at start")
	assert(second.get_movement_multiplier() == 0.5 and outside.get_movement_multiplier() == 1.0)
	global.game_paused = true
	var time_before: float = second.slow_left
	second.set_process(true)
	await create_timer(0.1,true).timeout
	assert(second.slow_left == time_before)
	global.game_paused = false
	await create_timer(2.2).timeout
	assert(second.get_movement_multiplier() == 1)
	await clear(weapon,[enemy,second,outside])
	weapon = make_weapon("pizza_cutter")
	motion = weapon.weapon_behaviour
	motion._set_roll_progress(0.5)
	enemy = make_enemy(motion.hitbox.bb.global_position)
	motion.reset_attack()
	motion.execute_attack()
	await create_timer(0.65).timeout
	assert(enemy.health_component.current_health == 1000 - weapon.data.stats.damage * 2, "Cutter hits on outgoing and returning arc")
	assert(motion.pulse_count == 2)
	await clear(weapon,[enemy])
	print("PASS mace arc, glove body collision, hammer phases, grater pin/three hits/release, fork outbound, adaptive ladle, pan early hit/slow/expiry/pause, cutter round trip")
	quit()
