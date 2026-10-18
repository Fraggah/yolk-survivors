extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	var item=load("res://resources/items/weapons/melee/spark_lighter/item_spark_lighter_1.tres")
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
	assert(weapon.data==item and weapon.data.stats.max_range<=100)
	var enemy=load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	enemy.stats=enemy.stats.duplicate()
	enemy.stats.block_chance=0
	arena.add_child(enemy)
	enemy.set_process(false)
	enemy.health_component.max_health=1000
	enemy.health_component.current_health=1000
	enemy.global_position=player.global_position+Vector2(200,0)
	var behaviour=weapon.weapon_behaviour
	behaviour._begin_pulse()
	enemy.get_node("HurtboxComponent")._on_area_entered(behaviour.hitbox)
	assert(enemy.health_component.current_health<1000)
	assert(enemy.has_node("FireVisual"),"Thrust applies burning")
	assert(enemy.status_controller.lightning_left>0,"The same thrust also electrifies")
	behaviour._end_pulse()
	assert(not behaviour.contact_active)
	for tier in range(1,5):
		var data=load("res://resources/items/weapons/melee/spark_lighter/item_spark_lighter_%d.tres" % tier)
		assert(arena.shop_panel.shop_items.has(data))
		assert(data.item_tier==tier-1 and data.type==0 and not data.selection_only)
		assert(data.on_hit_effects.size()==2)
		assert(data.on_hit_effects[0].kind==0 and data.on_hit_effects[1].kind==1)
		assert(data.stats.accuracy==1 and data.stats.melee_settings.hit_count==1)
		if tier<4: assert(data.upgrade_to.item_tier==tier)
	var menu=arena.weapon_selection_panel
	menu.show()
	await process_frame
	await process_frame
	var scroll=menu.roster_layout.weapon_scroll
	assert(scroll.follow_focus and menu.weapons_container.get_parent()==scroll)
	assert(menu.weapons_container.get_child_count()>40)
	scroll.ensure_control_visible(menu.weapons_container.get_children().back())
	await process_frame
	assert(scroll.scroll_vertical>0,"Extra weapon row is reachable by scrolling")
	arena.queue_free()
	await process_frame
	print("PASS Spark Lighter: melee thrust applies fire and electricity, four shop tiers/upgrades, selection and expanded scroll")
	quit()
