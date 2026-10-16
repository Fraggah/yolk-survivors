extends SceneTree
func _initialize(): call_deferred("verify")
func find_stats(node):
	if node.get_script()==load("res://scenes/ui/stats/stats_container.gd"): return node
	for child in node.get_children():
		var result=find_stats(child)
		if result: return result
	return null
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	root.size=Vector2i(1920,1080)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=arena.weapon_selection_panel.weapons_list[0]
	arena.start_panel.hide()
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	global.game_paused=true
	arena.pause_panel.show()
	await process_frame
	var panel=find_stats(arena.pause_panel)
	assert(panel and not panel.secondary_visible)
	assert(panel.stat_rows.melee_damage.visible and panel.stat_rows.ranged_damage.visible)
	assert(not panel.stat_rows.block_effectiveness.visible)
	panel._fit_content()
	var minimum=panel.custom_minimum_size
	panel.secondary_button.pressed.emit()
	panel._fit_content()
	assert(panel.secondary_visible and panel.stat_rows.block_effectiveness.visible)
	assert(panel.stat_rows.piercing.visible and panel.stat_rows.bounces.visible)
	assert(not panel.stat_rows.melee_damage.visible)
	assert(panel.custom_minimum_size==minimum)
	global.player.stats.block_effectiveness=75
	panel._process(0)
	assert(panel.stat_labels.block_effectiveness.text=="75%")
	var key=InputEventKey.new()
	key.pressed=true
	key.keycode=KEY_TAB
	panel._input(key)
	assert(not panel.secondary_visible)
	var pad=InputEventJoypadButton.new()
	pad.pressed=true
	pad.button_index=JOY_BUTTON_Y
	panel._input(pad)
	assert(panel.secondary_visible)
	arena.pause_panel.hide()
	arena.pause_panel.show()
	assert(not panel.secondary_visible)
	arena.pause_panel.hide()
	arena.shop_panel.show()
	var shop_stats=find_stats(arena.shop_panel)
	assert(shop_stats and not shop_stats.secondary_visible)
	shop_stats._input(key)
	assert(shop_stats.secondary_visible and not panel.secondary_visible)
	# Gameplay percentage semantics: higher effectiveness always receives less damage.
	global.game_paused=false
	var player=global.player
	player.stats.block_chance=100
	player.stats.armor=0
	var hit=load("res://scenes/components/hitbox_component.tscn").instantiate()
	arena.add_child(hit)
	hit.setup(100,false,0,null)
	for entry in [[0,100],[25,75],[50,50],[100,0]]:
		player.stats.block_effectiveness=entry[0]
		player.health_component.max_health=1000
		player.health_component.current_health=1000
		player.receive_hit(hit)
		assert(player.health_component.current_health==1000-entry[1])
	var upgrade=load("res://resources/items/upgrades/data/block_effectiveness/upgrade_block_effectiveness_1.tres")
	assert(upgrade.value>0 and upgrade.stat_id=="block_effectiveness")
	player.stats.block_effectiveness=50
	upgrade.apply_upgrade()
	assert(player.stats.block_effectiveness==55)
	assert(arena.upgrade_panel.upgrades.has(upgrade))
	print("PASS primary/secondary rows, stable panel dimensions, click/Tab/Y, reopen reset, shop shortcut isolation and block effectiveness 0/25/50/100 plus positive upgrades")
	quit()
