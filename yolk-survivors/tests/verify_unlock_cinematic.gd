extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	var progress = load("res://tests/progression_fixture.gd").prepare(root,false)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var global = root.get_node("Global")
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = arena.weapon_selection_panel.weapons_list[0]
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	progress.set_meta("suppress_unlock_presentation",false)
	var notice = arena.get_node("UnlockPresentation")
	global.player.stats.apply_stat_change("speed",60)
	await process_frame
	notice._process(0)
	assert(notice.active and arena.unlock_modal_active and global.game_paused)
	assert(notice.icon.texture != null and notice.icon.material != null)
	var remaining: float = arena.spawner.wave_timer.time_left
	await create_timer(0.1,true,false,true).timeout
	assert(arena.spawner.wave_timer.time_left == remaining)
	notice._process(1.3)
	assert(notice.revealed and notice.icon.material == null)
	assert(notice.name_label.text == "Tiny Egg" and notice.requirement_label.text.contains("350"))
	notice._process(1.8)
	assert(notice.continue_button.visible and notice.details_panel.visible)
	notice._continue()
	assert(not global.game_paused and not arena.unlock_modal_active)
	arena.set_wave_paused(true)
	notice._on_unlock_earned("Vampire + Bloody")
	assert(notice.pending.size() == 2)
	notice._process(0)
	notice._process(3.2)
	assert(notice.name_label.text == "Vampire")
	notice._continue()
	notice._process(3.2)
	assert(notice.current.resource.has_method("get_effective_damage"))
	assert(notice.current.resource.unlock_id == "bloody")
	notice._continue()
	assert(global.game_paused and arena.pause_panel.visible)
	assert(notice.pending.is_empty() and not notice.active)
	assert(root.get_node("MenuInput").menus[0] == notice.screen)
	print("PASS real unlock silhouette/reveal/details, timer freeze, queued character+weapon and pause restoration")
	quit()



