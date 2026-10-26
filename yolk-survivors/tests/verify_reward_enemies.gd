extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=arena.weapon_selection_panel.weapons_list[0]
	arena.start_panel.hide()
	arena.selection_panel.hide()
	arena.weapon_selection_panel.hide()
	arena._on_level_selected(0)
	var player=global.player
	player.set_process(false)
	player.set_physics_process(false)
	player.health_component.debug_invulnerable=true
	for weapon in player.current_weapons:
		weapon.set_process(false)
		weapon.cooldown_timer.stop()
	var spawner=arena.spawner
	spawner.spawn_timer.stop()
	var a=load("res://resources/wave/enemies/yolker.tres")
	var b=load("res://resources/wave/enemies/incognito.tres")
	spawner.spawn_profile(a)
	spawner.spawn_profile(b)
	assert(spawner.pending_population[3]==2)
	assert(spawner.pending_population[1]==0 and spawner.fueguito==null)
	await create_timer(1.15).timeout
	assert(spawner.reward_enemies.size()==2)
	var yolker=spawner.reward_enemies.filter(func(enemy): return not enemy.get_meta("incognito_reward"))[0]
	var incognito=spawner.reward_enemies.filter(func(enemy): return enemy.get_meta("incognito_reward"))[0]
	for enemy in spawner.reward_enemies: enemy.set_process(false)
	assert(yolker.stats.health==60 and yolker.stats.coin_drop==10)
	assert(incognito.stats.health==48)
	assert(incognito.stats.coin_drop==0)
	if OS.get_cmdline_user_args().has("--capture"):
		var display_center=spawner.arena_environment.movement_bounds.get_center()
		player.global_position=display_center
		yolker.global_position=display_center+Vector2(-180,0)
		incognito.global_position=display_center+Vector2(180,0)
		incognito._animate(incognito.bounce_period*0.25)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/reward-enemies-preview.png"))
	var bounds=spawner.arena_environment.movement_bounds
	var center=bounds.get_center()
	yolker.global_position=center
	yolker.travel_direction=Vector2.RIGHT
	player.global_position=center+Vector2(300,0)
	yolker._process(0.1)
	assert((yolker.global_position-center).is_equal_approx(Vector2(17.5,0)))
	player.global_position=center-Vector2(300,0)
	var previous=yolker.global_position
	yolker._process(0.1)
	assert((yolker.global_position-previous).is_equal_approx(Vector2(17.5,0)),"No steering toward the player")
	yolker.global_position=Vector2(bounds.end.x-24,center.y)
	yolker._process(0.1)
	assert(yolker.travel_direction.x<0,"Wall contact chooses a new inward heading")
	assert(spawner.arena_environment.clamp_position(yolker.global_position).is_equal_approx(yolker.global_position))
	for stage in arena.environment_controller.stages:
		yolker.arena_environment=stage.play_area
		var area_bounds=stage.play_area.movement_bounds
		yolker.global_position=Vector2(area_bounds.end.x-24,area_bounds.get_center().y)
		yolker.travel_direction=Vector2.RIGHT
		yolker._process(0.1)
		assert(yolker.travel_direction.x<0,"Inward turns also work in oval/rounded arenas")
		assert(stage.play_area.clamp_position(yolker.global_position).is_equal_approx(yolker.global_position))
	yolker.arena_environment=spawner.arena_environment
	var pin=Node.new()
	arena.add_child(pin)
	yolker.pin_for(pin)
	previous=yolker.global_position
	yolker._process(0.2)
	assert(yolker.global_position==previous)
	yolker.release_pin(pin)
	incognito.animation_clock=0
	incognito._animate(0)
	assert(is_equal_approx(fposmod(incognito.sprite.rotation,TAU),PI))
	var contact=incognito.sprite.position.y
	incognito._animate(incognito.bounce_period*0.25)
	assert(incognito.sprite.position.y<contact)
	incognito._animate(incognito.bounce_period*0.25)
	assert(is_zero_approx(fposmod(incognito.sprite.rotation,TAU)))
	assert(incognito.visuals.scale.x>0,"The question mark is never mirrored")
	global.game_paused=true
	var clock=incognito.animation_clock
	previous=incognito.global_position
	incognito._process(1)
	assert(incognito.animation_clock==clock and incognito.global_position==previous)
	global.game_paused=false
	for draw in 200:
		var value=yolker.roll_yolk_reward()
		assert(value>=10 and value<=25)
	yolker.health_component.take_damage(100000)
	var dropped=arena.gold_list.size()
	assert(dropped>=10 and dropped<=25)
	for pickup in arena.gold_list: assert(pickup.value==1 and not pickup.awarded)
	arena._on_enemy_died(yolker)
	assert(arena.gold_list.size()==dropped,"A death cannot duplicate currency")
	incognito.health_component.take_damage(100000)
	assert(arena.incognito_rewards.pending.size()==1 and not arena.incognito_rewards.visible)
	arena._on_enemy_died(incognito)
	assert(arena.incognito_rewards.pending.size()==1,"A death cannot duplicate an item")
	var item=load("res://resources/items/passives/catalogue/item_001.tres")
	var held_before=player.passive_items.count(item.effect_key)
	arena.incognito_rewards.pending.append({"item":item,"wave":1,"sell_value":item.get_sell_price(1)})
	arena.run_experience.grant_levels(1)
	spawner.wave_timer.stop()
	spawner._on_wave_timer_timeout()
	await create_timer(1.15).timeout
	assert(arena.incognito_rewards.visible and not arena.upgrade_panel.visible and not arena.shop_panel.visible)
	arena.set_wave_paused(true)
	assert(arena.pause_panel.visible and not arena.incognito_rewards.visible)
	arena.set_wave_paused(false)
	assert(arena.incognito_rewards.visible and not arena.pause_panel.visible)
	if OS.get_cmdline_user_args().has("--capture"):
		await process_frame
		await RenderingServer.frame_post_draw
		var capture=root.get_viewport().get_texture().get_image()
		capture.save_png(ProjectSettings.globalize_path("res://../tmp/incognito-reward-preview.png"))
	var menu_input=root.get_node("MenuInput")
	menu_input.gamepad_active=true
	var controls=menu_input._controls(arena.incognito_rewards)
	assert(controls.has(arena.incognito_rewards.keep_button) and controls.has(arena.incognito_rewards.sell_button))
	arena.incognito_rewards.keep_button.grab_focus()
	assert(root.gui_get_focus_owner()==arena.incognito_rewards.keep_button)
	menu_input.gamepad_active=false
	var money=global.coins
	var value=arena.incognito_rewards.current.sell_value
	arena.incognito_rewards.sell_button.pressed.emit()
	assert(global.coins==money+value and arena.incognito_rewards.visible and not arena.upgrade_panel.visible)
	arena.incognito_rewards.keep_button.pressed.emit()
	assert(player.passive_items.count(item.effect_key)==held_before+1)
	assert(arena.incognito_rewards.pending.is_empty() and arena.upgrade_panel.visible)
	money=global.coins
	arena.incognito_rewards.sell_current()
	assert(global.coins==money,"Repeated button presses cannot duplicate a payout")
	await process_frame
	await process_frame
	# A final-wave reward is revealed before victory, not discarded.
	arena.upgrade_panel.hide()
	arena.run_experience.pending_levels.clear()
	spawner.wave_index=spawner.last_wave_number()
	arena.incognito_rewards.pending.append({"item":item,"wave":20,"sell_value":item.get_sell_price(20)})
	arena._continue_wave_rewards()
	assert(arena.incognito_rewards.visible and not arena.final_screen.visible)
	arena.incognito_rewards.sell_current()
	assert(arena.final_screen.visible and global.player==null)
	await process_frame
	await process_frame
	arena._on_final_button_pressed()
	assert(arena.incognito_rewards.pending.is_empty() and not arena.incognito_rewards.visible)
	await process_frame
	await process_frame
	# Starting a fresh run and dying discards unrevealed items.
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=arena.weapon_selection_panel.weapons_list[0]
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	arena.incognito_rewards.pending.append({"item":item,"wave":1,"sell_value":1})
	arena._on_player_died()
	assert(arena.incognito_rewards.pending.is_empty() and not arena.incognito_rewards.visible)
	await process_frame
	await process_frame
	arena.queue_free()
	await process_frame
	print("PASS reward enemies: separate population, straight travel/wall turns, control/pause, alternating egg bounces, literal 10-25 yolks, one reward per death, loot before upgrades, keep/sell and final-wave rewards")
	quit()
