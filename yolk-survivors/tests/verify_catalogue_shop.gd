extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	load("res://tests/progression_fixture.gd").prepare(root)
	var global = root.get_node("Global")
	global.main_player_selected = load("res://resources/units/players/player_well_rounded.tres")
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var player = global.get_selected_player()
	arena.add_child(player)
	player.set_process(false)
	global.game_paused = true
	var shop = arena.shop_panel
	for offer in shop.shop_items:
		if offer.item_type == 2: assert(offer.ready_for_shop and offer.catalogue_id > 0)
	for id in range(1, 101):
		var item = load("res://resources/items/passives/catalogue/item_%03d.tres" % id)
		global.coins = 10000
		if item.ready_for_shop:
			assert(shop.try_purchase_item(item))
			assert(player.passive_items.count(item.effect_key) > 0)
		else:
			assert(not shop.try_purchase_item(item))
			assert(global.coins == 10000)
	assert(shop.next_stage.id == &"deep_wok")
	assert(player.passive_items.force_horde)
	var rules = load("res://resources/economy_rules.gd")
	var base_cost: int = rules.reroll_price(shop.shop_wave, shop.reroll_count)
	assert(shop.get_reroll_cost() == floori(base_cost * 0.9))
	var smasher = load("res://resources/items/weapons/range/smasher/item_smasher_1.tres")
	assert(smasher.get_effective_bounces(player.stats) == 0)
	var count_before: int = (player.passive_items.count("double_yolk") + player.passive_items.count("chocolate_coin") + player.passive_items.count("paprika") + player.passive_items.count("cumin") + player.passive_items.count("oregano") + player.passive_items.count("cinnamon") + player.passive_items.count("bay_leaf") + player.passive_items.count("turmeric") + player.passive_items.count("rosemary") + player.passive_items.count("saffron") + player.passive_items.count("fine_salt") + player.passive_items.count("yeast") + player.passive_items.count("sugar") + player.passive_items.count("calcium") + player.passive_items.count("bitter_cocoa") + player.passive_items.count("vinegar") + player.passive_items.count("olive_oil") + player.passive_items.count("mustard_seed") + player.passive_items.count("vacuum_seal") + player.passive_items.count("miniature_food") + player.passive_items.count("curdled_cream") + player.passive_items.count("lemon_juice") + player.passive_items.count("garlic_clove") + player.passive_items.count("melted_butter") + player.passive_items.count("cream_cheese") + player.passive_items.count("cherry_tomato") + player.passive_items.count("thick_honey") + player.passive_items.count("accelerated_cooking"))
	var enemy = load("res://scenes/units/enemies/enemy_chaser.tscn").instantiate()
	player.passive_items.kills = 99
	player.passive_items.enemy_killed(enemy)
	assert((player.passive_items.count("double_yolk") + player.passive_items.count("chocolate_coin") + player.passive_items.count("paprika") + player.passive_items.count("cumin") + player.passive_items.count("oregano") + player.passive_items.count("cinnamon") + player.passive_items.count("bay_leaf") + player.passive_items.count("turmeric") + player.passive_items.count("rosemary") + player.passive_items.count("saffron") + player.passive_items.count("fine_salt") + player.passive_items.count("yeast") + player.passive_items.count("sugar") + player.passive_items.count("calcium") + player.passive_items.count("bitter_cocoa") + player.passive_items.count("vinegar") + player.passive_items.count("olive_oil") + player.passive_items.count("mustard_seed") + player.passive_items.count("vacuum_seal") + player.passive_items.count("miniature_food") + player.passive_items.count("curdled_cream") + player.passive_items.count("lemon_juice") + player.passive_items.count("garlic_clove") + player.passive_items.count("melted_butter") + player.passive_items.count("cream_cheese") + player.passive_items.count("cherry_tomato") + player.passive_items.count("thick_honey") + player.passive_items.count("accelerated_cooking")) == count_before + 1)
	enemy.free()
	global.player = null
	global.game_paused = false
	arena.queue_free()
	await process_frame
	await process_frame
	print("PASS catalogue shop: all purchases, pending exclusions, stages, printer, reroll discount and Smasher immunity")
	quit()


