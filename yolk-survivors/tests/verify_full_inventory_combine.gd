extends SceneTree

func _initialize() -> void: call_deferred("verify")

func verify() -> void:
	for slot in [3, 4, 5]: await verify_slot(slot)
	print("PASS: six slots, three IV/three III, all three selectable III slots, mixed auto-upgrades and one-to-one inventory mapping")
	quit()

func verify_slot(slot: int) -> void:
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	var global = root.get_node("Global")
	var items: Array = []
	for tier in range(1, 5): items.append(load("res://resources/items/weapons/range/knifer/item_knifer_%d.tres" % tier))
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = items[3]
	arena.start_panel.hide()
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	global.game_paused = true
	global.coins = 10000
	await process_frame
	var shop = arena.shop_panel
	shop.show()
	for tier in [4, 2, 3, 2, 3]: assert(shop.try_purchase_item(items[tier - 1]))
	# Auto-upgrading an earlier slot creates a tier III instance after older III instances.
	for tier in [2, 3, 2]:
		assert(shop.try_purchase_item(items[tier - 1]))
		await process_frame
	assert(global.equipped_weapons.size() == 6)
	assert(global.equipped_weapons.filter(func(item): return item.item_tier == 3).size() == 3)
	assert(global.equipped_weapons.filter(func(item): return item.item_tier == 2).size() == 3)
	var selected = shop.weapon_container.get_child(slot)
	assert(selected.item.item_tier == 2)
	var selected_instance = selected.weapon_instance
	var coins_before: int = global.coins
	shop._on_item_card_selected(selected)
	assert(not shop.combine_button.disabled)
	shop._on_combine_button_pressed()
	await process_frame
	assert(not is_instance_valid(selected_instance), "Combine removes the exact selected instance")
	assert(global.coins == coins_before, "Manual combine does not charge currency")
	assert(global.equipped_weapons.size() == 5, "Tier III combine must work with full inventory after mixed auto-upgrades")
	assert(global.equipped_weapons.filter(func(item): return item.item_tier == 3).size() == 4)
	assert(global.equipped_weapons.filter(func(item): return item.item_tier == 2).size() == 1)
	assert(shop.weapon_container.get_child_count() == 5)
	var mapped: Array = []
	for card in shop.weapon_container.get_children():
		assert(is_instance_valid(card.weapon_instance) and global.player.current_weapons.has(card.weapon_instance))
		assert(card.weapon_instance.data == card.item and not mapped.has(card.weapon_instance))
		mapped.append(card.weapon_instance)
	shop._on_item_card_selected(shop.weapon_container.get_children().back())
	assert(shop.combine_button.disabled, "Tier IV cannot combine")
	arena.spawner.wave_timer.stop()
	global.player = null
	arena.queue_free()
	await process_frame
