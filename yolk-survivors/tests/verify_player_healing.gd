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
	var hp=player.health_component
	hp.max_health=100
	var pulses=[]
	global.on_create_heal_text.connect(func(unit,amount):
		if unit==player: pulses.append(amount))
	global.game_paused=false
	for points in [1.0,5.0,7.0,8.0,20.0]:
		player.stats.hp_regen=points
		player._regen_credit=0
		hp.healing_credit=0
		hp.current_health=50
		pulses.clear()
		for tick in 100: player._on_hp_timer_timeout()
		assert(is_equal_approx(hp.current_health,50+points),"Unchanged regeneration rate over ten seconds")
		for amount in pulses: assert(is_equal_approx(amount,1.0),"Only whole recovery points are applied and reported")
	player.stats.hp_regen=0.5
	player._regen_credit=0
	hp.healing_credit=0
	hp.current_health=50
	for tick in 100: player._on_hp_timer_timeout()
	assert(hp.current_health==50 and is_equal_approx(hp.healing_credit,0.5))
	for tick in 100: player._on_hp_timer_timeout()
	assert(hp.current_health==51)
	# Pausing adds no regeneration or lifesteal credit.
	hp.current_health=50
	hp.healing_credit=0
	player._regen_credit=0
	player.stats.hp_regen=5
	global.game_paused=true
	for tick in 100: player._on_hp_timer_timeout()
	assert(not player.try_life_steal(1.0))
	assert(hp.current_health==50 and hp.healing_credit==0)
	global.game_paused=false
	# Ten successful 0.1 lifesteal procs produce one actual heal and one number.
	for chance in [1.0,3.0,50.0,80.0]:
		hp.current_health=50
		hp.healing_credit=0
		pulses.clear()
		for hit in 9:
			player.life_steal_cooldown=0
			assert(player.try_life_steal(chance))
			assert(not player.try_life_steal(chance))
			assert(hp.current_health==50 and pulses.is_empty())
		player.life_steal_cooldown=0
		assert(player.try_life_steal(chance))
		assert(hp.current_health==51 and pulses==[1.0])
	# Regen and lifesteal share credit; no lost fractions or duplicate healing.
	hp.current_health=50
	hp.healing_credit=0
	player._regen_credit=0
	player.stats.hp_regen=1
	player._update_regeneration(6)
	assert(hp.current_health==50 and is_equal_approx(hp.healing_credit,0.6))
	for hit in 4:
		player.life_steal_cooldown=0
		assert(player.try_life_steal(1.0))
	assert(hp.current_health==51)
	# Even a partial gap below max HP waits for the complete unit of credit.
	hp.current_health=99.95
	hp.healing_credit=0
	player._regen_credit=0
	player.stats.hp_regen=8
	player._update_regeneration(1.0)
	assert(hp.current_health==99.95)
	player._update_regeneration(0.25)
	assert(hp.current_health==100 and hp.healing_credit==0)
	assert(root.get_node("CombatTexts").active.back().label.text=="+ 1")
	# Full/dead characters cannot bank recovery; new waves discard residual credit.
	hp.healing_credit=0.9
	player._update_regeneration(1)
	assert(hp.healing_credit==0)
	hp.current_health=0
	player._update_regeneration(10)
	assert(hp.current_health==0)
	hp.current_health=50
	hp.healing_credit=0.9
	player.prepare_for_new_wave()
	assert(hp.healing_credit==0 and player._regen_credit==0)
	# Damage display also retains fractions instead of emitting decimals or zeros.
	var texts=root.get_node("CombatTexts")
	texts.clear()
	texts.queue_damage(player,0.4,Color.WHITE,false)
	texts.queue_damage(player,0.3,Color.WHITE,false)
	texts._process(1)
	assert(texts.active.is_empty())
	texts.queue_damage(player,0.4,Color.WHITE,false)
	texts._process(1)
	assert(texts.active.back().label.text=="1")
	assert(is_equal_approx(texts.pending_damage[player.get_instance_id()].amount,0.1))
	texts.queue_damage(player,0.9,Color.WHITE,false)
	texts._process(1)
	assert(texts.active.back().label.text=="1" and texts.pending_damage.is_empty())
	# Exercise the real regeneration timer at 0.5 HP/s: no heal before two seconds.
	hp.max_health=100
	hp.current_health=50
	hp.healing_credit=0
	player._regen_credit=0
	player.stats.hp_regen=5
	timer.start()
	await create_timer(1.05).timeout
	assert(hp.current_health==50)
	await create_timer(1.05).timeout
	timer.stop()
	assert(hp.current_health==51)
	arena.queue_free()
	await process_frame
	print("PASS whole healing: regen rate, fractional/shared credit, ten lifesteal procs, pause/full/death/wave reset, cap and integer damage/heal texts, real timer")
	quit()
