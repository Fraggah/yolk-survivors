extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	var item=load("res://resources/items/weapons/range/kitchen_torch/item_kitchen_torch_1.tres")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=item
	assert(arena.weapon_selection_panel.weapons_list.has(item))
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	var player=global.player
	player.set_process(false)
	player.health_component.debug_invulnerable=true
	var weapon=player.current_weapons[0]
	weapon.set_process(false)
	weapon.rotation=0
	var stream=weapon.weapon_behaviour
	var enemy=load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	enemy.stats=enemy.stats.duplicate()
	enemy.stats.block_chance=0
	arena.add_child(enemy)
	enemy.set_process(false)
	enemy.health_component.max_health=10000
	enemy.health_component.current_health=10000
	var hurt=enemy.get_node("HurtboxComponent")
	enemy.global_position=stream.muzzle.global_position+Vector2(45,0)-(hurt.global_position-enemy.global_position)
	weapon.closest_target=enemy
	await physics_frame
	await physics_frame
	stream.update_stream(0.01,true)
	assert(stream.stream_active and stream.line.visible)
	assert(stream.current_targets.has(enemy),"Short hitscan actually intersects the enemy hurtbox")
	assert(enemy.health_component.current_health<10000 and enemy.has_node("FireVisual"))
	assert(enemy.status_controller.lightning_left==0,"Torch applies only fire")
	var hp=enemy.health_component.current_health
	var phase=stream.flow_phase
	global.game_paused=true
	stream.update_stream(1.0,true)
	assert(stream.flow_phase==phase and enemy.health_component.current_health==hp)
	global.game_paused=false
	stream.update_stream(0.2,true)
	assert(enemy.health_component.current_health<hp,"Continuous flame keeps ticking")
	enemy.global_position=stream.muzzle.global_position+Vector2(150,0)-(hurt.global_position-enemy.global_position)
	await physics_frame
	await physics_frame
	hp=enemy.health_component.current_health
	stream.update_stream(0.2,true)
	assert(stream.current_targets.has(enemy) and enemy.health_component.current_health<hp,"Doubled range damages beyond the previous 105-world-unit reach")
	for tier in range(1,5):
		var data=load("res://resources/items/weapons/range/kitchen_torch/item_kitchen_torch_%d.tres" % tier)
		assert(arena.shop_panel.shop_items.has(data) and data.item_tier==tier-1)
		assert(data.type==1 and data.stats.max_range==140 and data.stats.accuracy==1)
		assert(data.on_hit_effects.size()==1 and data.on_hit_effects[0].kind==0)
		if tier<4: assert(data.upgrade_to.item_tier==tier)
	stream.update_stream(0.01,false)
	assert(not stream.line.visible and not stream.stream_active)
	stream.reset_attack()
	assert(not weapon.is_attacking)
	arena.queue_free()
	await process_frame
	print("PASS Kitchen Torch: short continuous trace, fire only, recurring damage, pause, reset, four shop tiers and selection")
	quit()
