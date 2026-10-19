extends "res://tests/verify_status_system.gd"

func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var global = root.get_node("Global")
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	global.main_player_selected = load("res://resources/units/players/player_well_rounded.tres")
	var player = global.get_selected_player()
	arena.add_child(player)
	player.set_process(false)
	var shop = arena.shop_panel
	var liquidation = load("res://resources/items/passives/catalogue/item_077.tres").duplicate()
	liquidation.minimum_discount_percent = 30
	liquidation.maximum_discount_percent = 30
	liquidation.two_for_one_chance = 0
	liquidation.apply_passive_values()
	assert(not liquidation.available_for(player))
	global.coins = 100000
	shop.load_shop(5)
	var sale = sale_card(shop)
	assert(sale != null and sale.sale_discount_percent == 30)
	assert(sale.sale_badge.visible)
	var original = sale.shop_item
	var price = sale.get_effective_price()
	sale.set_locked(true)
	assert(shop.try_reroll())
	assert(sale_card(shop) == sale and sale.shop_item == original)
	assert(sale.get_effective_price() == price)
	shop._clear_liquidation_sales()
	assert(sale_card(shop) == null)
	shop.load_shop(6)
	assert(sale_card(shop) != null and not sale.has_sale())
	var discounted = sale_card(shop)
	var coins = global.coins
	price = discounted.get_effective_price()
	assert(shop._purchase_offer(discounted.shop_item, discounted))
	assert(global.coins == coins - price)
	shop.reset_offers()
	liquidation.two_for_one_chance = 1
	var offers: Array = []
	for id in [1, 2, 3, 4]:
		offers.append(load("res://resources/items/passives/catalogue/item_%03d.tres" % id))
	shop._populate_offers(offers)
	sale = sale_card(shop)
	assert(sale.sale_two_for_one and sale.sale_discount_percent == 0)
	assert(sale.get_effective_price() == sale.shop_item.get_shop_price(sale.shop_wave))
	var count_before = player.passive_items.count(sale.shop_item.effect_key)
	coins = global.coins
	price = sale.get_effective_price()
	assert(shop._purchase_offer(sale.shop_item, sale))
	assert(player.passive_items.count(sale.shop_item.effect_key) == count_before + 2)
	assert(global.coins == coins - price)
	assert(not shop._can_receive_two(liquidation))
	# An unowned unique must be excluded too, even with a guaranteed 2x1 roll.
	var unique = offers[0].duplicate()
	unique.effect_key = "unique_sale_fixture"
	unique.max_copies = 1
	assert(unique.available_for(player) and not shop._can_receive_two(unique))
	shop.reset_offers()
	shop._populate_offers([unique])
	sale = sale_card(shop)
	assert(sale != null and not sale.sale_two_for_one and sale.sale_discount_percent == 30)
	coins = global.coins
	sale.set_sale(0, true)
	assert(not shop._purchase_offer(unique, sale))
	assert(global.coins == coins and player.passive_items.count(unique.effect_key) == 0)
	sale.set_sale(30)
	assert(shop._purchase_offer(unique, sale))
	assert(player.passive_items.count(unique.effect_key) == 1)
	shop._on_new_wave_button_pressed()
	assert(sale_card(shop) == null)
	print("PASS liquidation: single sale, locks, visits, checkout, 2x1, uniqueness")
	arena.queue_free()
	await process_frame
	quit()

func sale_card(shop):
	var result = null
	for card in shop.items_container.get_children():
		if card.has_sale():
			assert(result == null, "Only one sale")
			result = card
	return result
