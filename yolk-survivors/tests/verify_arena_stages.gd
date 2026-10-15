extends SceneTree

func _initialize() -> void: call_deferred("verify")

func verify() -> void:
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var controller = arena.environment_controller
	assert(controller.stages.size() == 6)
	assert(controller.debug_stage_selector != null)
	assert(controller.debug_stage_selector.get_global_rect().position.y >= 0)
	controller._on_debug_stage_selected(3)
	for wave in [1, 2, 20]: assert(str(controller.prepare_wave(wave).id) == "cooking_pot")
	controller.reset_stage_selection()
	assert(str(controller.prepare_wave(1).id) == "cooking_pot")
	controller._on_debug_stage_selected(0)
	controller.reset_stage_selection()
	var ids: Array = []
	var area_signatures: Array = []
	var background_materials: Array = []
	for stage in controller.stages:
		assert(stage.is_valid() and not ids.has(stage.id))
		ids.append(stage.id)
		assert(stage.vessel.get_width() > 0 and stage.vessel.get_height() > 0)
		assert(stage.background_material != null and not background_materials.has(stage.background_material))
		background_materials.append(stage.background_material)
		var a: Color = stage.background_material.get_shader_parameter("color_a")
		var b: Color = stage.background_material.get_shader_parameter("color_b")
		assert(a != b and Vector3(a.r - b.r, a.g - b.g, a.b - b.b).length() < 0.12)
		var geometry = stage.play_area
		var signature := str(geometry.movement_bounds) + str(geometry.oval) + str(geometry.corner_radius)
		assert(not area_signatures.has(signature), "Each utensil has a unique play area")
		area_signatures.append(signature)
		for sample in 200:
			var point: Vector2 = geometry.random_spawn_position()
			assert(geometry.clamp_position(point).is_equal_approx(point))
			var outside: Vector2 = geometry.movement_bounds.end + Vector2(400, 300)
			var clamped: Vector2 = geometry.clamp_position(outside)
			assert(not clamped.is_equal_approx(outside) and geometry.clamp_position(clamped).is_equal_approx(clamped))
	for wave in range(1, 21):
		var selected = controller.prepare_wave(wave)
		assert(controller.prepare_wave(wave) == selected)
		var geometry = controller.apply_wave(wave)
		assert(geometry == selected.play_area, "Selected utensil determines movement/spawn geometry")
		assert(controller.current_stage == selected and controller.vessel.texture == selected.vessel)
		assert(controller.flat_background.color == selected.background_color and not controller.background.visible)
		assert(controller.flat_background.material == selected.background_material)
		assert(controller.flat_background.get_parent() == controller)
		assert(controller.flat_background.position == geometry.background_offset - geometry.background_size * 0.5)
		assert(controller.flat_background.size == geometry.background_size)
		var previous_phase: float = controller.background_phase
		controller._process(0.1)
		assert(controller.background_phase > previous_phase and is_equal_approx(selected.background_material.get_shader_parameter("phase"), controller.background_phase))
	assert(controller.find_children("*", "CollisionObject2D", true, false).is_empty(), "Stage presentation cannot introduce collisions")
	# Exercise independent draws, including adjacent repetitions, with a deterministic seed.
	controller.stage_random.seed = 2817
	controller.reset_stage_selection()
	var seen: Array = []
	var repeats := 0
	var previous = null
	for wave in range(1, 151):
		var selected = controller.prepare_wave(wave)
		if selected == previous: repeats += 1
		if not seen.has(selected.id): seen.append(selected.id)
		previous = selected
	assert(seen.size() == 6 and repeats > 0)
	controller.reset_stage_selection()
	assert(controller.prepare_wave(1, controller.stages[3]) == controller.stages[3])
	assert(controller.prepare_wave(1, controller.stages[0]) == controller.stages[3], "A prepared draw stays immutable")
	var global = root.get_node("Global")
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = arena.weapon_selection_panel.weapons_list[0]
	arena.start_panel.hide()
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	assert(controller.selected_stages.size() == 1, "A fresh run clears previous draws")
	await process_frame
	var player = global.player
	for stage in controller.stages:
		controller.selected_stages[2] = stage
		arena._apply_wave_environment(2)
		assert(player.arena_environment == stage.play_area and arena.spawner.arena_environment == stage.play_area)
		player.global_position = stage.play_area.movement_bounds.end + Vector2(500, 500)
		player._process(0.0)
		assert(stage.play_area.clamp_position(player.global_position).is_equal_approx(player.global_position))
		var profile = load("res://resources/wave/enemies/chaser_mid.tres")
		var enemy = profile.scene.instantiate()
		arena.spawner.prepare_enemy(enemy, profile)
		arena.add_child(enemy)
		enemy.global_position = stage.play_area.movement_bounds.position - Vector2(400, 300)
		enemy._process(0.0)
		assert(enemy.arena_environment == stage.play_area)
		assert(stage.play_area.clamp_position(enemy.global_position).is_equal_approx(enemy.global_position))
		enemy.queue_free()
		for sample in 20:
			var spawn: Vector2 = arena.spawner.get_safe_spawn_position(profile)
			assert(spawn.is_finite() and arena.spawner.is_spawn_position_safe(spawn, profile))
	controller.selected_stages.erase(2)
	global.game_paused = true
	arena.show_upgrades()
	var selected = controller.prepare_wave(2)
	assert(arena.shop_panel.next_stage == selected and arena.shop_panel.next_stage_wave == 2)
	assert(arena.shop_panel.next_stage_panel.visible)
	assert(arena.shop_panel.next_stage_label.text.contains(selected.display_name))
	global.coins = 500
	arena.shop_panel.try_reroll()
	var weapon_offers = arena.shop_panel.items_container.get_children().filter(func(card): return card.shop_item.has_method("get_effective_damage"))
	assert(not weapon_offers.is_empty())
	assert(arena.shop_panel.try_purchase_item(weapon_offers[0].shop_item))
	var owned = arena.shop_panel.weapon_container.get_children().back()
	arena.shop_panel._on_item_card_selected(owned)
	arena.shop_panel._on_sell_weapon_button_pressed()
	arena.shop_panel.hide()
	arena.shop_panel.show()
	assert(controller.prepare_wave(2) == selected and arena.shop_panel.next_stage == selected)
	arena._on_shop_panel_on_shop_next_wave()
	arena.spawner.spawn_timer.stop()
	assert(controller.current_stage == selected, "Shop preview and next combat must use the same draw")
	arena.spawner.wave_timer.stop()
	arena.spawner.clear_enemies()
	global.game_paused = true
	global.player = null
	arena.queue_free()
	await process_frame
	print("PASS: six unique utensil play areas, player/enemy clamping, safe spawn sampling, random repeats, stable shop/next-wave geometry and consistent stage geometry")
	quit()
