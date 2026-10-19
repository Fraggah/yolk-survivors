extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	global.main_player_selected=arena.selection_panel.player_list[0]
	var player=global.get_selected_player()
	arena.add_child(player)
	player.set_process(false)
	player.set_physics_process(false)
	var timer=player.get_node("HPTimer")
	timer.stop()
	assert(is_equal_approx(timer.wait_time,0.1))
	var hp=player.health_component
	player.stats.health=100
	hp.max_health=100
	var pulses:=[]
	global.on_create_heal_text.connect(func(unit,amount):
		if unit==player: pulses.append(amount))
	global.game_paused=false
	for points in [1.0,5.0,7.0,8.0,20.0]:
		player.stats.hp_regen=points
		player._regen_credit=0
		hp.current_health=50
		pulses.clear()
		for tick in 30: player._on_hp_timer_timeout()
		assert(is_equal_approx(hp.current_health,50+points*0.3),"Each point gives 0.1 HP/s over three seconds")
		for amount in pulses: assert(amount>0 and amount<=0.10000001,"Individual regen pulses cannot become a burst of the stat")
	# Fractional stats accumulate without being rounded away.
	player.stats.hp_regen=0.5
	player._regen_credit=0
	hp.current_health=50
	for tick in 20: player._on_hp_timer_timeout()
	assert(is_equal_approx(hp.current_health,50.1))
	# No healing while paused, no accumulated paused time paid after resuming.
	player.stats.hp_regen=5
	player._regen_credit=0
	hp.current_health=50
	global.game_paused=true
	for tick in 100: player._on_hp_timer_timeout()
	assert(hp.current_health==50 and player._regen_credit==0)
	global.game_paused=false
	player._on_hp_timer_timeout()
	assert(hp.current_health==50)
	player._on_hp_timer_timeout()
	assert(is_equal_approx(hp.current_health,50.1))
	# Full health discards credit rather than banking healing for the next hit.
	hp.current_health=100
	for tick in 100: player._on_hp_timer_timeout()
	assert(player._regen_credit==0)
	hp.current_health=50
	player._on_hp_timer_timeout()
	assert(hp.current_health==50)
	player.stats.hp_regen=-10
	player._on_hp_timer_timeout()
	assert(hp.current_health==50 and player._regen_credit==0)
	hp.current_health=0
	player.stats.hp_regen=8
	player._update_regeneration(10)
	assert(hp.current_health==0)
	# Last partial pulse clamps to max health and reports only actual healing.
	hp.current_health=99.95
	pulses.clear()
	player._on_hp_timer_timeout()
	assert(hp.current_health==100 and player._regen_credit==0)
	assert(pulses.size()==1 and is_equal_approx(pulses[0],0.05))
	# All hit sources share the lifesteal cooldown; excess chance stays one 0.1 heal.
	hp.current_health=50
	for chance in [1.0,3.0,50.0,80.0]:
		player.life_steal_cooldown=0
		var before=hp.current_health
		assert(player.try_life_steal(chance))
		assert(is_equal_approx(hp.current_health-before,0.1))
		assert(not player.try_life_steal(chance))
	# Actual timer, not just manual invocations: around 0.5 HP over one second.
	hp.current_health=50
	player.stats.hp_regen=5
	player._regen_credit=0
	timer.start()
	await create_timer(1.05).timeout
	timer.stop()
	assert(hp.current_health>=50.39999 and hp.current_health<=50.60001)
	player._regen_credit=0.09
	player.prepare_for_new_wave()
	assert(player._regen_credit==0)
	arena.queue_free()
	await process_frame
	print("PASS healing: 0.1 HP/s per regen point, 0.1 pulses, fractional stats, pause/full/death/reset, actual timer and one lifesteal heal per hit with shared cooldown")
	quit()
