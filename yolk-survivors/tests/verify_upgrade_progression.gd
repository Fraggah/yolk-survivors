extends SceneTree
func _initialize(): call_deferred("verify")
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
	var policy=load("res://resources/upgrade_rarity.gd")
	assert(policy.probabilities(1)==[1.0,0.0,0.0,0.0])
	assert(policy.probabilities(2)==[1.0,0.0,0.0,0.0])
	assert(is_equal_approx(policy.probabilities(3)[1],1.0/30.0))
	assert(is_equal_approx(policy.probabilities(10)[2],0.2/11.0))
	assert(is_equal_approx(policy.probabilities(15)[3],0.05/6.0))
	var end=policy.probabilities(20)
	for tier in 4: assert(is_equal_approx(end[tier],[0.4,0.4,0.15,0.05][tier]))
	assert(policy.probabilities(100)==end)
	var panel=arena.upgrade_panel
	seed(141415)
	for level in range(1,101):
		var chances=policy.probabilities(level)
		assert(is_equal_approx(chances[0]+chances[1]+chances[2]+chances[3],1.0))
		var cumulative=policy.cumulative(level)
		for tier in 3: assert(cumulative[tier]<=policy.CAPS[tier])
		for luck in [-100,0,200,1000]:
			player.stats.luck=luck
			assert(global.calculate_tier_probability(level,global.UPGRADE_PROBABILITY_CONFIG)==chances)
		for sample in 30:
			var offers=global.select_items_for_offer(panel.upgrades,level,global.UPGRADE_PROBABILITY_CONFIG)
			assert(offers.size()==4)
			var keys:=[]
			for item in offers:
				assert(not keys.has(item.get_offer_key()))
				keys.append(item.get_offer_key())
				if level<3: assert(item.item_tier==0)
				if level<10: assert(item.item_tier<2)
				if level<15: assert(item.item_tier<3)
	# UI and refresh use the awarded CHARACTER level, not the completed wave.
	global.game_paused=true
	global.coins=10000
	panel.begin_wave_rewards(1)
	panel.show()
	for level in [2,3,10,15,20]:
		panel.load_upgrades(level)
		assert(panel.offer_level==level and panel.completed_wave==1)
		var price=panel.get_reroll_cost()
		var before=global.coins
		assert(panel.try_reroll())
		assert(panel.offer_level==level and global.coins==before-price)
		assert(panel.item_container.get_child_count()==4)
		if level==2:
			for card in panel.item_container.get_children(): assert(card.item.item_tier==0)
	# Store thresholds remain distinct (Rare 2+, Epic 9+).
	assert(global.calculate_tier_probability(2,global.SHOP_PROBABILITY_CONFIG)[1]>0)
	assert(global.calculate_tier_probability(9,global.SHOP_PROBABILITY_CONFIG)[2]>0)
	assert(policy.probabilities(2)[1]==0 and policy.probabilities(9)[2]==0)
	arena.queue_free()
	await process_frame
	print("PASS upgrade progression: Common 1-2, unlocks 3/10/15, caps at 20, no Luck, 12000 actual offers, unique stats, character-level refresh and separate store curve")
	quit()
