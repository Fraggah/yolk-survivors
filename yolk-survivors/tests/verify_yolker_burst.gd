extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=arena.weapon_selection_panel.weapons_list[0]
	arena.start_panel.hide()
	arena._on_level_selected(0)
	var player=global.player
	player.set_process(false)
	player.set_physics_process(false)
	for weapon in player.current_weapons:
		weapon.set_process(false)
		weapon.cooldown_timer.stop()
	var spawner=arena.spawner
	spawner.spawn_timer.stop()
	var profile=load("res://resources/wave/enemies/yolker.tres")
	var incognito_profile=load("res://resources/wave/enemies/incognito.tres")
	assert(profile.visual_scale==0.75 and incognito_profile.visual_scale==0.65)
	var enemy=profile.scene.instantiate()
	spawner.prepare_enemy(enemy,profile)
	arena.add_child(enemy)
	enemy.set_process(false)
	assert(enemy.stats.health==60)
	assert(enemy.stats.health_increase_per_wave==12)
	var other_stats=load("res://resources/units/enemies/stats_enemy_incognito.tres")
	assert(other_stats.initial_health==48 and other_stats.health_increase_per_wave==10)
	var center=spawner.arena_environment.movement_bounds.get_center()
	enemy.global_position=center
	player.global_position=center
	var money=global.coins
	enemy.health_component.take_damage(100000)
	var count=arena.gold_list.size()
	assert(count>=10 and count<=25 and global.coins==money)
	await process_frame
	await process_frame
	var coins=arena.gold_list.duplicate()
	for coin in coins:
		coin.set_process(false)
		assert(coin.value==1 and not coin.awarded and not coin.collected)
		# Contact, forced spawn attraction, or a direct collection call cannot pay mid-flight.
		coin._on_area_entered(player)
		coin.add_coins()
		assert(not coin.awarded and global.coins==money)
		coin._process(0.2)
		assert(coin.global_position.distance_to(coin.launch_start)>0)
		var before=coin.global_position
		global.game_paused=true
		coin._process(1)
		assert(coin.global_position==before)
		global.game_paused=false
		coin._process(1)
		assert(coin.landed and not coin.awarded)
		assert(spawner.arena_environment.clamp_position(coin.global_position).is_equal_approx(coin.global_position))
	assert(global.coins==money,"Landing cannot grant currency")
	var positions:=[]
	for coin in coins:
		if not positions.has(coin.global_position): positions.append(coin.global_position)
	assert(positions.size()>5,"The drop spreads over the floor")
	var chosen=coins[0]
	player.global_position=chosen.global_position
	chosen._process(0.01)
	assert(chosen.awarded and global.coins==money+1,"Only picking up a yolk pays its one-yolk value")
	chosen.add_coins()
	assert(global.coins==money+1)
	# Uncollected burst pickups retain ordinary wave-end reserve behavior.
	global.game_paused=true
	arena.clear_arena(true)
	assert(global.coins==money+1 and global.yolk_reserve==count-1)
	await process_frame
	await process_frame
	for coin in coins:
		if is_instance_valid(coin) and not coin.is_queued_for_deletion():
			assert(coin.flying_to_jar)
			coin.animate_jar_flight(1)
	assert(global.coins==money+1,"Jar flights never grant spendable yolks")
	arena.queue_free()
	await process_frame
	print("PASS Yolker burst: smaller reward enemies, doubled HP/growth, 10-25 individual floor drops, ballistic scatter, pause, no instant payout, pickup pays once and reserve stays nonspendable")
	quit()
