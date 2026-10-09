extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func wait_frames(count: int = 3) -> void:
	for frame in count: await physics_frame

func verify() -> void:
	load("res://tests/progression_fixture.gd").prepare(root)
	var global = root.get_node("Global")
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	global.main_player_selected = load("res://resources/units/players/player_well_rounded.tres")
	global.main_weapon_selected = load("res://resources/items/weapons/melee/spatula/item_spatula_1.tres")
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	var player = global.player
	player.stats.health = 100.0
	player.stats.block_chance = 0.0
	player.stats.life_steal = 100.0
	player.health_component.setup(player.stats)
	player.health_component.current_health = 50.0
	player.get_node("HPTimer").stop()
	player.position = Vector2.ZERO
	var melee = player.current_weapons[0]
	melee.set_process(false)
	player.add_weapon(load("res://resources/items/weapons/range/hydrant/item_hydrant_1.tres"))
	var ranged = player.current_weapons[1]
	ranged.set_process(false)
	var charger = load("res://scenes/units/enemies/enemy_charger.tscn").instantiate()
	charger.stats = charger.stats.duplicate()
	charger.stats.health = 1000000.0
	charger.stats.damage = 7.0
	arena.add_child(charger)
	charger.position = Vector2(650, 150)
	charger.set_process(false)
	var charge = charger.get_node("ChargeAttackBehaviour")
	charge.set_process(false)
	var contact = charger.get_node("HitboxComponent")
	assert(contact.damage == 7.0 and contact.continuous_contact)
	# Misses and attack startup cannot pay life steal; only effective hits do.
	ranged.weapon_behaviour.execute_attack()
	assert(player.health_component.current_health == 50.0)
	var shot = get_nodes_in_group("projectiles").back()
	assert(shot.hitbox.life_steal_chance == 1.0)
	charger._on_hurtbox_component_on_damage(shot.hitbox)
	assert(player.health_component.current_health == 51.0)
	charger._on_hurtbox_component_on_damage(shot.hitbox)
	assert(player.health_component.current_health == 51.0, "Shared lifesteal frequency cap")
	await create_timer(0.12).timeout
	charger._on_hurtbox_component_on_damage(shot.hitbox)
	assert(player.health_component.current_health == 52.0)
	charger.stats.block_chance = 100.0
	player.life_steal_cooldown = 0.0
	var before = charger.health_component.current_health
	charger._on_hurtbox_component_on_damage(shot.hitbox)
	assert(charger.health_component.current_health == before and player.health_component.current_health == 52.0)
	charger.stats.block_chance = 0.0
	charger.health_component.current_health = 0.0
	charger._on_hurtbox_component_on_damage(shot.hitbox)
	assert(player.health_component.current_health == 52.0)
	charger.health_component.current_health = 1000000.0
	# Melee also pays only when its active hitbox actually deals damage.
	player.life_steal_cooldown = 0.0
	melee.weapon_behaviour.execute_attack()
	assert(player.health_component.current_health == 52.0)
	await create_timer(0.12).timeout
	charger._on_hurtbox_component_on_damage(melee.weapon_behaviour.hitbox)
	assert(player.health_component.current_health == 53.0)
	await create_timer(0.5).timeout
	player.health_component.current_health = 52.0
	# Pause in the middle of real attacks, dash, projectiles and charger telegraph.
	for projectile in get_nodes_in_group("projectiles"): projectile.queue_free()
	await process_frame
	player.move_dir = Vector2.RIGHT
	player.start_dash()
	melee.weapon_behaviour.execute_attack()
	ranged.weapon_behaviour.execute_attack()
	charge.start_charge()
	await create_timer(0.06).timeout
	var projectile = get_nodes_in_group("projectiles").back()
	player.get_node("HPTimer").wait_time = 0.3
	player.get_node("HPTimer").start()
	var regen_left = player.get_node("HPTimer").time_left
	player.hit_invulnerability_left = 0.4
	player.life_steal_cooldown = 0.08
	var dash_left = player.dash_timer.time_left
	var wave_left = arena.spawner.wave_timer.time_left
	var melee_pos = melee.sprite_2d.position
	var ranged_pos = ranged.sprite_2d.position
	var projectile_pos = projectile.position
	var charge_anim = charge.anim_player.current_animation_position
	var charger_pos = charger.position
	arena.set_wave_paused(true)
	assert(paused and arena.pause_panel.visible)
	await create_timer(0.65).timeout
	assert(is_equal_approx(player.dash_timer.time_left, dash_left) and player.is_dashing)
	assert(is_equal_approx(player.get_node("HPTimer").time_left, regen_left))
	assert(player.hit_invulnerability_left == 0.4 and player.life_steal_cooldown == 0.08)
	player.get_node("HPTimer").stop()
	assert(is_equal_approx(arena.spawner.wave_timer.time_left, wave_left))
	assert(melee.sprite_2d.position.is_equal_approx(melee_pos) and ranged.sprite_2d.position.is_equal_approx(ranged_pos))
	assert(projectile.position.is_equal_approx(projectile_pos))
	assert(is_equal_approx(charge.anim_player.current_animation_position, charge_anim))
	charge.is_charging = true
	charge.charge_atk_position = charger.position + Vector2(500, 0)
	charge._process(0.2)
	assert(charger.position == charger_pos)
	player._on_hurtbox_component_on_damage(contact)
	assert(player.health_component.current_health == 52.0)
	arena.set_wave_paused(false)
	await create_timer(0.7).timeout
	assert(not player.is_dashing and not melee.is_attacking and not ranged.is_attacking)
	assert(player.dash_cooldown_timer.time_left > 0.0)
	# A running dash cooldown also freezes, and resumes from the same remaining time.
	var cooldown = player.dash_cooldown_timer.time_left
	arena.set_wave_paused(true)
	await create_timer(0.2).timeout
	assert(is_equal_approx(player.dash_cooldown_timer.time_left, cooldown))
	arena.set_wave_paused(false)
	# Invulnerability is shared across different simultaneous enemies.
	player.hit_invulnerability_left = 0.0
	player._on_hurtbox_component_on_damage(contact)
	var damaged = player.health_component.current_health
	assert(damaged == 45.0)
	player._on_hurtbox_component_on_damage(contact)
	assert(player.health_component.current_health == damaged)
	await create_timer(0.55).timeout
	player._on_hurtbox_component_on_damage(contact)
	assert(player.health_component.current_health == damaged - 7.0)
	player.hit_invulnerability_left = 0.0
	player.start_dash()
	player._on_hurtbox_component_on_damage(contact)
	assert(player.health_component.current_health == damaged - 7.0)
	await create_timer(0.55).timeout
	# An enemy that stays overlapping must deal periodic contact damage.
	charger.position = player.position
	charge.is_charging = false
	await wait_frames()
	var touching = player.health_component.current_health
	await wait_frames(45)
	assert(player.health_component.current_health < touching)
	charger.position = Vector2(600, 0)
	await wait_frames()
	# Reapplication retains the latest knockback instead of erasing it.
	charger.apply_knockback(Vector2.RIGHT, 1.0)
	charger.apply_knockback(Vector2.LEFT, 2.0)
	assert(charger.knockback_dir == Vector2.LEFT and charger.knockback_power == 2.0)
	var knock_left = charger.knockback_timer.time_left
	arena.set_wave_paused(true)
	await create_timer(0.5).timeout
	assert(charger.knockback_power == 2.0 and is_equal_approx(charger.knockback_timer.time_left, knock_left))
	arena.set_wave_paused(false)
	await create_timer(0.5).timeout
	assert(charger.knockback_power == 0.0)
	# Coincident neighbors produce a finite steering direction.
	var other = load("res://scenes/units/enemies/enemy_chaser.tscn").instantiate()
	arena.add_child(other)
	other.set_process(false)
	other.position = charger.position
	await wait_frames()
	assert(charger.get_move_direction().is_finite())
	# Intermission cleanup runs while paused, without surviving combat colliders.
	arena.spawner.spawned_enemies.append(charger)
	arena.spawner.spawned_enemies.append(other)
	arena.spawner.wave_timer.stop()
	arena._on_spawner_on_wave_completed()
	await create_timer(1.15).timeout
	assert(arena.upgrade_panel.visible and global.game_paused)
	assert(not is_instance_valid(charger) and not is_instance_valid(other))
	assert(get_nodes_in_group("projectiles").is_empty())
	arena._on_upgrade_selected()
	assert(arena.shop_panel.visible)
	arena._on_shop_panel_on_shop_next_wave()
	arena.spawner.spawn_timer.stop()
	assert(not global.game_paused and not paused and not player.is_dashing)
	assert(player.health_component.current_health == player.stats.health)
	arena.set_wave_paused(true)
	arena._on_pause_panel_on_exit_pressed()
	await process_frame
	assert(global.game_paused and global.player == null and arena.start_panel.visible)
	global.main_player_selected = load("res://resources/units/players/player_well_rounded.tres")
	global.main_weapon_selected = load("res://resources/items/weapons/melee/spatula/item_spatula_1.tres")
	arena._on_level_selected(0)
	assert(not paused and global.player.hit_invulnerability_left == 0.0 and global.player.life_steal_cooldown == 0.0)
	# Actual fatal contact leaves no stale player reference and permits retry.
	var fresh_player = global.player
	fresh_player.health_component.current_health = 1.0
	var fatal = load("res://scenes/units/enemies/enemy_chaser.tscn").instantiate()
	arena.add_child(fatal)
	fatal.position = Vector2(900, 0)
	fatal.set_process(false)
	fresh_player._on_hurtbox_component_on_damage(fatal.get_node("HitboxComponent"))
	assert(global.player == null and global.game_paused and arena.final_screen.visible)
	assert(arena.spawner.wave_timer.is_stopped() and arena.spawner.spawn_timer.is_stopped())
	fatal.queue_free()
	await process_frame
	arena._on_final_button_pressed()
	global.main_player_selected = load("res://resources/units/players/player_well_rounded.tres")
	global.main_weapon_selected = load("res://resources/items/weapons/melee/spatula/item_spatula_1.tres")
	arena._on_level_selected(0)
	arena.spawner.wave_index = 10
	arena.spawner.start_wave()
	arena.spawner.spawn_timer.stop()
	arena.spawner.wave_timer.stop()
	arena._on_spawner_on_wave_completed()
	await create_timer(1.15).timeout
	assert(arena.final_screen.visible and arena.final_label.text == "YOU WIN!")
	assert(global.player == null and global.game_paused and global.level_reached == 1)
	assert(arena.spawner.fueguito == null)
	arena._on_final_button_pressed()
	await create_timer(6.5).timeout
	arena.queue_free()
	await process_frame
	print("PASS: effective-hit lifesteal/cap/block/dead/miss, scaled contact/repeated overlap, shared invulnerability, dash immunity, physics/tween/timer pause, knockback refresh, finite separation, wave/shop/exit/retry/death/victory")
	quit()
