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
	coop._process(0)
	await process_frame
	var viewport=root.get_visible_rect()
	for i in 4:
		var widget=coop.hud.get_node("P%d" % (i+1))
		assert(widget.visible and widget.get_node("PlayerLabel").text=="P%d" % (i+1))
		var center=widget.get_global_rect().get_center()
		assert((center.x>viewport.size.x/2)==(i%2==1))
		assert((center.y>viewport.size.y/2)==(i>=2))
	for i in 4:
		var widget=coop.hud.get_node("P%d" % (i+1))
		assert(widget.get_node("Wallet/Balance/Value").text==str(coop.sessions[i].coins))
		assert(widget.get_node("Wallet/Reserve").visible==(i==0))
		var wallet=widget.get_node("Wallet/Balance").get_global_rect()
		assert((wallet.get_center().y>widget.get_global_rect().get_center().y)==(i<2))
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/coop-four-corner-hud.png"))
	var coin=load("res://scenes/coins/coins.tscn").instantiate()
	arena.add_child(coin)
	coin.global_position=Vector2(800,800)
	coin.value=13
	arena.gold_list.append(coin)
	var enemy=load("res://scenes/units/enemies/enemy_chaser.tscn").instantiate()
	arena.add_child(enemy)
	enemy.set_process(false)
	arena.spawner.spawned_enemies.append(enemy)
	coop.wave_completed()
	await create_timer(0.05).timeout
	assert(coop.transitioning and coop.mode=="combat" and not coop.screen.visible)
	assert(is_instance_valid(coin) and coin.flying_to_jar)
	assert(coin.jar_target==coop.hud.get_node("P1/Wallet/Reserve/Icon"))
	assert(coop.sessions[0].reserve==4 and coop.sessions[1].reserve==3)
	await create_timer(1.1).timeout
	assert(not is_instance_valid(coin) and not is_instance_valid(enemy))
	assert(coop.mode=="shop" and not coop.hud.is_visible_in_tree() and not arena.coins_bag.visible)
	assert(not arena.environment_controller.debug_stage_selector.visible)
	print("PASS co-op corner HUD, yolk flight, reserve split, enemy retirement and shop visibility")
	coop.stop()
	arena.queue_free()
	await process_frame
	quit()
