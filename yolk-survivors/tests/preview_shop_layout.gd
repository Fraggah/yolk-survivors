extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var global = root.get_node("Global")
	global.main_player_selected = load("res://resources/units/players/player_gambler.tres")
	global.main_weapon_selected = arena.weapon_selection_panel.weapons_list[0]
	arena._on_level_selected(0)
	arena.start_panel.hide()
	arena.selection_panel.hide()
	arena.weapon_selection_panel.hide()
	arena.spawner.spawn_timer.stop()
	var shop = arena.shop_panel
	shop.load_shop(1)
	shop.set_next_stage(arena.environment_controller.prepare_wave(2), 2)
	shop.show()
	assert(shop.gamble_button.visible and shop.gamble_button.text.is_empty())
	assert(shop.gamble_button.get_node("CoinIcon").material != null)
	assert(shop.gamble_button.get_parent() == shop.get_node("MarginContainer/Control"))
	assert(not shop.next_stage_panel.visible)
	shop.set_next_stage(load("res://resources/environments/stages/nonstick_pan.tres"), 2)
	assert(shop.next_stage_panel.visible and shop.next_stage_icon.visible)
	await process_frame
	await process_frame
	assert(shop.weapon_container.columns == 3)
	shop._position_refresh_buttons()
	var group_center = (shop.reroll_button.global_position.x + shop.gamble_button.get_global_rect().end.x) * 0.5
	assert(is_equal_approx(group_center, shop.get_node("MarginContainer/Control/StatsContainer").get_global_rect().get_center().x))
	assert(not shop.golden_control.visible and not shop.breading_control.visible)
	assert(is_equal_approx(shop.items_container.global_position.y, shop.get_node("MarginContainer/Control/StatsContainer").global_position.y))
	shop._on_item_purchased(load("res://resources/items/passives/catalogue/item_062.tres"))
	await process_frame
	var passive = shop.passive_container.get_child(0)
	root.get_node("MenuInput").gamepad_active = true
	passive.focus_mode = Control.FOCUS_ALL
	passive.grab_focus()
	shop._on_item_card_hovered(passive)
	await process_frame
	assert(passive.tooltip_text.is_empty())
	assert(shop.weapon_tooltip.visible and shop.weapon_tooltip.passive_description.visible)
	assert(not shop.weapon_tooltip.stats_grid.visible)
	var stats = shop.get_node("MarginContainer/Control/StatsContainer")
	var target = stats.stat_rows["effects"].get_node("StatHelpTarget")
	target.focus_mode = Control.FOCUS_ALL
	target.grab_focus()
	await process_frame
	assert(stats.stat_help.visible and stats.stat_help_title.text == "Effects")
	stats.show_secondary(true)
	assert(not stats.stat_help.visible)
	target = stats.stat_rows["dash_cooldown"].get_node("StatHelpTarget")
	target.focus_mode = Control.FOCUS_ALL
	target.grab_focus()
	await process_frame
	assert(stats.stat_help.visible and stats.stat_help_title.text == "Dash cooldown")
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/shop-layout.png"))
	print("PASS shop layout")
	quit()
