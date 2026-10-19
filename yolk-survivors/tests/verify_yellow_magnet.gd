extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	load("res://tests/progression_fixture.gd").prepare(root)
	var global = root.get_node("Global")
	global.main_player_selected = load("res://resources/units/players/player_well_rounded.tres")
	var player = global.get_selected_player()
	root.add_child(player)
	player.set_process(false)
	var item = load("res://resources/items/passives/catalogue/item_047.tres")
	item.apply_passive_values()
	item.apply_passive_values()
	assert(is_equal_approx(player.passive_items.yolk_magnet_chance, 0.1))
	assert(item.proc_chance == 0.05)
	var coin_scene = load("res://scenes/coins/coins.tscn")
	player.passive_items.yolk_magnet_chance = 1.0
	var attracted = coin_scene.instantiate()
	attracted.position = player.position + Vector2(10000, 0)
	root.add_child(attracted)
	attracted.set_process(false)
	assert(attracted.collected and attracted.spawn_attraction_checked)
	var before: float = attracted.global_position.distance_to(player.global_position)
	attracted._process(0.01)
	assert(attracted.global_position.distance_to(player.global_position) < before)
	player.passive_items.yolk_magnet_chance = 0.0
	var failed = coin_scene.instantiate()
	failed.position = player.position + Vector2(10000, 0)
	root.add_child(failed)
	failed.set_process(false)
	assert(not failed.collected and failed.spawn_attraction_checked)
	player.passive_items.yolk_magnet_chance = 1.0
	failed._try_spawn_attraction()
	for frame in 5: failed._process(0.01)
	assert(not failed.collected, "No repeated rolls or retroactive attraction")
	global.game_paused = true
	before = attracted.global_position.distance_to(player.global_position)
	attracted._process(1.0)
	assert(attracted.global_position.distance_to(player.global_position) == before)
	global.game_paused = false
	global.coins = 0
	global.yolk_reserve = 0
	attracted.value = 3
	attracted.add_coins()
	attracted.add_coins()
	assert(global.coins == 3, "Normal collection pays exactly once")
	global.player = null
	player.queue_free()
	failed.queue_free()
	await process_frame
	await process_frame
	print("PASS yellow magnet: additive chance, unlimited attraction, single spawn roll, pause and one-time payout")
	quit()
