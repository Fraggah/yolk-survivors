extends SceneTree
func _initialize(): call_deferred("verify")
func make_enemy(arena, point):
	var enemy=load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	enemy.stats=enemy.stats.duplicate()
	enemy.stats.block_chance=0
	arena.add_child(enemy)
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.health_component.current_health=1000
	enemy.health_component.max_health=1000
	enemy.global_position=point
	return enemy
func blasts():
	return get_nodes_in_group("projectiles").filter(func(node): return node.get_script().resource_path.ends_with("spicy_explosion.gd"))
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	var item=load("res://resources/items/weapons/spicy/item_habanero.tres")
	assert(not item.selection_only and item.type==2)
	assert(arena.shop_panel.shop_items.has(item))
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=item
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	var player=global.player
	player.set_process(false)
	player.health_component.debug_invulnerable=true
	var weapon=player.current_weapons[0]
	weapon.set_process(false)
	var catalogue=load("res://resources/items/weapons/spicy_catalogue.gd")
	assert(catalogue.items().size()==10 and catalogue.items(true).size()==40)
	for base in catalogue.items():
		var current=base
		var last_damage=-1.0
		for tier in 4:
			assert(current and current.item_tier==tier)
			assert(arena.shop_panel.shop_items.has(current))
			assert(current.stats.damage>last_damage)
			assert(current.scene==base.scene and current.final_stat_modifiers==base.final_stat_modifiers)
			last_damage=current.stats.damage
			current=current.upgrade_to
		assert(current==null)
	var current=item
	var behaviour=weapon.weapon_behaviour
	behaviour.set_process(false)
	var previous_radius=0.0
	for tier in 4:
		weapon.data=current
		var config=current.stats.spicy_explosion_settings
		assert(config.explosion_count==tier+3)
		assert(config.explosion_radius>previous_radius)
		previous_radius=config.explosion_radius
		behaviour.execute_attack()
		assert(blasts().size()==1)
		for blast in get_nodes_in_group("projectiles"): blast.set_process(false)
		var left=behaviour.next_explosion
		global.game_paused=true
		behaviour._process(10)
		assert(behaviour.next_explosion==left)
		global.game_paused=false
		behaviour._process(left*0.5)
		assert(blasts().size()==1)
		behaviour._process(left*0.5+0.001)
		assert(blasts().size()==2)
		for count in range(2,config.explosion_count):
			behaviour._process(behaviour.next_explosion+0.001)
		assert(blasts().size()==config.explosion_count)
		assert(weapon.is_attacking)
		behaviour._process(behaviour.next_explosion+0.001)
		assert(not weapon.is_attacking)
		for blast in get_nodes_in_group("projectiles"): blast.queue_free()
		await process_frame
		behaviour.execute_attack()
		behaviour.reset_attack()
		behaviour._process(10)
		assert(behaviour.explosions_remaining==0 and not weapon.is_attacking)
		for blast in get_nodes_in_group("projectiles"): blast.queue_free()
		await process_frame
		current=current.upgrade_to
	arena.queue_free()
	await process_frame
	print("PASS all 40 spicy tier resources, shop inclusion, scaling, Habanero sequential count, pause and reset")
	quit()
