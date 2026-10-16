extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	var spawner=arena.spawner
	spawner.wave_index=1
	spawner.current_wave_data=spawner.find_wave_data()
	var profile=load("res://resources/wave/enemies/chaser_mini.tres")
	var mid_profile=load("res://resources/wave/enemies/chaser_mid.tres")
	for wave in [1,2,3,10]:
		spawner.wave_index=wave
		spawner.current_wave_data=spawner.find_wave_data()
		var mini=profile.scene.instantiate()
		var mid=mid_profile.scene.instantiate()
		spawner.prepare_enemy(mini,profile)
		spawner.prepare_enemy(mid,mid_profile)
		assert(mini.stats.speed==mid.stats.speed)
		assert(mini.stats.health<mid.stats.health and mini.stats.damage<mid.stats.damage)
		assert(mini.stats.coin_drop==mid.stats.coin_drop)
		if wave==1:
			assert(mini.stats.health==4 and mini.stats.damage==2)
			arena.add_child(mini)
			arena.add_child(mid)
			assert(mini.sprite.texture==mid.sprite.texture)
			assert(mini.visuals.scale.is_equal_approx(mid.visuals.scale*0.6))
			for path in ["HurtboxComponent/CollisionShape2D","HitboxComponent/CollisionShape2D2"]:
				var small=mini.get_node(path)
				var normal=mid.get_node(path)
				assert(is_equal_approx(small.shape.radius,normal.shape.radius*0.6))
			mini.free()
			mid.free()
		else:
			mini.free()
			mid.free()
	for wave in [1,2,3]:
		spawner.wave_index=wave
		var data=spawner.find_wave_data()
		assert(data.groups[0].enemies.has(profile))
		assert(data.groups[0].minimum_count==1 and data.groups[0].maximum_count==1)
	spawner.wave_index=1
	spawner.current_wave_data=spawner.find_wave_data()
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=load("res://resources/items/weapons/range/knifer/item_knifer_1.tres")
	arena._on_level_selected(0)
	global.player.health_component.debug_invulnerable=true
	# Exercise real wave spawns and verify the profile survives instantiation.
	await create_timer(1.3).timeout
	assert(not spawner.spawned_enemies.is_empty())
	for enemy in spawner.spawned_enemies:
		assert(enemy.get_meta("enemy_profile")==&"chaser_mini")
		assert(enemy.stats.health==4 and enemy.visual_scale==0.6)
	print("PASS Mini weaker than Mid, equal speed/rewards, inherited scaled collisions, early wave mix and live spawns")
	quit()
