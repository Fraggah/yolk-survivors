extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	load("res://tests/progression_fixture.gd").prepare(root)
	var global = root.get_node("Global")
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	global.main_player_selected = load("res://resources/units/players/player_well_rounded.tres")
	global.main_weapon_selected = load("res://resources/items/weapons/melee/butcher_knife/item_knife_1.tres")
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	var weapon = global.player.current_weapons[0]
	weapon.set_process(false)
	var motion = weapon.weapon_behaviour
	assert(motion.attack_motion == 1)
	var radius: float = weapon.data.stats.max_range * 0.75
	for angle in [-PI / 2.0, 0.0, PI / 2.0]:
		motion._set_sweep_angle(angle, radius)
		assert(is_equal_approx(weapon.sprite_2d.global_position.distance_to(global.player.global_position), radius * absf(weapon.global_scale.x)))
	motion.execute_attack()
	var aim: float = weapon.rotation
	weapon.rotate_to_target()
	assert(weapon.rotation == aim)
	await create_timer(0.13).timeout
	assert(motion.hitbox.monitoring)
	var hurtbox = load("res://scenes/components/hurtbox_component.gd").new()
	assert(motion.hitbox.claim_hit(hurtbox))
	assert(not motion.hitbox.claim_hit(hurtbox))
	await create_timer(0.4).timeout
	assert(not weapon.is_attacking and not motion.hitbox.monitoring)
	assert(weapon.sprite_2d.position.is_equal_approx(weapon.atk_start_pos))
	assert(is_zero_approx(weapon.sprite_2d.rotation))
	motion.hitbox.enable()
	assert(motion.hitbox.claim_hit(hurtbox))
	motion.hitbox.disable()
	motion.execute_attack()
	await create_timer(0.15).timeout
	global.player.prepare_for_new_wave()
	assert(not weapon.is_attacking)
	assert(weapon.sprite_2d.position.is_equal_approx(weapon.atk_start_pos))
	assert(is_zero_approx(weapon.sprite_2d.rotation))
	await create_timer(0.5).timeout
	assert(weapon.sprite_2d.position.is_equal_approx(weapon.atk_start_pos), "Cancelled attack cannot resume next wave")
	hurtbox.free()
	var thrust = load("res://scenes/weapons/melee/weapon_spatula.tscn").instantiate()
	root.add_child(thrust)
	assert(thrust.weapon_behaviour.attack_motion == 0)
	assert(not thrust.weapon_behaviour.lock_aim_during_attack)
	thrust.queue_free()
	print("PASS: player-centered semicircle, locked aim, one hit per activation, reset and unchanged thrust")
	quit()
