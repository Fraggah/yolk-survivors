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
	arena.spawner.wave_timer.stop()
	var actors: Array=[]
	for s in coop.sessions:
		actors.append(s.actor)
		s.actor.set_process(false)
		s.actor.passive_items.debug_yolk_magnet_chance=1.0
		for w in s.actor.current_weapons: w.set_process(false)
	seed(42)
	var recipients: Array=[]
	for i in 64:
		var coin=load("res://scenes/coins/coins.tscn").instantiate()
		arena.add_child(coin)
		coin.set_process(false)
		assert(coin.collected and actors.has(coin.magnet_target))
		if not recipients.has(coin.magnet_target): recipients.append(coin.magnet_target)
		var chosen=coin.magnet_target
		var other=actors[(actors.find(chosen)+1)%4]
		coin.global_position=other.global_position
		assert(coin._pickup_target()==chosen,"Proximity must not steal a magnet target")
		coin.queue_free()
	assert(recipients.size()==4,"All successful magnets participate in the draw")
	for actor in actors: actor.passive_items.debug_yolk_magnet_chance=0.0
	actors[3].passive_items.debug_yolk_magnet_chance=1.0
	var coin=load("res://scenes/coins/coins.tscn").instantiate()
	arena.add_child(coin)
	coin.set_process(false)
	assert(coin.magnet_target==actors[3],"A distant successful magnet wins even if nearest fails")
	actors[3].health_component.take_damage(100000)
	assert(coin._pickup_target()!=actors[3] and is_instance_valid(coin._pickup_target()))
	coin.queue_free()
	var failed=load("res://scenes/coins/coins.tscn").instantiate()
	arena.add_child(failed)
	failed.set_process(false)
	assert(not failed.collected and failed.magnet_target==null)
	actors[0].passive_items.debug_yolk_magnet_chance=1.0
	failed._try_spawn_attraction()
	assert(not failed.collected,"No repeated magnet rolls")
	failed.queue_free()
	print("PASS co-op magnets: independent procs, random successful recipient, fixed destination, downed fallback and no rerolls")
	coop.stop()
	arena.queue_free()
	await process_frame
	quit()
