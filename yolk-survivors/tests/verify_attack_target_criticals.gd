extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var global = root.get_node("Global")
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = arena.weapon_selection_panel.weapons_list[0]
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	var weapon = global.player.current_weapons[0]
	weapon.set_process(false)
	var enemies := []
	for i in 20:
		var enemy = load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
		arena.add_child(enemy)
		enemy.set_process(false)
		enemy.global_position = weapon.global_position + Vector2(40+i*3,20)
		enemy.stats = enemy.stats.duplicate()
		enemy.stats.block_chance = 0
		enemy.health_component.current_health = 100
		enemy.health_component.max_health = 100
		enemies.append(enemy)
	weapon.targets.assign(enemies)
	weapon.update_closest_target()
	weapon.rotate_to_target()
	weapon.use_weapon()
	var aim: float = weapon.rotation
	var old_target = weapon.closest_target
	old_target.health_component.current_health = 0
	weapon.update_closest_target()
	weapon.rotate_to_target()
	assert(weapon.closest_target == old_target and weapon.rotation == aim)
	var before: Vector2 = weapon.global_position
	global.player.position += Vector2(30,0)
	assert(weapon.global_position != before and weapon.rotation == aim)
	await create_timer(0.7).timeout
	assert(not weapon.is_attacking and weapon.sprite_2d.position.is_equal_approx(weapon.atk_start_pos))
	weapon.update_closest_target()
	assert(weapon.closest_target != old_target)
	var hitbox = weapon.weapon_behaviour.hitbox
	hitbox.setup(10,false,0,global.player)
	hitbox.roll_critical_per_target = true
	hitbox.critical_chance = 0.30
	hitbox.critical_multiplier = 2
	hitbox.enable()
	var normal := 0
	var crit := 0
	seed(1234)
	for enemy in enemies.slice(1):
		enemy.health_component.current_health = 100
		var hurtbox = enemy.get_node("HurtboxComponent")
		hurtbox._on_area_entered(hitbox)
		var hp: float = enemy.health_component.current_health
		assert(hp == 90 or hp == 80)
		if hp == 80: crit += 1
		else: normal += 1
		hurtbox._on_area_entered(hitbox)
		assert(enemy.health_component.current_health == hp)
	assert(crit > 0 and normal > 0)
	for mode in [0,1]:
		var projectile = load("res://scenes/projectiles/projectile_pistol.tscn").instantiate()
		arena.add_child(projectile)
		projectile.set_process(false)
		projectile.setup_projectile(Vector2(100,0),10,false,0,global.player,500)
		projectile.remaining_piercing = 25 if mode == 0 else 0
		projectile.remaining_bounces = 25 if mode == 1 else 0
		projectile.hitbox.roll_critical_per_target = true
		projectile.hitbox.critical_chance = 0.30
		projectile.hitbox.critical_multiplier = 2
		var results := {}
		for enemy in enemies.slice(1):
			enemy.health_component.current_health = 100
			var hurtbox = enemy.get_node("HurtboxComponent")
			hurtbox._on_area_entered(projectile.hitbox)
			var hp: float = enemy.health_component.current_health
			results[hp] = true
			hurtbox._on_area_entered(projectile.hitbox)
			assert(enemy.health_component.current_health == hp)
			projectile._on_hitbox_component_on_hit_hurtbox(hurtbox)
		assert(results.has(80.0) and results.has(90.0))
		projectile.queue_free()
	print("PASS locked thrust on dead target, player following, rest/reacquisition, independent criticals and no duplicate hits")
	quit()
