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
	var vitamin = load("res://resources/items/passives/catalogue/item_046.tres")
	vitamin.apply_passive_values()
	vitamin.apply_passive_values()
	assert(is_equal_approx(player.passive_items.yolk_heal_chance, 0.1))
	assert(player.passive_items.yolk_heal_amount == 0.1)
	assert(vitamin.proc_chance == 0.05)
	player.passive_items.yolk_heal_chance = 1.0
	player.health_component.current_health = 10.0
	global.coins = 0
	global.yolk_reserve = 3
	var pickup = load("res://scenes/coins/coins.tscn").instantiate()
	root.add_child(pickup)
	pickup.set_process(false)
	pickup.value = 4
	pickup.add_coins()
	assert(global.coins == 7 and global.yolk_reserve == 0)
	assert(is_equal_approx(player.health_component.current_health, 10.7), "All seven obtained yolks get a roll")
	pickup.add_coins()
	assert(is_equal_approx(player.health_component.current_health, 10.7), "A pickup can only pay and heal once")
	player.health_component.current_health = player.health_component.max_health - 0.05
	player.passive_items.on_yolks_collected(10)
	assert(player.health_component.current_health == player.health_component.max_health)
	player.health_component.current_health = 10.0
	player.passive_items.yolk_heal_chance = 0.0
	player.passive_items.on_yolks_collected(10)
	assert(player.health_component.current_health == 10.0)
	player.passive_items.yolk_heal_chance = 1.0
	var banked = load("res://scenes/coins/coins.tscn").instantiate()
	root.add_child(banked)
	banked.set_process(false)
	banked.flying_to_jar = true
	banked.add_coins()
	assert(player.health_component.current_health == 10.0 and global.coins == 7, "Banking uncollected yolks does not trigger collection effects")
	global.game_paused = true
	player.passive_items.on_yolks_collected(10)
	assert(player.health_component.current_health == 10.0)
	global.game_paused = false
	global.player = null
	player.queue_free()
	banked.queue_free()
	await process_frame
	await process_frame
	print("PASS Complejo B: additive chance, per-yolk healing, reserve bonus, cap, duplicate guard and no bank/pause triggers")
	quit()
