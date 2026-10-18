extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=load("res://resources/items/weapons/range/knifer/item_knifer_1.tres")
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	var player=global.player
	player.set_process(false)
	player.global_position=Vector2.ZERO
	for weapon in player.current_weapons: weapon.set_process(false)
	var crowd=root.get_node("EnemyCrowd")
	crowd.set_process(false)
	var geometry=load("res://resources/arena_environment.gd").new()
	geometry.movement_bounds=Rect2(-1000,-1000,2000,2000)
	var wok=load("res://scenes/arena/mechanics/wok_mechanic.gd").new()
	arena.add_child(wok)
	wok.area=geometry
	wok.active=true
	wok.safe_zone_bounds=Rect2(-50,-50,100,100)
	wok.set_process(false)
	var enemies=[]
	for i in 2:
		var enemy=load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
		enemy.stats=enemy.stats.duplicate()
		arena.add_child(enemy)
		enemy.arena_environment=geometry
		enemy.global_position=Vector2(400,0)
		enemy.set_process(false)
		enemies.append(enemy)
	var stats=load("res://resources/items/weapons/range/baguette_harpoon/stats_baguette_harpoon_1.tres")
	var arrow=stats.projectile_scene.instantiate()
	arena.add_child(arrow)
	arrow.set_process(false)
	arrow.setup_projectile(Vector2(1000,0),1,false,0,player,500)
	arrow.configure_effects(stats.ranged_settings)
	arrow.global_position=Vector2(400,0)
	for enemy in enemies: arrow._on_hitbox_component_on_hit_hurtbox(enemy.get_node("HurtboxComponent"))
	arrow._move_carried()
	arrow._plant()
	assert(wok.force_at(arrow.global_position).length()>0,"Reproduction is on the wok slope")
	for step in 20:
		for enemy in enemies:
			wok.apply_force(enemy,0.016)
			assert(enemy.global_position.is_equal_approx(arrow.global_position),"Pinned enemy never slides off its anchor")
			enemy._process(0.016)
		crowd._process(0.016)
	for enemy in enemies:
		enemy.crowd_steering=Vector2(500,0)
		crowd.members[enemy.get_instance_id()].steering=Vector2(500,0)
	arrow.finish()
	for enemy in enemies:
		assert(enemy.pins.is_empty() and enemy.crowd_steering==Vector2.ZERO)
		assert(crowd.separation(enemy)==Vector2.ZERO)
	enemies[1].global_position+=Vector2(0.02,0.01)
	crowd.rebuild()
	for enemy in enemies:
		crowd._calculate(enemy,enemy.get_instance_id())
		assert(enemy.crowd_steering.length()<=1.001)
		var before=enemy.global_position
		enemy._process(0.016)
		assert(before.distance_to(enemy.global_position)<=enemy.stats.speed*0.016+0.001,"Released crowd never exceeds normal locomotion speed")
	var before=enemies[0].global_position
	wok.apply_force(enemies[0],0.016)
	assert(before.distance_to(enemies[0].global_position)>0,"Wok resumes its normal pull after release")
	arena.queue_free()
	await process_frame
	print("PASS wok/harpoon: stable pin on slope, release clears steering, dense crowd speed bounded, slope force resumes")
	quit()
