extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	load("res://tests/progression_fixture.gd").prepare(root)
	var global = root.get_node("Global")
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	global.main_player_selected = load("res://resources/units/players/player_well_rounded.tres")
	var player = global.get_selected_player()
	arena.add_child(player)
	player.set_process(false)
	player.stats.apply_stat_change("hp_regen", 2)
	arena.run_experience.add_experience(41)
	assert(arena.run_experience.level == 3 and player.stats.hp_regen == 2)
	var egg = load("res://resources/items/passives/catalogue/item_074.tres")
	egg.apply_passive_values()
	assert(player.stats.hp_regen == 2, "Buying the item does not count previous or pending levels")
	arena.run_experience.add_experience(36)
	assert(arena.run_experience.level == 4 and player.stats.hp_regen == 3)
	egg.apply_passive_values()
	assert(player.stats.hp_regen == 3, "A later copy does not retroactively duplicate earlier gains")
	arena.run_experience.add_experience(49)
	assert(arena.run_experience.level == 5 and player.stats.hp_regen == 5)
	arena.run_experience.add_experience(145)
	assert(arena.run_experience.level == 7 and player.stats.hp_regen == 9, "Every level in a multi-level award counts once")
	player.prepare_for_new_wave()
	assert(player.stats.hp_regen == 9, "Earned regeneration persists across waves")
	assert(egg.regen_per_level == 1.0)
	global.player = null
	arena.queue_free()
	await process_frame
	await process_frame
	print("PASS aged egg: subsequent levels only, later copies, multi-level awards and permanent run gains")
	quit()
