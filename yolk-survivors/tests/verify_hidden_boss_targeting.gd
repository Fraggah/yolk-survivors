extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	await process_frame
	var global = root.get_node("Global")
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = load("res://resources/items/weapons/range/kitchen_torch/item_kitchen_torch_1.tres")
	arena._on_boss_test_selected()
	var encounter = arena.boss_encounter
	encounter.set_process(false)
	var boss = encounter.boss
	var player = global.player
	player.set_process(false)
	player.global_position = boss.anchor + Vector2(70,0)
	var weapon = player.current_weapons[0]
	weapon.set_process(false)
	weapon.cooldown_timer.stop()
	var crowd = root.get_node("EnemyCrowd")
	await create_timer(0.1).timeout
	assert(crowd.nearest(boss.anchor,200) == null, "Grid lookup rejects absent boss")
	assert(crowd.nearest(boss.anchor,2000) == null, "Long-range lookup rejects absent boss")
	weapon.targets.clear()
	weapon.spatial_target = boss
	weapon.spatial_target_deadline = crowd.clock+100
	assert(weapon.get_closest_target() == null, "Cached targets must respect targetable")
	boss.health_component.open_window(0)
	boss.set_present(true)
	await create_timer(0.1).timeout
	assert(crowd.nearest(boss.anchor,200) == boss)
	weapon.targets.clear()
	weapon.spatial_target_deadline = 0
	assert(weapon.get_closest_target() == boss)
	weapon.closest_target = boss
	var stream = weapon.weapon_behaviour
	stream.update_stream(0.01,true)
	assert(stream.stream_active)
	boss.set_present(false)
	# A continuous attack also guards against the old cached reference.
	stream.update_stream(0.01,true)
	assert(not stream.stream_active and not stream.line.visible)
	weapon.targets.clear()
	weapon.spatial_target = boss
	weapon.spatial_target_deadline = crowd.clock+100
	assert(weapon.get_closest_target() == null)
	var enemy = load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	arena.add_child(enemy)
	enemy.global_position = boss.anchor+Vector2(20,0)
	enemy.set_process(false)
	await create_timer(0.1).timeout
	assert(crowd.nearest(boss.anchor,200) == enemy, "Normal visible enemies still acquired")
	arena.clear_arena()
	enemy.queue_free()
	await process_frame
	arena.queue_free()
	await process_frame
	print("PASS hidden boss targeting: grid/long range/cache exclusion, visible acquisition, instant stream stop and normal enemy targeting")
	quit()
