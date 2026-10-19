extends SceneTree

func _initialize(): call_deferred("verify")

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
	var rarity = load("res://resources/shop_rarity.gd")
	var policy = load("res://resources/shop_weapon_bias.gd")
	assert(rarity.probabilities(1) == [1.0, 0.0, 0.0, 0.0])
	var end = rarity.probabilities(20)
	assert(is_equal_approx(end[0], 0.4) and is_equal_approx(end[1], 0.4) and is_equal_approx(end[2], 0.15) and is_equal_approx(end[3], 0.05))
	assert(rarity.probabilities(100) == end)
	var table := FileAccess.open("res://resources/shop_rarity_base.txt", FileAccess.READ)
	table.get_csv_line()
	for wave in range(1,21):
		var row := table.get_csv_line()
		assert(row[0].to_int() == wave)
		var actual = rarity.probabilities(wave)
		for tier in 4: assert(absf(actual[tier] - row[tier + 1].to_float()) < 0.000001, "Base table mismatch")
	table.close()
	for wave in range(1,21):
		var cumulative = rarity.cumulative(wave)
		assert(cumulative[0] <= 0.6 and cumulative[1] <= 0.2 and cumulative[2] <= 0.05)
		if wave < 2: assert(cumulative[0] == 0)
		if wave < 9: assert(cumulative[1] == 0)
		if wave < 15: assert(cumulative[2] == 0)
		player.stats.luck = 1000
		var lucky = global.calculate_tier_probability(wave, global.SHOP_PROBABILITY_CONFIG)
		player.stats.luck = 0
		assert(lucky == global.calculate_tier_probability(wave, global.SHOP_PROBABILITY_CONFIG), "Luck remains uncalibrated, not applied yet")
	var spatula = load("res://resources/items/weapons/melee/spatula/item_spatula_1.tres")
	player.add_weapon(spatula)
	player.current_weapons[0].set_process(false)
	shop.load_shop(10)
	var held_key = spatula.get_offer_key()
	assert(shop.equipped_guarantee_shown)
	assert(shop.items_container.get_children().any(func(card): return card.shop_item.get_offer_key() == held_key))
	global.coins = 100000
	var previous := []
	for card in shop.items_container.get_children(): previous.append(card.shop_item.get_offer_key())
	assert(shop.try_reroll())
	for card in shop.items_container.get_children():
		assert(not previous.has(card.shop_item.get_offer_key()), "Refresh excludes every old family/passive")
	assert(not shop.items_container.get_children().any(func(card): return card.shop_item.get_offer_key() == held_key), "No repeat of the guaranteed family on the next refresh")
	shop.load_shop(10)
	assert(shop.items_container.get_children().any(func(card): return card.shop_item.get_offer_key() == held_key), "Guarantee returns on a new shop visit")
	var locked = shop.items_container.get_child(0)
	locked.set_locked(true)
	var locked_item = locked.shop_item
	var locked_price = locked.item_cost.text
	previous.clear()
	for card in shop.items_container.get_children(): previous.append(card.shop_item.get_offer_key())
	assert(shop.try_reroll())
	assert(shop.items_container.get_child(0) == locked and locked.shop_item == locked_item and locked.item_cost.text == locked_price)
	for card in shop.items_container.get_children():
		if card != locked: assert(not previous.has(card.shop_item.get_offer_key()))
	# With only the displayed catalogue, no compliant refresh is possible: no payment or mutation.
	var complete_catalog = shop.shop_items.duplicate()
	shop.shop_items.clear()
	for card in shop.items_container.get_children(): shop.shop_items.append(card.shop_item)
	var coins = global.coins
	var cards = shop.items_container.get_children()
	assert(not shop.try_reroll() and global.coins == coins and cards == shop.items_container.get_children())
	shop.shop_items.assign(complete_catalog)
	# Distinct tag matches, not the number of copies, determine weighting.
	var clone = spatula.duplicate()
	clone.tags.assign([0, 2])
	var tags: Array[int] = [0, 2]
	assert(policy.tag_weight(spatula, tags) == 2.0 and policy.tag_weight(clone, tags) == 3.0)
	var held = policy.equipped(player)
	held.append(spatula)
	assert(policy.families(held).size() == 1 and policy.shared_tags(held).size() == spatula.tags.size())
	# Below three EQUIPPED slots (copies included) there is a guarantee; at three,
	# drawing the owned family is probabilistic instead of mandatory.
	player.add_weapon(spatula)
	player.add_weapon(spatula)
	for weapon in player.current_weapons: weapon.set_process(false)
	shop.equipped_guarantee_shown = false
	var missing_owned := 0
	var found_owned := 0
	for sample in 100:
		var offers = shop.select_shop_offers(20)
		if offers.any(func(item): return item.get_offer_key() == held_key): found_owned += 1
		else: missing_owned += 1
	assert(missing_owned > 0 and found_owned > 0, "Three copies remove the mandatory offer")
	# Statistical check: 40% family-search branch + 60% unbiased 1/4 = 55% overall.
	# This also establishes that 40% is a search chance, not an overall hard cap.
	var weapon_script = load("res://resources/items/weapons/item_weapon.gd")
	var candidates := []
	for index in 4:
		var candidate = weapon_script.new()
		candidate.item_name = "Candidate_%d" % index
		candidate.tags.assign([0])
		candidates.append(candidate)
	held.clear()
	for copy in 3: held.append(candidates[0])
	seed(321321)
	var counts := [0, 0, 0, 0]
	for sample in 30000: counts[candidates.find(policy.choose(candidates, held))] += 1
	assert(absf(float(counts[0]) / 30000.0 - 0.55) < 0.015)
	# With no owned-family candidate: one shared tag -> 2, two -> 3, none -> 1.
	var held_only = weapon_script.new()
	held_only.item_name = "NotOffered"
	held_only.tags.assign([0, 2])
	held.clear()
	held.append(held_only)
	candidates.resize(3)
	candidates[0].tags.assign([0])
	candidates[1].tags.assign([0, 2])
	candidates[2].tags.assign([1])
	counts = [0, 0, 0]
	for sample in 30000: counts[candidates.find(policy.choose(candidates, held))] += 1
	for index in 3:
		assert(absf(float(counts[index]) / 30000.0 - [2.0/6.0, 3.0/6.0, 1.0/6.0][index]) < 0.015)
	# Full single-family loadout: restrict only when at most one copy is below IV.
	var tiers := []
	for tier in range(1,5): tiers.append(load("res://resources/items/weapons/melee/spatula/item_spatula_%d.tres" % tier))
	held.clear()
	for slot in player.get_weapon_limit(): held.append(tiers[3])
	for minimum in range(4):
		held[held.size()-1] = tiers[minimum]
		for tier in range(4):
			assert(policy.useful_tier(tiers[tier],held,held.size()) == (minimum < 3 and tier >= minimum))
		assert(policy.useful_tier(tiers[0],held,held.size()+1),"An extra free slot restores all tiers")
	var other=load("res://resources/items/weapons/range/kitchen_torch/item_kitchen_torch_1.tres")
	assert(policy.useful_tier(other,held,held.size()),"Other families remain available")
	held[0]=other
	assert(policy.useful_tier(tiers[0],held,held.size()),"Mixed loadouts keep previous rules")
	# Integration: catalogue filtering is shared by initial offers, refresh and refill.
	while player.current_weapons.size()<player.get_weapon_limit(): player.add_weapon(spatula)
	for equipped_weapon in player.current_weapons:
		equipped_weapon.set_process(false)
		equipped_weapon.data=tiers[3]
	for minimum in range(4):
		player.current_weapons.back().data=tiers[minimum]
		var eligible=shop._eligible_shop_items()
		for tier in range(4): assert(eligible.has(tiers[tier]) == (minimum<3 and tier>=minimum))
	# Two or more unfinished copies can combine to free a slot, so every tier is useful.
	for first_tier in range(3):
		for second_tier in range(3):
			for equipped_weapon in player.current_weapons: equipped_weapon.data=tiers[3]
			player.current_weapons[0].data=tiers[first_tier]
			player.current_weapons[1].data=tiers[second_tier]
			var eligible=shop._eligible_shop_items()
			for data in tiers: assert(eligible.has(data),"Two unfinished copies must keep all tiers available")
	# Screenshot regression: one III plus five II still allows a new tier I.
	for equipped_weapon in player.current_weapons: equipped_weapon.data=tiers[1]
	player.current_weapons[0].data=tiers[2]
	for data in tiers: assert(shop._eligible_shop_items().has(data))
	print("PASS useful weapon tiers: full IV, mixed IV/III, IV/II, IV/I, free slots, other families and shop catalogue")
	print("PASS shop progression: cumulative caps, unlocks, Luck deferred, per-visit family guarantee, refresh exclusions, locks/prices, atomic failure and tag weights")
	arena.queue_free()
	await process_frame
	quit()
