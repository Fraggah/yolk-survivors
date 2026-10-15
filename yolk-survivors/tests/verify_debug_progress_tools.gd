extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	var progress = load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	ProjectSettings.set_setting("yolk/testing/unlock_characters_and_weapons",true)
	progress.counters["test"] = 20
	arena.start_panel._debug_progress_action(true)
	assert(progress.completed.is_empty() and progress.counters.is_empty())
	assert(root.get_node("Global").level_reached == 0)
	assert(not progress.is_character_unlocked(arena.selection_panel.player_list[1]))
	progress.load_progress()
	assert(progress.completed.is_empty() and not progress._testing_unlocks_enabled())
	arena.start_panel._debug_progress_action(false)
	for player in arena.selection_panel.player_list: assert(progress.is_character_unlocked(player))
	for weapon in arena.weapon_selection_panel.weapons_list: assert(progress.is_weapon_unlocked(weapon))
	assert(root.get_node("Global").level_reached == 5)
	progress.load_progress()
	assert(progress.completed.size() == progress.ACHIEVEMENT_IDS.size())
	assert(root.get_node("Global").level_reached == 5)
	assert(not arena.level_panel.buttons[5].get_meta("difficulty_locked"))
	progress.run_active = true
	assert(not progress.debug_reset_progress())
	progress.run_active = false
	assert(progress.debug_reset_progress())
	assert(arena.level_panel.buttons[5].get_meta("difficulty_locked"))
	print("PASS debug menu reset/unlock, persistence, legacy override, difficulty refresh and active run guard")
	quit()
