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
	global.game_paused = true
	var seen := {}
	var tiers := {"armor":[], "critical_chance":[]}
	for item in arena.upgrade_panel.upgrades:
		if item.stat_id in tiers:
			tiers[item.stat_id].append(item.item_tier)
			assert(item.item_icon != null)
	assert(tiers.armor.size() == 4 and tiers.critical_chance.size() == 4)
	for level in range(1,101):
		arena.upgrade_panel.load_upgrades(level)
		for card in arena.upgrade_panel.item_container.get_children():
			seen[card.item.stat_id] = true
	assert(seen.has("armor") and seen.has("critical_chance"))
	for stat in ["armor","critical_chance"]:
		var upgrade = load("res://resources/items/upgrades/data/%s/upgrade_%s_1.tres" % [stat,stat])
		var card = load("res://scenes/ui/upgrades/upgrade_card.tscn").instantiate()
		arena.upgrade_panel.item_container.add_child(card)
		card.item = upgrade
		var before: float = global.player.stats.get(stat)
		card._on_custom_button_pressed()
		assert(global.player.stats.get(stat) == before + upgrade.value)
		card.queue_free()
	print("PASS armor/critical tiers, actual randomized offers and card selection applies stats")
	quit()
