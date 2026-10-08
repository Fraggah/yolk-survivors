extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func create_yolk(arena, amount: int, location: Vector2):
	var coin = load("res://scenes/coins/coins.tscn").instantiate()
	coin.value = amount
	arena.add_child(coin)
	coin.global_position = location
	coin.set_process(false)
	arena.gold_list.append(coin)
	return coin

func verify() -> void:
	var global = root.get_node("Global")
	global.game_paused = true
	global.coins = 10
	global.yolk_reserve = 0
	global.main_player_selected = load("res://resources/units/players/player_well_rounded.tres")
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	var player = global.get_selected_player()
	arena.add_child(player)
	player.set_process(false)
	player.set_physics_process(false)
	await process_frame
	await process_frame
	var hud = arena.coins_bag
	assert(is_equal_approx(hud.position.x, 40.0) and is_equal_approx(hud.position.y, arena.wave_index_label.position.y))
	assert(is_equal_approx(hud.get_node("BalanceRow/YolkIcon").global_position.x, hud.jar_icon.global_position.x))
	assert(is_equal_approx(hud.coins_label.global_position.x, hud.reserve_label.global_position.x))
	assert(hud.jar_icon.global_position.y > hud.get_node("BalanceRow/YolkIcon").global_position.y)
	var first = create_yolk(arena, 6, Vector2(650, 220))
	var second = create_yolk(arena, 4, Vector2(-450, -180))
	# Old unused bonuses expire. Only this wave's uncollected base values survive.
	global.yolk_reserve = 99
	arena._on_spawner_on_wave_completed()
	assert(global.yolk_reserve == 10 and global.coins == 10)
	await process_frame
	assert(first.flying_to_jar and second.flying_to_jar)
	# Test a moved UI target and translated/zoomed canvas while the wave is paused.
	hud.position += Vector2(30, 12)
	root.canvas_transform = Transform2D(Vector2(1.3, 0), Vector2(0, 1.3), Vector2(320, -95))
	for coin in [first, second]:
		coin._process(coin.jar_flight_duration)
		var expected = hud.jar_icon.get_global_transform_with_canvas() * (hud.jar_icon.size * 0.5)
		assert(coin.sprite.get_global_transform_with_canvas().origin.distance_to(expected) < 0.01, "Visible yolk center reaches the jar center")
		assert(coin.is_queued_for_deletion())
	assert(global.coins == 10 and global.yolk_reserve == 10, "Jar flights never grant spendable currency")
	await create_timer(1.1).timeout
	assert(arena.upgrade_panel.visible and global.coins == 10)
	root.canvas_transform = Transform2D.IDENTITY
	global.game_paused = false
	for pickup in 6:
		var coin = create_yolk(arena, 1, Vector2(500, 500))
		coin.add_coins()
		coin.add_coins()
	assert(global.coins == 22 and global.yolk_reserve == 4, "Six pickups redeem six bonuses exactly once")
	var remaining = create_yolk(arena, 3, Vector2(400, 100))
	global.game_paused = true
	arena.clear_arena(true)
	assert(global.yolk_reserve == 3, "Replace the four unused bonuses with three new base yolks")
	await process_frame
	remaining._process(remaining.jar_flight_duration)
	await process_frame
	global.game_paused = false
	var valuable = create_yolk(arena, 5, Vector2(500, 500))
	valuable.add_coins()
	assert(global.coins == 30 and global.yolk_reserve == 0, "Partial reserve adds only its remaining value")
	global.game_paused = true
	var idle = create_yolk(arena, 1, Vector2.ZERO)
	idle._process(1.0)
	assert(not idle.is_queued_for_deletion(), "Uncollected yolks at origin never pay automatically")
	player.stats.harvesting = 7
	global.yolk_reserve = 5
	global.get_harvesting_coins()
	assert(global.coins == 37 and global.yolk_reserve == 5)
	arena._on_player_died()
	assert(global.yolk_reserve == 0 and global.coins == 37, "Death discards reserve and floor drops without a payout")
	await process_frame
	assert(get_nodes_in_group("yolks").is_empty())
	global.yolk_reserve = 10
	arena._on_final_button_pressed()
	assert(global.yolk_reserve == 0, "Retry clears the reserve")
	global.player = null
	player.queue_free()
	# Allow floating x2 text to finish before teardown.
	await create_timer(1.4).timeout
	arena.queue_free()
	await process_frame
	print("PASS: aligned HUD, paused flights reach jar sprite center under translated/zoomed canvas, reserve replaces leftovers, pickup x2 and partial bonuses, no duplicate payout, harvesting and death cleanup")
	quit()



