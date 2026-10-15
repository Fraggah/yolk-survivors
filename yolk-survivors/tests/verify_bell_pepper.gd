extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	var item=load("res://resources/items/weapons/spicy/item_bell_pepper.tres")
	assert(not item.selection_only and item.type==2)
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=item
	assert(arena.shop_panel.shop_items.has(item))
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	var player=global.player
	assert(player.current_weapons.size()==1)
	player.set_process(false)
	var pepper=player.current_weapons[0]
	pepper.set_process(false)
	assert(pepper.targets.is_empty() and pepper.can_use_weapon())
	seed(12345)
	pepper.use_weapon()
	var shots=get_nodes_in_group("projectiles")
	assert(shots.size()==3, "Seeds must fire without enemies")
	assert(not pepper.can_use_weapon(), "Cooldown gates autonomous shots")
	var angles=[]
	for shot in shots:
		shot.set_process(false)
		angles.append(shot.velocity.angle())
		assert(is_equal_approx(shot.velocity.length(),item.stats.projectile_speed))
		assert(shot.hitbox.weapon_damage_record==pepper.damage_record)
	assert(not is_equal_approx(angles[0],angles[1]))
	var stats=player.stats.duplicate()
	stats.melee_damage=100
	stats.ranged_damage=100
	stats.damage_percent=20
	assert(is_equal_approx(item.get_effective_damage(stats),6.0))
	var shot=shots[0]
	var start=shot.position
	global.game_paused=true
	shot._process(0.1)
	assert(shot.position==start)
	global.game_paused=false
	shots[1]._process(100)
	assert(shots[1].is_queued_for_deletion(), "Travel range removes seeds")
	# Real overlap validates the shared hitbox damage path, not only shot creation.
	var enemy=load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	enemy.stats=enemy.stats.duplicate()
	enemy.stats.block_chance=0
	arena.add_child(enemy)
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.health_component.current_health=100
	enemy.health_component.max_health=100
	enemy.global_position=shot.global_position
	shot.hitbox.critical_chance=0
	await physics_frame
	await physics_frame
	await process_frame
	assert(enemy.health_component.current_health<100, "Seed overlap damages enemies")
	player.add_weapon(item)
	assert(player.current_weapons.size()==2, "Copies occupy separate slots")
	var second=player.current_weapons[1]
	second.set_process(false)
	assert(second.can_use_weapon())
	second.use_weapon()
	assert(second.cooldown_timer.time_left>0)
	player.prepare_for_new_wave()
	assert(not pepper.is_attacking and pepper.cooldown_timer.is_stopped())
	print("PASS Morrón autonomous random seeds, damage overlap, general scaling, independent copies, cooldown, pause and range")
	quit()
