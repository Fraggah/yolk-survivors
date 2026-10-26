extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var global = root.get_node("Global")
	global.main_player_selected = load("res://resources/units/players/player_hoarder.tres")
	global.main_weapon_selected = arena.weapon_selection_panel.weapons_list[0]
	arena._on_level_selected(0)
	arena.start_panel.hide()
	arena.selection_panel.hide()
	arena.weapon_selection_panel.hide()
	arena.spawner.spawn_timer.stop()
	await process_frame
	var shop = arena.shop_panel
	shop.load_shop(1)
	shop.show()
	var offered_coins = shop.items_container.get_children().filter(func(card): return card.shop_item.get("effect_key") == "chocolate_coin")
	assert(offered_coins.size() == 1)
	global.coins = 1000
	assert(shop.try_reroll())
	assert(shop.items_container.get_children().any(func(card): return card.shop_item.get("effect_key") == "chocolate_coin"))
	var reveal = shop.coin_animation
	assert(reveal.frames.size() == 4)
	global.coins = 20
	assert(shop.resolve_chocolate_coin(1))
	assert(global.coins == 40)
	assert(reveal.displayed_balance == 20, "Balance must not spoil the outcome")
	reveal.set_process(false)
	assert(root.get_node("MenuInput")._visible_menu() == reveal)
	reveal._process(0.6)
	assert(reveal.coin.texture == reveal.frames[0] and absf(reveal.coin.scale.x - 1.0) < 0.03)
	reveal._process(0.2)
	assert(reveal.elapsed < 1.7 and not reveal.revealed)
	reveal._set_frame(4)
	assert(reveal.coin.flip_h and reveal.coin.texture == reveal.frames[1])
	reveal._process(0.97)
	assert(reveal.coin.scale.x < 0.3)
	reveal._process(0.1)
	assert(reveal.coin.texture == reveal.frames[0] and not reveal.coin.flip_h)
	reveal._process(0.16)
	assert(reveal.revealed and reveal.particles.size() == 295)
	assert(reveal.result_label.text == "X2" and reveal.coin.scale.x > 1.25)
	assert(reveal.displayed_balance == 40)
	if OS.get_cmdline_user_args().has("--capture"):
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/chocolate-coin-win.png"))
	reveal.close()
	assert(reveal.visible, "Cannot dismiss before the result settles")
	reveal._process(0.9)
	assert(reveal.continue_button.visible)
	reveal.continue_button.pressed.emit()
	assert(not reveal.visible and global.coins == 40)
	assert(not shop.resolve_chocolate_coin(0))
	assert(global.coins == 0)
	assert(reveal.displayed_balance == 40)
	reveal.set_process(false)
	reveal._process(2.1)
	assert(reveal.revealed and reveal.particles.is_empty())
	assert(reveal.result_label.text == "X0" and reveal.card_style.bg_color == Color("512a2b"))
	assert(reveal.displayed_balance == 0)
	assert(reveal.coin.texture == reveal.frames[3])
	if OS.get_cmdline_user_args().has("--capture"):
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/chocolate-coin-loss.png"))
	reveal._process(0.8)
	reveal.close()
	# The actual item purchase spends its price first and rolls once.
	global.coins = 21
	var item = load("res://resources/items/passives/catalogue/item_034.tres")
	assert(shop.try_purchase_item(item))
	assert(global.coins == 40 or global.coins == 0)
	assert(reveal.visible and reveal.balance == global.coins)
	reveal.set_process(false)
	root.get_node("MenuInput").gamepad_active = true
	reveal._process(2.9)
	assert(reveal.continue_button.has_focus())
	reveal.play(false, 0)
	assert(reveal.pending_results.size() == 1)
	reveal.continue_button.pressed.emit()
	assert(reveal.visible and not reveal.won and reveal.pending_results.is_empty())
	reveal.set_process(false)
	reveal._process(2.9)
	reveal.close()
	assert(not reveal.visible)
	print("PASS chocolate coin: actual purchase, real outcome, five sprite frames, timings, modal input, win-only particles, loss and close")
	arena.queue_free()
	await process_frame
	quit()
