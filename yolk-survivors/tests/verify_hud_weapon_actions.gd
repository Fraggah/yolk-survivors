extends SceneTree

func _initialize() -> void: call_deferred("verify")

func verify() -> void:
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	var global = root.get_node("Global")
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = arena.weapon_selection_panel.weapons_list[0]
	arena.start_panel.hide()
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	await process_frame
	var player = global.player
	var weapon = player.current_weapons[0]
	var record: Dictionary = weapon.damage_record
	var enemy = load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	arena.add_child(enemy)
	var hitbox = load("res://scenes/components/hitbox_component.gd").new()
	hitbox.weapon_damage_record = record
	enemy.stats = enemy.stats.duplicate()
	enemy.stats.block_chance = 0.0
	enemy.health_component.current_health = 7.0
	hitbox.damage = 100.0
	assert(enemy.receive_hit(hitbox), "Weapon damage uses actual health removed, excluding overkill")
	hitbox.report_damage(player, 100.0)
	assert(record.total_damage == 7.0 and record.wave_damage == 7.0)
	weapon.get_script().finish_damage_wave()
	weapon.get_script().begin_damage_wave()
	assert(record.last_wave_damage == 7.0 and record.wave_damage == 0.0)
	hitbox.report_damage(enemy, 3.0)
	assert(record.total_damage == 10.0 and record.last_wave_damage == 7.0)
	global.game_paused = true
	hitbox.report_damage(enemy, 999.0)
	assert(record.total_damage == 10.0)
	hitbox.free()
	enemy.queue_free()
	arena.run_experience.reset()
	arena.run_experience.add_experience(5)
	assert(is_equal_approx(arena.experience_bar.progress_bar.value, 5.0 / 16.0))
	arena.set_wave_paused(true)
	assert(arena.pause_panel.weapons_grid.get_child_count() == player.current_weapons.size())
	arena.pause_panel.hide()
	arena.shop_panel.show()
	var shop = arena.shop_panel
	assert(not shop.weapon_actions.visible)
	var card = shop.weapon_container.get_child(0)
	shop._on_item_card_selected(card)
	assert(shop.weapon_actions.visible and shop.combine_button.disabled)
	var menu = root.get_node("MenuInput")
	menu._set_gamepad_active(true)
	var controls = menu._controls(shop)
	assert(controls.size() == 2 and controls.all(func(control): return shop.weapon_actions.is_ancestor_of(control)))
	shop.close_weapon_actions()
	assert(not shop.weapon_actions.visible)
	menu._set_gamepad_active(false)
	shop.hide()
	global.game_paused = false
	var profile = load("res://resources/wave/enemies/chaser_mid.tres")
	for distance in [100.0, 0.0]:
		arena.spawner.spawn_profile(profile)
		var effects = get_nodes_in_group("spawn_effects")
		assert(effects.size() == 1)
		var effect = effects[0]
		var point: Vector2 = effect.global_position
		player.global_position = point + Vector2(distance, 0)
		var before: int = arena.spawner.total_spawned
		effect.complete()
		assert(arena.spawner.total_spawned == before + 1, "Relocation spawns immediately after one warning")
		var spawned = arena.spawner.spawned_enemies.back()
		assert(spawned.global_position.is_equal_approx(point) == (distance == 100.0))
		await process_frame
		assert(get_nodes_in_group("spawn_effects").is_empty())
	arena.spawner.wave_timer.stop()
	arena.spawner.clear_enemies()
	global.game_paused = true
	print("PASS: per-weapon damage/wave snapshots, XP HUD, pause equipment, action panel/controller scope, near-only immediate spawn relocation")
	quit()
