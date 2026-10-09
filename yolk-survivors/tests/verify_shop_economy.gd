extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	load("res://tests/progression_fixture.gd").prepare(root)
	var global = root.get_node("Global")
	global.game_paused = true
	global.main_player_selected = load("res://resources/units/players/player_well_rounded.tres")
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	var player = global.get_selected_player()
	arena.add_child(player)
	player.set_process(false)
	var shop = arena.shop_panel
	var rules = load("res://resources/economy_rules.gd")
	var item = load("res://resources/items/weapons/melee/spatula/item_spatula_1.tres")
	assert(global.STARTING_COINS == 0)
	for example in [[1, 12, 23, 45, 78], [5, 20, 35, 65, 110], [9, 28, 47, 85, 142]]:
		for tier in 4:
			assert(rules.shop_price([10, 20, 40, 70][tier], example[0]) == example[tier + 1])
	assert(rules.shop_price(9, 1) == 10 and rules.shop_price(0, 1) == 1)
	var bases = {"blender":10, "butcher_knife":9, "mace":12, "mitten":8, "spatula":10, "corpse_l":12, "hydrant":10, "knifer":10, "smasher":14, "the_bloody":14}
	var weapons = 0
	for resource in shop.shop_items:
		if resource.item_type != 0: continue
		weapons += 1
		var folder = resource.resource_path.get_base_dir().get_file()
		assert(resource.item_cost == bases[folder] * [1,2,4,7][resource.item_tier])
		var previous = 0
		for wave in range(1, 10):
			var price = resource.get_shop_price(wave)
			assert(price > previous and resource.get_sell_price(wave) == floori(price * 0.25))
			previous = price
	assert(weapons == 40)
	for reward in [["chaser_slow",2], ["chaser_mid",2], ["chaser_fast",2], ["shooter",3], ["charger",4], ["fueguito",0]]:
		assert(load("res://resources/units/enemies/stats_enemy_%s.tres" % reward[0]).coin_drop == reward[1])
	for passive in [["ball",12], ["cape",20], ["sword",30], ["rage",50]]:
		assert(load("res://resources/items/passives/data/passive_item_%s.tres" % passive[0]).item_cost == passive[1])
	for luck in [0,35,200]:
		player.stats.luck = luck
		for seed_value in 50:
			seed(seed_value)
			for wave in [1,2]:
				var offers = shop.select_shop_offers(wave)
				assert(offers.size() == 4)
				var weapon_count = 0
				var affordable = false
				var unique = []
				for offer in offers:
					assert(not unique.has(offer.get_offer_key()))
					unique.append(offer.get_offer_key())
					if offer.item_type == 0:
						weapon_count += 1
						if offer.item_tier == 0 and offer.get_shop_price(wave) <= 12: affordable = true
					if wave == 1: assert(offer.item_tier == 0)
				assert(weapon_count >= 2)
				if wave == 1: assert(affordable)
	player.stats.luck = 0
	player.add_weapon(item)
	global.equipped_weapons.assign([item])
	shop.create_item_weapon(item)
	shop.load_shop(5)
	await process_frame
	for card in shop.items_container.get_children():
		if card.is_queued_for_deletion(): continue
		assert(int(card.item_cost.text) == card.shop_item.get_shop_price(5))
	global.coins = 19
	assert(not shop.try_purchase_item(item) and global.coins == 19)
	global.coins = 20
	assert(shop.try_purchase_item(item) and global.coins == 0)
	assert(player.current_weapons.size() == 2 and item.item_cost == 10, "Inflation never mutates the resource base")
	var bought_card = shop.weapon_container.get_child(shop.weapon_container.get_child_count() - 1)
	shop._on_item_card_selected(bought_card)
	shop._on_sell_weapon_button_pressed()
	assert(global.coins == 5 and player.current_weapons.size() == 1)
	await process_frame
	global.coins = 500
	assert(shop.try_purchase_item(item))
	shop._on_item_card_selected(shop.weapon_container.get_child(0))
	shop._on_combine_button_pressed()
	await process_frame
	assert(global.equipped_weapons.size() == 1 and global.equipped_weapons[0] == item.upgrade_to)
	for folder in ["hydrant", "knifer", "corpse_l", "smasher", "the_bloody"]:
		var directory = DirAccess.open("res://resources/items/weapons/range/" + folder)
		for file in directory.get_files():
			if file.begins_with("item_") and file.ends_with("_1.tres"):
				assert(shop.try_purchase_item(load(directory.get_current_dir() + "/" + file)))
	assert(global.equipped_weapons.size() == 6)
	var upgraded = item.upgrade_to
	var before = global.coins
	assert(shop.try_purchase_item(upgraded))
	assert(global.coins == before - upgraded.get_shop_price(5))
	assert(global.equipped_weapons.size() == 6 and global.equipped_weapons.has(upgraded.upgrade_to))
	var unmatched = load("res://resources/items/weapons/melee/mace/item_mace_1.tres")
	before = global.coins
	assert(not shop.try_purchase_item(unmatched) and global.coins == before)
	shop.clear_items()
	global.equipped_weapons.clear()
	global.player = null
	player.queue_free()
	arena.queue_free()
	await process_frame
	print("PASS: 40 tier prices, inflation and 25% sale, rewards/passives, 300 early shops, displayed/charged price equality, insufficient funds, manual/automatic combinations and full-slot rejection")
	quit()
