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
	for session in coop.sessions:
		session.actor.set_process(false)
		for weapon in session.actor.current_weapons: weapon.set_process(false)
	for index in 24:
		var enemy=load("res://scenes/units/enemies/enemy_incognito.tscn").instantiate()
		arena.add_child(enemy)
		enemy.set_process(false)
		var before=coop.sessions.map(func(s): return s.rewards.size())
		arena._on_enemy_died(enemy)
		var recipients:=0
		for i in 4:
			var added=coop.sessions[i].rewards.size()-before[i]
			assert(added==0 or added==1)
			recipients+=added
		assert(recipients==1,"Each Incognito grants exactly one item to one player")
		var effects=get_nodes_in_group("incognito_confetti")
		assert(effects.size()==1 and effects[0].pieces.size()==72)
		assert(effects[0].origin.is_equal_approx(arena.to_local(enemy.sprite.to_global(Vector2.ZERO))-effects[0].position))
		arena._on_enemy_died(enemy)
		for i in 4: assert(coop.sessions[i].rewards.size()-before[i]<=1)
		assert(get_nodes_in_group("incognito_confetti").size()==1)
		effects[0].queue_free()
		enemy.queue_free()
		await process_frame
	print("PASS co-op Incognito: shared death effect, one random recipient per kill, duplicate guard and pending item limits")
	coop.stop()
	arena.queue_free()
	await process_frame
	quit()
