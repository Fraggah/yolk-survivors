extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	var global = root.get_node("Global")
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	assert(is_instance_valid(arena.pause_panel), "Main scene must load PausePanel")
	var selection = arena.selection_panel
	assert(selection.player_list.size() == 10)
	assert(selection.players_container.get_child_count() == 10)
	assert(global.available_players.size() == 10)
	selection.show()
	await process_frame
	for card in selection.players_container.get_children():
		assert(selection.get_global_rect().encloses(card.get_global_rect()), "Character card outside screen")
	var fields = ["health", "damage", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting"]
	for index in selection.player_list.size():
		var base = selection.player_list[index]
		var original: Dictionary = {}
		for field in fields:
			original[field] = base.get(field)
		selection.players_container.get_child(index).pressed.emit()
		assert(global.main_player_selected == base)
		assert(selection.player_name.text == base.name)
		await process_frame
		assert(selection.player_description.get_content_height() <= selection.player_description.size.y, "Stats clipped: " + base.name)
		assert(selection.player_description.text.contains("Harvesting:"))
		assert(selection.player_description.text.contains("Life steal:"))
		global.main_weapon_selected = load("res://resources/items/weapons/melee/spatula/item_spatula_1.tres")
		selection.hide()
		arena._on_level_selected(0)
		var player = global.player
		assert(player != null and player.stats != base, "Run needs its own stats copy")
		assert(player.sprite.texture == base.icon, "In-game sprite must match selected portrait")
		assert(player.sprite.texture.get_size() == Vector2(176, 176))
		assert(arena.wave_active and not global.game_paused)
		assert(not arena.coocking_player.stream_paused)
		assert(not arena.spawner.wave_timer.is_stopped())
		if index == 0:
			await press_escape()
			assert(global.game_paused and arena.pause_panel.visible)
			assert(arena.spawner.wave_timer.paused and arena.spawner.spawn_timer.paused)
			assert(arena.coocking_player.stream_paused and arena.music_player.stream_paused)
			await press_escape()
			assert(not global.game_paused and not arena.pause_panel.visible)
			assert(not arena.spawner.wave_timer.paused and not arena.spawner.spawn_timer.paused)
			assert(not arena.coocking_player.stream_paused)
			arena.spawner.wave_timer.stop()
			arena.spawner.spawn_timer.stop()
			arena._on_spawner_on_wave_completed()
			await press_escape()
			assert(global.game_paused and arena.coocking_player.stream_paused)
			await create_timer(1.1).timeout
			assert(arena.upgrade_panel.visible)
			await press_escape()
			assert(global.game_paused and arena.upgrade_panel.visible and not arena.pause_panel.visible)
			assert(arena.coocking_player.stream_paused)
			arena._on_upgrade_selected()
			await press_escape()
			assert(global.game_paused and arena.shop_panel.visible and not arena.pause_panel.visible)
			assert(arena.coocking_player.stream_paused)
			arena._on_shop_panel_on_shop_next_wave()
			assert(arena.wave_active and not global.game_paused and not arena.coocking_player.stream_paused)
		assert(player.health_component.current_health == base.health)
		for field in fields:
			assert(player.stats.get(field) == original[field], "Wrong starting stat: " + field)
		if base.name == "Tiny Egg":
			assert(player.get_node("HurtboxComponent/CollisionShape2D").shape.radius == 25.0)
		# Real attack behavior uses the character's additive damage.
		var weapon = player.current_weapons[0]
		weapon.data = weapon.data.duplicate() # Isolate test changes from the weapon resource.
		weapon.data.stats = weapon.data.stats.duplicate()
		weapon.data.stats.crit_chance = 0.0
		var behavior = weapon.get_node("WeaponBehaviour")
		assert(behavior.get_damage() == weapon.data.get_effective_damage(base))
		if base.name == "Vampire":
			seed(123)
			player.health_component.current_health -= 10
			var before_steal = player.health_component.current_health
			for attack in 100:
				behavior.apply_life_steal()
			assert(player.health_component.current_health > before_steal, "Existing life steal must heal Vampire")
		player.health_component.current_health -= 5
		var before_regen = player.health_component.current_health
		player._on_hp_timer_timeout()
		assert(player.health_component.current_health == before_regen + base.hp_regen)
		global.game_paused = true
		var paused_health = player.health_component.current_health
		player._on_hp_timer_timeout()
		assert(player.health_component.current_health == paused_health)
		var coins_before = global.coins
		global.get_harvesting_coins()
		assert(global.coins == coins_before + int(base.harvesting))
		# Even a stray growth value must not affect the player's maximum HP.
		player.stats.health_increase_per_wave = 999.0
		player.prepare_for_new_wave()
		assert(player.stats.health == base.health)
		assert(player.health_component.max_health == base.health)
		assert(player.health_component.current_health == base.health)
		assert(not selection.player_description.text.contains("HP / wave:"))
		# Simulate upgrades, then exit and reselect: every base stat must be restored.
		for field in fields:
			player.stats.set(field, player.stats.get(field) + 7)
		arena._on_pause_panel_on_exit_pressed()
		await process_frame
		for field in fields:
			assert(base.get(field) == original[field], "Run changed roster resource: " + field)
		global.main_player_selected = base
		var fresh = global.get_selected_player()
		for field in fields:
			assert(fresh.stats.get(field) == original[field], "Retry retained upgrades: " + field)
		fresh.free()
		global.player = null
		selection.show()
		print("PASS character: ", base.name)
	arena.spawner.wave_timer.stop()
	arena.spawner.spawn_timer.stop()
	# Real death path must likewise leave the permanent starting values intact.
	var vampire = selection.player_list[4]
	global.main_player_selected = vampire
	var dying = global.get_selected_player()
	arena.add_child(dying)
	global.game_paused = false
	dying.stats.life_steal = 99
	dying.health_component.take_damage(10000)
	await process_frame
	assert(arena.spawner.wave_timer.is_stopped() and arena.spawner.spawn_timer.is_stopped())
	assert(vampire.life_steal == 12)
	assert(vampire.health == 18)
	global.player = null
	# Let the existing control-hint and floating-text animations finish before teardown.
	await create_timer(6.5).timeout
	arena.queue_free()
	await process_frame
	print("PASS: Escape pauses/resumes waves, ignores upgrades/shop and wave-end transition; 10 selectable characters, portraits, base stats, regen pause, harvesting, fixed max HP between waves, exit/retry and death isolation")
	call_deferred("quit")

func press_escape() -> void:
	var event := InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.physical_keycode = KEY_ESCAPE
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	await process_frame
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame
