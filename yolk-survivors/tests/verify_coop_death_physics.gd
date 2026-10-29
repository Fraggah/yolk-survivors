extends SceneTree
var physics_hits := 0
func _initialize(): call_deferred("verify")
func lethal_contact(arena, actor):
	var sensor=Area2D.new()
	sensor.collision_layer=0
	sensor.collision_mask=actor.collision_layer
	var shape=CollisionShape2D.new()
	shape.shape=CircleShape2D.new()
	shape.shape.radius=48
	sensor.add_child(shape)
	sensor.area_entered.connect(func(area):
		if area==actor:
			physics_hits+=1
			actor.health_component.take_damage(100000))
	sensor.position=actor.position
	arena.add_child(sensor)
	for i in 12:
		await physics_frame
		await process_frame
		if actor.health_component.current_health<=0: break
	assert(actor.health_component.current_health==0,"Lethal damage must originate inside area_entered")
	for i in 2: await process_frame
	assert(actor.process_mode==Node.PROCESS_MODE_DISABLED)
	assert(not actor.visible)
	sensor.queue_free()
	await process_frame
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	await process_frame
	var coop=arena.coop
	coop.open()
	var first=coop.join(-1)
	var second=coop.join(0)
	coop.start_run()
	arena.spawner.spawn_timer.stop()
	arena.spawner.wave_timer.stop()
	for session in coop.sessions:
		for weapon in session.actor.current_weapons: weapon.set_process(false)
	var weapon_count=first.actor.current_weapons.size()
	await lethal_contact(arena,first.actor)
	assert(coop.mode=="combat" and coop.corpses.size()==1)
	assert(first.actor.current_weapons.size()==weapon_count)
	await coop.wave_completed()
	assert(coop.mode=="shop")
	coop.next_wave()
	arena.spawner.spawn_timer.stop()
	arena.spawner.wave_timer.stop()
	for i in 3: await process_frame
	assert(first.actor.visible and first.actor.health_component.current_health>0)
	assert(first.actor.process_mode==Node.PROCESS_MODE_INHERIT)
	await lethal_contact(arena,first.actor)
	await lethal_contact(arena,second.actor)
	assert(coop.mode=="result")
	assert(physics_hits==3)
	print("PASS cooperative death in real physics callbacks: corpse/build preserved, deferred disable, next-wave revival and team defeat")
	arena.queue_free()
	await process_frame
	quit()
