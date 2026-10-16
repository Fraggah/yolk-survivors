extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	var item=load("res://resources/items/weapons/range/smasher/item_smasher_1.tres")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=item
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	arena.stage_mechanics.stop()
	var player=global.player
	player.set_process(false)
	player.global_position=Vector2.ZERO
	var weapon=player.current_weapons[0]
	weapon.set_process(false)
	weapon.position=Vector2.ZERO
	weapon.rotation=0
	var tier=item
	for i in 4:
		assert(tier.stats.unlimited_range and tier.stats.unlimited_piercing and tier.stats.bounces==0)
		assert(tier.get_range_description()==tier.format_number(tier.stats.max_range))
		tier=tier.upgrade_to
	player.stats.bounces=10
	assert(item.get_effective_bounces(player.stats)==0)
	var enemies=[]
	for point in [Vector2(250,0),Vector2(350,0),Vector2(450,0)]:
		var enemy=load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
		enemy.stats=enemy.stats.duplicate()
		enemy.stats.block_chance=0
		arena.add_child(enemy)
		enemy.global_position=point
		enemy.set_process(false)
		enemy.set_physics_process(false)
		enemy.can_move=false
		enemy.health_component.current_health=1000
		enemy.health_component.max_health=1000
		enemies.append(enemy)
	for enemy in enemies: weapon._on_range_area_area_entered(enemy)
	assert(weapon.get_closest_target()==null,"Unlimited travel must not extend detection")
	var first_position=enemies[0].global_position
	enemies[0].global_position=Vector2(100,0)
	assert(weapon.get_closest_target()==enemies[0],"Normal detection still finds nearby enemies")
	enemies[0].global_position=first_position
	weapon.weapon_behaviour.create_projectile()
	var shot=get_nodes_in_group("projectiles")[0]
	shot.set_process(false)
	shot.hitbox.critical_chance=0
	assert(is_inf(shot.max_distance) and shot.unlimited_piercing and shot.remaining_bounces==0)
	var direction=shot.velocity
	for enemy in enemies:
		shot.global_position=enemy.get_node("HurtboxComponent").global_position
		await physics_frame
		await physics_frame
		await process_frame
		assert(enemy.health_component.current_health<1000)
		assert(not shot.is_queued_for_deletion() and shot.velocity==direction,"Hits pierce without redirecting or consuming projectile")
		var hp=enemy.health_component.current_health
		enemy.get_node("HurtboxComponent")._on_area_entered(shot.hitbox)
		assert(enemy.health_component.current_health==hp,"Each enemy is hit only once")
	shot._process(0.01)
	assert(not shot.is_queued_for_deletion(),"Travels beyond the old 150 range")
	shot.global_position=player.arena_environment.movement_bounds.end+Vector2(50,50)
	global.game_paused=true
	shot._process(1)
	assert(not shot.is_queued_for_deletion())
	global.game_paused=false
	shot._process(0)
	assert(not shot.is_queued_for_deletion(),"Leaving the playable surface keeps the shot alive")
	shot.arena_environment=player.arena_environment.duplicate()
	shot.arena_environment.background_offset=Vector2(100,50)
	shot.arena_environment.background_size=Vector2(6000,4000)
	var background_end=shot.arena_environment.background_offset+shot.arena_environment.background_size*0.5
	shot.global_position=Vector2(background_end.x-1,50)
	shot._process(0)
	assert(not shot.is_queued_for_deletion(),"Visible part of the projectile can remain within background")
	shot.global_position=background_end+Vector2(100,100)
	shot._process(0)
	assert(shot.is_queued_for_deletion(),"Leaving the full background deletes projectile")
	await process_frame
	weapon.weapon_behaviour.create_projectile()
	shot=get_nodes_in_group("projectiles")[0]
	shot.set_process(false)
	shot.arena_environment=player.arena_environment.duplicate()
	shot.arena_environment.oval=false
	shot.arena_environment.corner_radius=0
	shot.arena_environment.background_size=Vector2(200000,200000)
	shot.global_position=shot.get_canvas_transform().affine_inverse()*(root.get_visible_rect().end+Vector2(100,100))
	shot._process(0)
	shot._on_visible_on_screen_notifier_2d_screen_exited()
	assert(not shot.is_queued_for_deletion(),"Shot survives outside camera while inside arena")
	var offscreen=enemies[0]
	offscreen.global_position=shot.global_position
	var hp_before=offscreen.health_component.current_health
	await physics_frame
	await physics_frame
	await process_frame
	assert(offscreen.health_component.current_health<hp_before,"Offscreen shot still damages enemies")
	assert(not shot.is_queued_for_deletion())
	arena.clear_arena()
	assert(shot.is_queued_for_deletion())
	print("PASS Smasher: normal detection, unlimited travel/piercing, no bounces, offscreen damage, full background exit, pause and wave cleanup")
	quit()
