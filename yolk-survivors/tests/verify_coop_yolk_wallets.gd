extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	await process_frame
	var coop=arena.coop
	coop.open()
	for device in [-1,0,1,2]: coop.join(device)
	coop.start_run()
	arena.spawner.spawn_timer.stop()
	for s in coop.sessions:
		s.actor.set_process(false)
		for weapon in s.actor.current_weapons: weapon.set_process(false)
	coop.sessions[2].actor.health_component.take_damage(100000)
	for i in 4:
		coop.sessions[i].coins=10+i
		coop.sessions[i].reserve=i
	var coin=load("res://scenes/coins/coins.tscn").instantiate()
	arena.add_child(coin)
	coin.set_process(false)
	coin.value=2
	coin.add_coins()
	coin.add_coins()
	for i in 4:
		assert(coop.sessions[i].coins==10+i+2+mini(i,2))
		assert(coop.sessions[i].reserve==maxi(0,i-2))
	coop.collect_yolk(0)
	coop.collect_yolk(-3)
	for i in 4: assert(coop.sessions[i].coins==10+i+2+mini(i,2))
	print("PASS full pickup value for all four wallets, downed players, personal reserves and duplicate guard")
	coop.stop()
	arena.queue_free()
	await process_frame
	quit()
