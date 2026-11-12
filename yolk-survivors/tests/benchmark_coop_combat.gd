extends SceneTree
## Reproducible rendered co-op combat. --yolk-stress also exercises the cap and jar.
var actors=[]
var foes=[]
var frames=[]
var enemy_counts=[]
var costs={}
var peaks={}
var scenario="reported"
var population=250
var participants=2
var duration=25.0
var tier=3
var batch=0
var tested_weapons=[]
var mortal=false
var replacements=0
var no_status=false
var capture=false
var profile=false
var yolk_stress=false
var arena
var global
func _initialize(): call_deferred("run")
func percentile(values,fraction):
	var sorted=values.duplicate()
	sorted.sort()
	return sorted[mini(sorted.size()-1,int(sorted.size()*fraction))]
func run():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--case="): scenario=arg.get_slice("=",1)
		if arg.begins_with("--enemies="): population=int(arg.get_slice("=",1))
		if arg.begins_with("--players="): participants=int(arg.get_slice("=",1))
		if arg.begins_with("--seconds="): duration=float(arg.get_slice("=",1))
		if arg.begins_with("--tier="): tier=int(arg.get_slice("=",1))
		if arg.begins_with("--batch="): batch=int(arg.get_slice("=",1))
		if arg=="--mortal": mortal=true
		if arg=="--no-status": no_status=true
		if arg=="--capture": capture=true
		if arg=="--profile": profile=true
		if arg=="--yolk-stress": yolk_stress=true
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps=0
	RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(),true)
	load("res://tests/progression_fixture.gd").prepare(root)
	arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	await process_frame
	global=root.get_node("Global")
	arena.coop.open()
	for i in participants: arena.coop.join(i-1)
	arena.coop.start_run()
	arena.spawner.spawn_timer.stop()
	arena.spawner.wave_timer.stop()
	arena.stage_mechanics.stop()
	var paths=["range/the_bloody/item_bloody_1","chili/carolina_reaper/item_carolina_reaper","chili/cayenne/item_cayenne","range/kitchen_torch/item_kitchen_torch_1","melee/electric_knife/item_electric_knife_1","melee/butcher_knife/item_knife_1"]
	var catalogue=[]
	for item in arena.weapon_selection_panel.weapons_list:
		if item.item_tier==0 and not catalogue.has(item): catalogue.append(item)
	for kind in ["melee","ranged","spicy","pet"]:
		for item in load("res://resources/items/weapons/"+kind+"_catalogue.gd").items():
			if not catalogue.has(item): catalogue.append(item)
	catalogue=catalogue.filter(func(item): return global.is_valid_starting_weapon(item))
	for session in arena.coop.sessions:
		var actor=session.actor
		actors.append(actor)
		actor.set_process(false)
		actor.health_component.debug_invulnerable=true
		for w in actor.current_weapons: w.queue_free()
		actor.current_weapons.clear()
		var chosen=[0,0,0,0,0,0] if session.slot%2==0 else [1,2,3,4,4,5]
		if scenario=="all": chosen=[0,1,2,3,4,5]
		for slot_index in chosen.size():
			var index=chosen[slot_index]
			if scenario=="baseline": continue
			if scenario=="no_spicy" and index in [1,2]: continue
			if scenario=="no_reaper" and index==1: continue
			if scenario=="no_cayenne" and index==2: continue
			var item=load("res://resources/items/weapons/"+paths[index]+".tres")
			if scenario=="catalogue":
				var catalogue_index=batch*participants*6+session.slot*6+slot_index
				item=catalogue[catalogue_index % catalogue.size()]
			for upgrade in tier:
				if item.upgrade_to: item=item.upgrade_to
			var count=actor.current_weapons.size()
			actor.add_weapon(item)
			if actor.current_weapons.size()!=count+1:
				push_error("Benchmark failed to equip an actual weapon")
				quit(2)
				return
			tested_weapons.append(item.item_name+" "+str(item.item_tier))
	seed(14102026)
	for i in population:
		var enemy=load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
		enemy.stats=enemy.stats.duplicate()
		enemy.stats.block_chance=0
		if yolk_stress: enemy.stats.coin_drop=3
		enemy.status_immune=no_status
		arena.add_child(enemy)
		enemy.global_position=Vector2.from_angle(i*2.399963)*lerpf(80.0,700.0,float(i)/population)
		enemy.health_component.max_health=250 if mortal else 10000000
		enemy.health_component.current_health=enemy.health_component.max_health
		foes.append(enemy)
		if i%10==0: await process_frame
	if yolk_stress:
		var initial_value: int = arena.uncollected_yolk_value()
		for i in 100:
			arena.spawn_yolk_at(Vector2.from_angle(i*2.399963)*800, 3)
		if arena.gold_list.size() != mini(300, arena.yolk_pickup_limit) or arena.uncollected_yolk_value() != initial_value + 300:
			push_error("Initial yolk pressure did not preserve the cap and total")
			quit(2)
			return
	else:
		for i in 150:
			var coin=load("res://scenes/coins/coins.tscn").instantiate()
			coin.position=Vector2.from_angle(i*2.399963)*800
			arena.add_child(coin)
	var began=Time.get_ticks_usec()
	var fire_contacts=root.get_node("FireContacts")
	fire_contacts.profile_enabled=profile
	var last=began
	var draw_calls=0.0
	var physics=0.0
	var gpu=0.0
	var process_ms=0.0
	var render_cpu=0.0
	var physics_steps=0.0
	var previous_physics=Engine.get_physics_frames()
	var next_burst := 2.0
	var bursts := 0
	while Time.get_ticks_usec()-began<duration*1000000:
		await process_frame
		var now=Time.get_ticks_usec()
		var elapsed=(now-began)/1000000.0
		var dt=(now-last)/1000000.0
		var steps=Engine.get_physics_frames()-previous_physics
		previous_physics=Engine.get_physics_frames()
		last=now
		for i in actors.size():
			actors[i].global_position=Vector2(sin(elapsed*0.5+i*PI)*350,cos(elapsed*0.7+i*PI)*230)
		var spawn_started=Time.get_ticks_usec()
		if mortal:
			# Replace at most one killed enemy per rendered frame, without spawn bursts.
			for i in foes.size():
				if is_instance_valid(foes[i]) and not foes[i].is_queued_for_deletion() and foes[i].health_component.current_health>0: continue
				var enemy=load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
				enemy.stats=enemy.stats.duplicate()
				enemy.stats.block_chance=0
				if yolk_stress: enemy.stats.coin_drop=3
				arena.add_child(enemy)
				enemy.global_position=Vector2.from_angle(randf()*TAU)*650
				enemy.health_component.max_health=250
				enemy.health_component.current_health=250
				foes[i]=enemy
				replacements+=1
				break
		if yolk_stress and elapsed >= next_burst:
			var before: int = arena.uncollected_yolk_value()
			arena.spawn_yolk_burst(Vector2.from_angle(bursts * 2.399963) * 650, 25)
			if arena.uncollected_yolk_value() != before + 25 or arena.gold_list.size() > arena.yolk_pickup_limit:
				push_error("Yolker burst exceeded the cap or lost currency")
				quit(2)
				return
			bursts += 1
			next_burst = elapsed + 3.0
		fire_contacts.finish_profile("benchmark_replacement",spawn_started)
		# Read last frame's timings without changing the real process order/delta.
		for key in fire_contacts.profile_costs:
			costs[key]=costs.get(key,0.0)+fire_contacts.profile_costs[key]
		fire_contacts.profile_costs.clear()
		if elapsed<5.0:
			costs.clear()
			continue
		frames.append(dt*1000)
		enemy_counts.append(fire_contacts.samples.size())
		draw_calls+=Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		physics+=Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000
		gpu+=RenderingServer.viewport_get_measured_render_time_gpu(root.get_viewport_rid())
		process_ms+=Performance.get_monitor(Performance.TIME_PROCESS)*1000
		render_cpu+=RenderingServer.viewport_get_measured_render_time_cpu(root.get_viewport_rid())
		physics_steps+=steps
		for group in ["projectiles","reaper_trails","yolks","combat_texts"]:
			peaks[group]=maxi(peaks.get(group,0),get_nodes_in_group(group).size())
	var total=0.0
	for frame in frames: total+=frame
	for key in costs: costs[key]/=frames.size()
	if scenario in ["all", "reported", "catalogue"] and tested_weapons.size()!=participants*6:
		push_error("Benchmark requires six weapons for every participant")
		quit(2)
		return
	var result={"case":scenario,"players":participants,"tier":tier+1,"enemies":population,"seconds":duration,"frames":frames.size(),"active_enemies_min":enemy_counts.min(),"active_enemies_max":enemy_counts.max(),"active_enemies_mean":float(enemy_counts.reduce(func(a,b): return a+b,0))/enemy_counts.size(),"fps":1000.0*frames.size()/total,"mean_ms":total/frames.size(),"p95_ms":percentile(frames,0.95),"p99_ms":percentile(frames,0.99),"draw_calls":draw_calls/frames.size(),"physics_ms":physics/frames.size(),"gpu_ms":gpu/frames.size(),"effect_ms_per_frame":costs,"peak_nodes":peaks,"gpu":RenderingServer.get_video_adapter_name(),"viewport":str(root.size)}
	result["weapons"]=tested_weapons
	result["catalogue_size"]=catalogue.size()
	result["batch"]=batch
	result["mortal"]=mortal
	result["replacements"]=replacements
	result["profile_enabled"]=profile
	result["renderer"]=RenderingServer.get_current_rendering_method()
	result["build"]="debug" if OS.is_debug_build() else "release"
	result["cpu"]=OS.get_processor_name()
	result["process_ms"]=process_ms/frames.size()
	result["render_cpu_ms"]=render_cpu/frames.size()
	result["physics_steps_per_frame"]=physics_steps/frames.size()
	var field=root.get_node("GroundFire")
	if not field.patches.is_empty():
		assert(field.floor_batch.multimesh.visible_instance_count>0)
		assert(field.floor_batch.multimesh.get_instance_transform_2d(0).x.length()>1.0,"Ground fire must really be rendered")
	if capture:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("user://goal60-capture.png"))
	if yolk_stress:
		for foe in foes:
			if is_instance_valid(foe) and not foe.is_queued_for_deletion():
				arena.spawner.spawned_enemies.append(foe)
		var bank: int = arena.uncollected_yolk_value()
		var physical: int = get_nodes_in_group("yolks").size()
		var jar_frames: Array[float] = []
		var jar_start := Time.get_ticks_usec()
		var jar_last := jar_start
		arena.coop.wave_completed()
		var credited := 0
		for session in arena.coop.sessions: credited += session.reserve
		if credited != bank:
			push_error("Co-op jar split did not preserve the pending and physical yolks")
			quit(2)
			return
		while Time.get_ticks_usec() - jar_start < 900000:
			await process_frame
			var now := Time.get_ticks_usec()
			jar_frames.append((now - jar_last) / 1000.0)
			jar_last = now
		result["yolk_stress"] = {"bursts": bursts, "pickup_limit": arena.yolk_pickup_limit, "jar_pickups": physical,
			"jar_value": bank, "credited": credited, "end_wave_p95_ms": percentile(jar_frames, 0.95),
			"end_wave_max_ms": jar_frames.max()}
		while arena.coop.transitioning:
			await process_frame
	var path="res://../tmp/coop-benchmark-"+scenario+"-"+str(participants)+"-"+str(population)+".json"
	if scenario=="catalogue": path=path.get_basename()+"-"+str(batch)+".json"
	if mortal: path=path.get_basename()+"-mortal.json"
	if yolk_stress: path=path.get_basename()+"-yolk-stress.json"
	if not OS.is_debug_build(): path="user://"+path.get_file()
	FileAccess.open(path,FileAccess.WRITE).store_string(JSON.stringify(result,"\t"))
	print(JSON.stringify(result))
	quit()
