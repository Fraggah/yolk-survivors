extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var global = root.get_node("Global")
	global.main_player_selected = load("res://resources/units/players/player_glass_egg.tres")
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
	assert(shop.items_container.get_children().any(func(card): return card.shop_item.get("effect_key") == "golden_yolk"))
	global.coins = 1000
	assert(shop.try_reroll())
	assert(shop.items_container.get_children().any(func(card): return card.shop_item.get("effect_key") == "golden_yolk"))
	var player = global.player
	player.passive_items.golden_yolks = 3
	var owned = shop.weapon_container.get_child(0)
	var original = owned.item
	assert(shop.apply_golden_yolk(owned, 0.99))
	var reveal = shop.golden_animation
	reveal.set_process(false)
	assert(reveal.visible and player.passive_items.golden_yolks == 2)
	assert(root.get_node("MenuInput")._visible_menu() == reveal)
	assert(not reveal.is_in_group("coin_balance_reveal"))
	assert(owned.item.golden_perfect)
	reveal._process(0.6)
	assert(reveal.coin.position.x < reveal.yolk.position.x)
	assert(reveal.coin.scale.x < reveal.coin.scale.y)
	var apart = reveal.yolk.position.x - reveal.coin.position.x
	reveal._process(0.48)
	assert(reveal.coin.scale.x > reveal.coin.scale.y)
	assert(reveal.yolk.position.x - reveal.coin.position.x < apart)
	reveal._process(0.06)
	assert(reveal.flash.visible and not reveal.coin.visible)
	if OS.get_cmdline_user_args().has("--capture"):
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/golden-yolk-impact.png"))
	reveal._process(0.4)
	assert(not reveal.flash.visible and reveal.revealed)
	assert(reveal.coin.material != null and reveal.result_label.text == "+100%")
	assert(reveal.card_style.bg_color == Color("504025"))
	assert(reveal.particles.any(func(p): return not p.spark))
	assert(is_instance_valid(reveal.perfect_glints))
	if OS.get_cmdline_user_args().has("--capture"):
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/golden-yolk-success.png"))
	root.get_node("MenuInput").gamepad_active = true
	reveal._process(1.3)
	assert(reveal.continue_button.has_focus())
	reveal.continue_button.pressed.emit()
	assert(not reveal.visible)
	assert(shop.apply_golden_yolk(owned, 0.0))
	assert(player.passive_items.golden_yolks == 1)
	reveal.set_process(false)
	reveal._process(1.6)
	assert(reveal.result_label.text == "ITEM BROKEN" and not reveal.coin.visible)
	assert(not reveal.flash.visible and reveal.card_style.bg_color == Color("512a2b"))
	assert(player.current_weapons.is_empty())
	if OS.get_cmdline_user_args().has("--capture"):
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/golden-yolk-broken.png"))
	print("PASS golden yolk reveal: guaranteed Glass Egg offers, actual enhancement/break, anticipation, stretch, white impact, shader, perfect effect and controller dismissal")
	arena.queue_free()
	await process_frame
	quit()
