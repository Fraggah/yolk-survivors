extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var policy=load("res://resources/rewards/incognito_loot.tres")
	var random=RandomNumberGenerator.new()
	random.seed=19102026
	var anchors=[[0.0,[0.65,0.25,0.09,0.01]],[500.0,[0.25,0.25,0.25,0.25]],[1500.0,[0.0,1.0/3,1.0/3,1.0/3]],[3000.0,[0.0,0.0,0.5,0.5]],[5000.0,[0.0,0.0,0.0,1.0]],[10000.0,[0.0,0.0,0.0,1.0]]]
	for anchor in anchors:
		var chances=policy.probabilities(anchor[0])
		var counts=[0,0,0,0]
		for tier in 4: assert(is_equal_approx(chances[tier],anchor[1][tier]))
		for draw in 30000: counts[policy.roll_tier(anchor[0],random)]+=1
		for tier in 4:
			var tolerance=6.0*sqrt(chances[tier]*(1.0-chances[tier])/30000)+0.001
			assert(absf(float(counts[tier])/30000-chances[tier])<tolerance)
			if chances[tier]==0: assert(counts[tier]==0)
	for luck in range(-100,5500,13):
		var chances=policy.probabilities(luck)
		assert(is_equal_approx(chances[0]+chances[1]+chances[2]+chances[3],1))
		for chance in chances: assert(chance>=0 and chance<=1)
	var mid=policy.probabilities(250)
	for tier in 4: assert(is_equal_approx(mid[tier],[0.45,0.25,0.17,0.13][tier]))
	assert(policy.probabilities(-10)==policy.probabilities(0))
	var global=root.get_node("Global")
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	global.main_player_selected=arena.selection_panel.player_list[0]
	var player=global.get_selected_player()
	arena.add_child(player)
	player.set_process(false)
	var pending:=[]
	for luck in [0,500,1500,3000,5000]:
		player.stats.luck=luck
		for draw in 30:
			var item=policy.select_item(player,[],random)
			assert(item!=null and item.item_type==2 and item.available_for(player))
			if luck>=1500: assert(item.item_tier>0)
			if luck>=3000: assert(item.item_tier>1)
			if luck>=5000: assert(item.item_tier==3)
			if item.max_copies>0:
				if not pending.any(func(entry): return entry.item.get_offer_key()==item.get_offer_key()): pending.append({"item":item})
	# Reserved unique items cannot be rolled again; an exhausted rarity can fall back.
	for draw in 50:
		var item=policy.select_item(player,pending,random)
		if item.max_copies>0:
			assert(not pending.any(func(entry): return entry.item.get_offer_key()==item.get_offer_key()))
			pending.append({"item":item})
	var keys:=[]
	for entry in pending:
		assert(not keys.has(entry.item.get_offer_key()))
		keys.append(entry.item.get_offer_key())
	arena.queue_free()
	await process_frame
	print("PASS Incognito loot: 180000 draws, exact base and luck milestones, smooth interpolation, late-tier elimination, passive-only catalogue and unique reservations")
	quit()
