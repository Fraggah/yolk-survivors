extends SceneTree
func _initialize(): call_deferred("verify")

func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	await process_frame
	var global=root.get_node("Global")
	var coop=arena.coop
	coop.open()
	var first=coop.join(-1)
	var second=coop.join(3)
	assert(coop.join(3)==second and coop.sessions.size()==2)
	assert(coop.MAX_PLAYERS==4)
	assert(coop.lobby.get_node("Players").get_index()==1)
	await process_frame
	var center=coop.lobby.get_node("Players").get_global_rect().get_center().x
	assert(absf(center-root.get_visible_rect().get_center().x)<2,"Player cards stay centered between symmetric slots")
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/local-coop-lobby.png"))
	first.character=arena.selection_panel.player_list[0]
	second.character=arena.selection_panel.player_list[1]
	for item in arena.weapon_selection_panel.weapons_list:
		if global.is_valid_starting_weapon(item) and second.character.can_use_weapon(item): second.weapon=item; break
	coop.start_run()
	assert(coop.active and global.coop_players.size()==2 and arena.wave_active)
	assert(first.actor!=second.actor and first.actor.stats!=second.actor.stats)
	assert(first.actor.coop_session==first and second.actor.coop_session==second)
	assert(first.actor.global_position!=second.actor.global_position)
	assert(arena.get_node("Camera2D").overview)
	for session in coop.sessions:
		session.actor.set_process(false)
		session.actor.get_node("HPTimer").stop()
		for weapon in session.actor.current_weapons:
			weapon.set_process(false)
			weapon.cooldown_timer.stop()
	# A gamepad event targets only its registered participant.
	var event=InputEventJoypadButton.new()
	event.device=3
	event.button_index=JOY_BUTTON_A
	event.pressed=true
	coop._input(event)
	assert(second.dash_requested and not first.dash_requested)
	second.dash_requested=false
	var before=first.coins+second.coins
	coop.collect_yolk(101)
	assert(first.coins+second.coins==before+202)
	assert(absi(first.coins-second.coins)<=1)
	coop.collect_yolk(1)
	assert(first.coins==second.coins)
	assert(not arena.spawner.is_spawn_position_safe(second.actor.global_position))
	assert(global.nearest_player(second.actor.global_position)==second.actor)
	# XP is awarded once to both with their individual gain modifiers.
	var enemy=load("res://scenes/units/enemies/enemy_chaser.tscn").instantiate()
	arena.add_child(enemy)
	enemy.stats.experience_reward=5
	var xp1=first.experience.experience
	var xp2=second.experience.experience
	coop.enemy_died(enemy)
	assert(first.experience.experience>xp1 and second.experience.experience>xp2)
	var after=first.experience.experience
	coop.enemy_died(enemy)
	assert(first.experience.experience==after)
	enemy.queue_free()
	# A downed actor persists with its build; the other remains a valid target.
	first.actor.health_component.take_damage(100000)
	assert(is_instance_valid(first.actor) and first.actor.health_component.current_health==0)
	assert(coop.mode=="combat" and not global.game_paused)
	assert(global.nearest_player(first.actor.global_position)==second.actor)
	assert(coop.corpses.size()==1 and coop.corpses[0].global_position.is_equal_approx(first.actor.global_position))
	await process_frame
	assert(coop.hud.get_node("P1").visible and coop.hud.get_node("P2").visible)
	assert(not coop.hud.get_node("P3").visible and not arena.environment_controller.debug_stage_selector.visible)
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/coop-gameplay-hud.png"))
	await coop.wave_completed()
	assert(coop.corpses.is_empty() and not arena.coins_bag.visible)
	assert(coop.mode=="shop" and global.game_paused and coop.panels.size()==4)
	# Own wallet and stat changes are isolated, including level-up queues.
	var other=second.actor.stats.damage_percent
	first.experience.grant_levels(1)
	coop._show_post_wave_phase("upgrades")
	assert(first.offers.size()==4)
	coop.activate(first,0)
	assert(first.experience.pending_levels.is_empty())
	assert(second.actor.stats.damage_percent==other)
	var passive=null
	for candidate in coop._pool(first):
		if candidate.get("effect_key")=="oregano": passive=candidate; break
	assert(passive!=null)
	first.coins=1000
	first.offers[0]=passive
	var other_effects=second.actor.stats.effects
	coop.activate(first,0)
	assert(first.actor.passive_items.count("oregano")==1)
	assert(second.actor.passive_items.count("oregano")==0 and second.actor.stats.effects==other_effects)
	first.coins=1000
	var own=first.coins
	var other_coins=second.coins
	coop.activate(first,4)
	assert(first.coins<own and second.coins==other_coins)
	var weapons=0
	for offer in first.offers:
		if offer and is_instance_of(offer,load("res://resources/items/weapons/item_weapon.gd")): weapons+=1
	assert(weapons<=2)
	if OS.get_cmdline_user_args().has("--capture"):
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/local-coop-shop.png"))
	coop.activate(first,7)
	assert(coop.mode=="shop")
	coop.activate(second,7)
	assert(coop.mode=="combat" and arena.spawner.wave_index==2)
	assert(first.actor.health_component.current_health>0 and first.actor.visible)
	# Production boss entry shares the encounter and completes the team run.
	await coop.wave_completed()
	arena.spawner.wave_index=19
	first.ready=false; second.ready=false
	coop.next_wave()
	assert(arena.boss_wave_active and arena.boss_encounter.active and coop.mode=="combat")
	arena._on_boss_test_defeated()
	await create_timer(1.1).timeout
	assert(coop.mode=="result" and coop.screen.visible)
	coop.stop()
	coop.open(); first=coop.join(-1); second=coop.join(3); coop.start_run()
	coop._connection_changed(3,false)
	assert(global.game_paused and second.disconnected)
	coop._connection_changed(3,true)
	assert(not second.disconnected and global.game_paused)
	global.game_paused=false
	first.actor.health_component.take_damage(100000)
	second.actor.health_component.take_damage(100000)
	assert(coop.mode=="result" and global.game_paused)
	coop.stop()
	assert(not coop.active and global.coop_players.is_empty() and global.player==null)
	assert(arena.start_panel.visible)
	arena.queue_free()
	await process_frame
	await process_frame
	print("PASS local co-op: unique devices, isolated builds, inputs, currency/XP, targeting/spawn safety, down/revive, own upgrades/shop, ready barrier, disconnect and team defeat")
	quit()
