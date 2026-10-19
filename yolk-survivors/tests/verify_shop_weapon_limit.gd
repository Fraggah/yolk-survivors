extends SceneTree
func _initialize(): call_deferred("verify")
func weapon_count(offers: Array) -> int:
	return offers.filter(func(item): return item.has_method("get_effective_damage")).size()
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var global=root.get_node("Global")
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	global.main_player_selected=arena.selection_panel.player_list[0]
	var player=global.get_selected_player()
	arena.add_child(player)
	player.set_process(false)
	var shop=arena.shop_panel
	var spatula=load("res://resources/items/weapons/melee/spatula/item_spatula_1.tres")
	player.add_weapon(spatula)
	player.current_weapons[0].set_process(false)
	player.current_weapons[0].cooldown_timer.stop()
	var families:=[]
	for item in shop.shop_items:
		if item.has_method("get_effective_damage") and item.get_offer_key()!=spatula.get_offer_key() and not families.has(item.get_offer_key()): families.append(item.get_offer_key())
	seed(32717)
	for locks in range(3):
		var keys=families.slice(0,locks)
		for wave in [1,2,3,10,20]:
			for sample in 100:
				shop.equipped_guarantee_shown=false
				var offers=shop.select_shop_offers(wave,keys)
				assert(offers.size()==4-locks)
				assert(weapon_count(offers)+locks<=2,"Locked weapons consume the same two-weapon budget")
				if wave<=2: assert(weapon_count(offers)+locks==2)
				if locks==2: assert(weapon_count(offers)==0,"Even the equipped guarantee cannot create a third weapon")
	# Real retained cards: refresh and next-shop opening preserve two locked weapons.
	shop.load_shop(1)
	var locked:=[]
	for card in shop.items_container.get_children():
		if card.shop_item.has_method("get_effective_damage"):
			card.set_locked(true)
			locked.append(card)
	assert(locked.size()==2)
	global.coins=100000
	for sample in 10:
		assert(shop.try_reroll())
		var offers:=[]
		for card in shop.items_container.get_children(): offers.append(card.shop_item)
		assert(offers.size()==4 and weapon_count(offers)==2)
		for card in locked: assert(card.get_parent()==shop.items_container and card.locked)
	shop.load_shop(20)
	var displayed:=[]
	for card in shop.items_container.get_children(): displayed.append(card.shop_item)
	assert(weapon_count(displayed)==2)
	# Buying/replacing a passive must also respect the two weapons already displayed.
	for sample in 50:
		var card=shop.items_container.get_children().filter(func(value): return not value.shop_item.has_method("get_effective_damage"))[0]
		shop._refill_offer(card.shop_item,card)
		displayed.clear()
		for offer in shop.items_container.get_children(): displayed.append(offer.shop_item)
		assert(displayed.size()==4 and weapon_count(displayed)==2)
	arena.queue_free()
	await process_frame
	print("PASS shop two-weapon cap: 1500 draws, 0/1/2 locked weapons, guarantees, early shops, real refreshes, next visit and purchase refills")
	quit()
