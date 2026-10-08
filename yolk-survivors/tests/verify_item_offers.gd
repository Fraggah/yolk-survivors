extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func assert_unique(items: Array) -> void:
	var keys: Array = []
	for item in items:
		assert(not keys.has(item.get_offer_key()))
		keys.append(item.get_offer_key())

func verify() -> void:
	var global = root.get_node("Global")
	global.game_paused = true
	global.main_player_selected = load("res://resources/units/players/player_well_rounded.tres")
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	var player = global.get_selected_player()
	arena.add_child(player)
	player.set_process(false)
	var shop = arena.shop_panel
	var upgrades = arena.get_node("GameUI/UpgradePanel")
	for luck in [0, 200]:
		player.stats.luck = luck
		for wave in [1, 2, 5, 9, 20]:
			for sample in 50:
				seed(sample)
				var offers = shop.select_shop_offers(wave)
				assert(offers.size() == 4)
				assert_unique(offers)
				var choices = global.select_items_for_offer(upgrades.upgrades, wave, global.UPGRADE_PROBABILITY_CONFIG)
				assert(choices.size() == 4)
				assert_unique(choices)
	var weapon = load("res://resources/items/weapons/melee/spatula/item_spatula_1.tres")
	assert(global.select_items_for_offer([weapon, weapon.upgrade_to], 20, global.SHOP_PROBABILITY_CONFIG).size() == 1)
	assert(global.select_items_for_offer([], 1, global.SHOP_PROBABILITY_CONFIG).is_empty())
	assert(global.select_items_for_offer([weapon.upgrade_to], 1, global.SHOP_PROBABILITY_CONFIG).is_empty())
	player.stats.luck = 0
	shop.load_shop(1)
	global.coins = 0
	await process_frame
	assert(shop.reroll_button.disabled)
	var card = shop.items_container.get_child(0)
	var original = card.shop_item
	card._on_custom_button_pressed()
	assert(card.shop_item == original and shop.items_container.get_child_count() == 4)
	global.coins = 10000
	for purchase in 15:
		var previous = []
		for other in shop.items_container.get_children(): previous.append(other.shop_item)
		card = shop.items_container.get_child(purchase % 4)
		var bought = card.shop_item
		var before = global.coins
		# Free inventory slots to exercise repeated successful card purchases.
		shop.clear_items()
		global.equipped_weapons.clear()
		for held in player.current_weapons: held.queue_free()
		player.current_weapons.clear()
		card._on_custom_button_pressed()
		assert(global.coins == before - bought.get_shop_price(1))
		assert(card.shop_item.get_offer_key() != bought.get_offer_key())
		var current = []
		for index in 4:
			var other = shop.items_container.get_child(index)
			current.append(other.shop_item)
			if other != card: assert(other.shop_item == previous[index])
		assert_unique(current)
		assert(shop.items_container.get_child_count() == 4)
	for cost in [1, 2, 3]:
		assert(shop.get_reroll_cost() == cost)
		global.coins = cost - 1
		var before = shop.items_container.get_children()
		assert(not shop.try_reroll())
		assert(shop.items_container.get_children() == before and global.coins == cost - 1)
		global.coins = cost
		assert(shop.try_reroll() and global.coins == 0)
		var current = []
		for other in shop.items_container.get_children(): current.append(other.shop_item)
		assert_unique(current)
	shop.load_shop(5)
	assert(shop.reroll_count == 0 and shop.get_reroll_cost() == 5)
	global.coins = 100
	assert(shop.try_reroll() and shop.get_reroll_cost() == 7 and global.coins == 95)
	await process_frame
	var buttons = shop.get_node("MarginContainer/Control/VBoxContainer")
	var stats = shop.get_node("MarginContainer/Control/StatsContainer")
	assert(shop.reroll_button.get_global_rect().end.y + 20 <= stats.get_global_rect().position.y)
	assert(shop.reroll_cost_label.text == "refresh 7")
	assert(shop.reroll_button.get_node("Content/YolkIcon").texture != null)
	for button in buttons.get_children():
		assert(button.position.y >= 0 and button.position.y + button.size.y <= buttons.size.y)
	upgrades.load_upgrades(9)
	upgrades.load_upgrades(9)
	assert(upgrades.item_container.get_child_count() == 4)
	var displayed = []
	for child in upgrades.item_container.get_children(): displayed.append(child.item)
	assert_unique(displayed)
	global.equipped_weapons.clear()
	global.player = null
	arena.queue_free()
	await process_frame
	await process_frame
	print("PASS: 1000 unique shop/upgrade draws, small pools, purchase refill preserving other slots, failed payments, reroll costs/reset, upgrade rebuild and button layout")
	quit()
