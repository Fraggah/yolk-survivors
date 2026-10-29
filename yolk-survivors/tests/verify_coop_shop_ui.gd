extends SceneTree
func _initialize(): call_deferred("verify")
func check_sound(sound,key: String,action: Callable) -> void:
	for player in sound.stream_players: player.stop()
	sound.event_times.erase(key)
	action.call()
	assert(sound.event_times.has(key),"Missing shop sound: "+key)

func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena); current_scene=arena
	await process_frame
	var sound=root.get_node("SoundManager")
	var tone=AudioStreamWAV.new()
	tone.mix_rate=22050
	tone.data=PackedByteArray(); tone.data.resize(2205)
	for key in ["shop_lock","shop_unlock","shop_buy","shop_no_money","shop_reroll","shop_sell","shop_combine"]: sound.set(key,tone)
	var coop=arena.coop
	coop.set_process(false)
	coop.open()
	for device in [-1,0,1,2]: coop.join(device)
	coop.start_run()
	await coop.wave_completed()
	await process_frame; await process_frame
	assert(coop.panels.size()==4 and coop.grids.columns==2)
	assert(not coop.title.visible and not coop.hint.visible)
	assert(coop.grids.size.y>root.get_visible_rect().size.y*.97)
	assert(not coop.content.get_node("Back").visible)
	assert(not arena.environment_controller.debug_stage_selector.visible)
	assert(coop.grids.get_global_rect().position.y<=16)
	for i in 4:
		var panel=coop.panels[i]
		assert(panel.session==coop.sessions[i])
		var weapons_panel=panel.view.get_node("Inventory/WeaponsPanel")
		assert(weapons_panel.position.x>panel.view.size.x*.5,"Weapons must be on the right")
		assert(is_equal_approx(weapons_panel.get_rect().end.x,panel.view.get_node("Cards").get_rect().end.x),"Weapons and offers must share their right margin")
		assert(panel.get_theme_stylebox("panel").bg_color==coop.COLORS[i])
		assert(panel.get_theme_stylebox("panel").border_color==coop.COLORS[i])
		assert(panel.get_node("InnerFrame/Surface").get_theme_stylebox("panel").bg_color==root.get_node("UITheme").palette.surface)
		assert(panel.get_node("TabAnchor/PlayerTab/Label").text=="P%d"%(i+1))
		assert(panel.controls.size()>=10)
		assert(panel.controls[0].get_theme_stylebox("normal").bg_color==root.get_node("UITheme").palette.hover_surface,"Initial selection must be highlighted before moving")
		assert(absf(panel.controls[0].size.y-panel.lock_buttons[0].size.y)<1)
		assert(absf(panel.controls[4].size.y-panel.lock_buttons[0].size.y)<1)
		assert(panel.offers[0].item_cost.get_index()<panel.offers[0].item_cost.get_parent().get_node("TextureRect").get_index())
		assert(panel.view.get_node("Balance").get_theme_font_size("font_size")==72)
		assert(panel.view.get_node("Yolk").size.is_equal_approx(Vector2(72,72)))
		assert(panel.offers[0].get_script()==load("res://scenes/ui/shop/shop_card.gd"))
		assert(panel.controls[9].get_script()==load("res://scenes/ui/shop/item_card.gd"))
		assert(panel.offers[0].preview_stats==coop.sessions[i].actor.stats)
		for j in 4: assert(panel.offers[j].item_name.text!="")
		var others: Array=[]
		for s in coop.sessions: others.append(s.cursor)
		panel.select(9)
		assert(panel.view.get_node("Inspect").weapon_name.text==coop.sessions[i].actor.current_weapons[0].data.item_name)
		var tooltip=panel.view.get_node("Inspect")
		assert(tooltip.get_script()==load("res://scenes/ui/shop/weapon_tooltip.gd"))
		assert(tooltip.preview_stats==coop.sessions[i].actor.stats)
		await process_frame; await process_frame
		var bounds=panel.get_global_rect().grow(1)
		var detail_rect=tooltip.get_global_rect()
		assert(bounds.encloses(detail_rect),"Tooltip must stay within its owner's quadrant")
		assert(detail_rect.end.y<=panel.controls[9].get_global_rect().position.y+1,"Tooltip should appear above its selected slot")
		if i==0 and OS.get_cmdline_user_args().has("--capture"):
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/coop-native-tooltip.png"))
		panel.select(8)
		assert(panel.stats.bound_player==coop.sessions[i].actor)
		coop.activate(coop.sessions[i],8)
		assert(panel.page=="stats")
		assert(panel.controls[8].disabled and not panel.view.get_node("ShopButton").disabled)
		assert(panel.stats.visible and panel.stats_secondary.visible)
		assert(not panel.stats.secondary_visible and panel.stats_secondary.secondary_visible)
		assert(not panel.view.get_node("Cards").visible)
		assert(not panel.view.get_node("Inventory").visible)
		if i==0 and OS.get_cmdline_user_args().has("--capture"):
			await process_frame; await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/coop-sketch-stats.png"))
		coop.activate(coop.sessions[i],300)
		assert(panel.page=="items" and panel.view.get_node("Inventory/PassivesPanel").visible)
		assert(panel.view.get_node("ItemsButton").disabled and not panel.controls[8].disabled)
		assert(not panel.view.get_node("Cards").visible and not panel.stats.visible)
		if i==0:
			var herb=null
			for item in coop._pool(coop.sessions[i]):
				if item.get("effect_key")=="oregano": herb=item; break
			assert(herb!=null)
			herb.apply_passive_values(coop.sessions[i].actor)
			herb.apply_passive_values(coop.sessions[i].actor)
			coop._render_panel(coop.sessions[i])
			assert(panel.inventory.back().count==2 and coop.sessions[i].cursor==301)
			if OS.get_cmdline_user_args().has("--capture"):
				await process_frame; await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/coop-sketch-items.png"))
		coop.activate(coop.sessions[i],301)
		assert(panel.page=="shop" and panel.view.get_node("Cards").visible)
		assert(not panel.stats.visible and not panel.view.get_node("Inventory/PassivesPanel").visible)
		assert(panel.view.get_node("ShopButton").disabled)
		assert(panel.view.get_node("Cards").size.x>=panel.view.size.x*.98)
		panel.select(0)
		panel.move_selector(Vector2.RIGHT)
		assert(coop.sessions[i].cursor==1)
		assert(panel.controls[1].get_theme_stylebox("normal").bg_color==panel.controls[1].get_theme_stylebox("hover").bg_color)
		for j in 4:
			if i!=j: assert(coop.sessions[j].cursor==others[j])
		coop.sessions[i].cursor=0
		coop.toggle_lock(coop.sessions[i])
		assert(panel.offers[0].lock_button.text=="LOCKED")
		coop.toggle_lock(coop.sessions[i])
		# The lock itself is reachable and confirmable, in addition to X/L shortcuts.
		panel.select(0); panel.move_selector(Vector2.DOWN)
		assert(coop.sessions[i].cursor==200)
		var accept=InputEventKey.new() if i==0 else InputEventJoypadButton.new()
		if i==0: accept.physical_keycode=KEY_ENTER
		else: accept.device=coop.sessions[i].device; accept.button_index=JOY_BUTTON_A
		accept.pressed=true
		check_sound(sound,"shop_lock",func(): coop._input(accept))
		assert(coop.sessions[i].locked[0])
		var shortcut=InputEventKey.new() if i==0 else InputEventJoypadButton.new()
		if i==0: shortcut.physical_keycode=KEY_L
		else: shortcut.device=coop.sessions[i].device; shortcut.button_index=JOY_BUTTON_X
		shortcut.pressed=true
		check_sound(sound,"shop_unlock",func(): coop._input(shortcut))
		assert(not coop.sessions[i].locked[0])
		var tab=panel.get_node("TabAnchor/PlayerTab")
		assert(absf(tab.get_global_rect().get_center().x-panel.get_global_rect().get_center().x)<1)
	# Mouse remains disabled throughout co-op; selector feedback uses the assigned device.
	var mouse_panel=coop.panels[0]
	var cursor_before=coop.sessions[0].cursor
	for j in 4:
		mouse_panel.lock_buttons[j].mouse_entered.emit()
		mouse_panel.lock_buttons[j].mouse_exited.emit()
		assert(coop.sessions[0].cursor==cursor_before)
	mouse_panel.select(200)
	coop.toggle_lock(coop.sessions[0],0)
	assert(mouse_panel.lock_buttons[0].button_pressed and mouse_panel.lock_buttons[0].text=="LOCKED")
	mouse_panel.select(0)
	assert(mouse_panel.lock_buttons[0].get_theme_stylebox("pressed").bg_color!=root.get_node("UITheme").palette.hover_surface)
	coop.toggle_lock(coop.sessions[0],0)
	# Detailed ranged tooltip uses the owner's stats and includes the weapon's behavior.
	var hydrant=null
	for item in arena.weapon_selection_panel.weapons_list:
		if item.item_name.to_lower().contains("hydrant"): hydrant=item; break
	assert(hydrant!=null)
	var first_session=coop.sessions[0]
	first_session.actor.add_weapon(hydrant)
	first_session.actor.stats.ranged_damage=17
	coop._render_panel(first_session)
	var first_panel=coop.panels[0]
	var hydrant_slot=0
	for k in first_panel.inventory.size():
		if first_panel.inventory[k].item==hydrant: hydrant_slot=k+9
	first_panel.select(hydrant_slot)
	var detailed=first_panel.view.get_node("Inspect")
	assert(detailed.full_description.visible and detailed.full_description.text.contains("stream"))
	assert(detailed.value_labels[0].text=="[right]%s[/right]"%root.get_node("UITheme").rich_text(hydrant.get_damage_description(first_session.actor.stats)))
	await process_frame; await process_frame
	assert(first_panel.get_global_rect().grow(1).encloses(detailed.get_global_rect()))
	first_panel.scroll_detail(100)
	await process_frame; await process_frame
	var description_scroll=detailed.full_description.get_v_scroll_bar()
	if description_scroll.max_value>description_scroll.page: assert(description_scroll.value>0)
	description_scroll.value=0
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/coop-hydrant-tooltip.png"))
	# Mouse hover updates only the keyboard player's detail and never purchases.
	var first=coop.sessions[0]
	var coins=first.coins
	var original_cursor=first.cursor
	coop.panels[0].controls[2].mouse_entered.emit()
	assert(first.cursor==original_cursor and first.coins==coins)
	var previous_coins=first.coins
	first.coins=0
	check_sound(sound,"shop_no_money",func(): coop.activate(first,0))
	first.coins=1000
	var retained=first.offers.duplicate()
	coop.toggle_lock(first,1)
	check_sound(sound,"shop_buy",func(): coop.activate(first,0))
	assert(first.offers.size()==4 and first.offers.all(func(item): return item!=null))
	assert(first.offers[0].get_offer_key()!=retained[0].get_offer_key())
	for j in [1,2,3]: assert(first.offers[j]==retained[j])
	assert(first.locked[1])
	var weapon_count:=0
	for item in first.offers:
		if is_instance_of(item,load("res://resources/items/weapons/item_weapon.gd")): weapon_count+=1
	assert(weapon_count<=2)
	coop.toggle_lock(first,1)
	check_sound(sound,"shop_reroll",func(): coop.activate(first,4))
	first.coins=previous_coins
	var other_cursor=coop.sessions[1].cursor
	coop.panels[1].controls[2].mouse_entered.emit()
	assert(coop.sessions[1].cursor==other_cursor)
	if OS.get_cmdline_user_args().has("--capture"):
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/coop-shop-four.png"))
	# Weapon actions require a chosen slot; selling/combining must target it, never the last weapon.
	var context_session=coop.sessions[0]
	var actor=context_session.actor
	var panel=coop.panels[0]
	assert(not panel.view.has_node("Reserve") and not panel.content.has_node("Header"))
	assert(not panel.view.get_node("WeaponActions").visible)
	var original=actor.current_weapons[0]
	var different=null
	for item in coop._pool(context_session):
		if is_instance_of(item,load("res://resources/items/weapons/item_weapon.gd")) and item.get_offer_key()!=original.data.get_offer_key(): different=item; break
	assert(different!=null)
	actor.add_weapon(different)
	coop._render_panel(context_session)
	var last=actor.current_weapons.back()
	assert(load("res://assets/sprites/Yolk/yolk.png").get_image().has_mipmaps())
	var count_before=actor.current_weapons.size()
	coop.activate(context_session,6)
	assert(actor.current_weapons.size()==count_before)
	var sale_price=original.data.get_sell_price(arena.spawner.wave_index)
	var own_coins=context_session.coins
	var partner_coins=coop.sessions[1].coins
	panel.select(9); coop.activate(context_session,9)
	assert(panel.context_target()==original and panel.view.get_node("WeaponActions").visible)
	if OS.get_cmdline_user_args().has("--capture"):
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/coop-weapon-context.png"))
	check_sound(sound,"shop_sell",func(): coop.activate(context_session,6))
	assert(not actor.current_weapons.has(original) and actor.current_weapons.has(last))
	assert(context_session.coins==own_coins+sale_price and coop.sessions[1].coins==partner_coins)
	var base=coop.sessions[1].actor.current_weapons[0].data
	actor.add_weapon(base); actor.add_weapon(base)
	coop._render_panel(context_session)
	var selected=actor.current_weapons.back()
	var selected_index=0
	for j in panel.inventory.size():
		if panel.inventory[j].instance==selected: selected_index=9+j
	panel.select(selected_index); coop.activate(context_session,selected_index)
	assert(coop.can_combine(context_session,selected))
	check_sound(sound,"shop_combine",func(): coop.activate(context_session,5))
	assert(actor.current_weapons.has(last))
	assert(actor.current_weapons.any(func(w): return w.data==base.upgrade_to))
	assert(not panel.view.get_node("WeaponActions").visible)
	# Controller navigation stays inside the context menu and can close it.
	panel.select(9); coop.activate(context_session,9)
	panel.move_selector(Vector2.DOWN)
	assert(context_session.cursor==100)
	coop.activate(context_session,100)
	assert(panel.context_target()==null)
	for i in 3: coop.activate(coop.sessions[i],7)
	assert(coop.mode=="shop")
	for i in 4:
		assert(coop.panels[i].get_node("ReadyShade").visible==(i<3))
		assert(coop.panels[i].controls[7].text=="LISTO")
	if OS.get_cmdline_user_args().has("--capture"):
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/coop-ready-shade.png"))
	coop.activate(coop.sessions[0],7)
	assert(not coop.sessions[0].ready and coop.mode=="shop")
	assert(not coop.panels[0].get_node("ReadyShade").visible)
	# Only the final participant's Ready starts the next wave.
	for player_session in coop.sessions: player_session.ready=false
	var next_index=arena.spawner.wave_index+1
	for i in 4:
		coop.activate(coop.sessions[i],7)
		if i<3: assert(coop.mode=="shop")
	assert(coop.mode=="combat" and arena.spawner.wave_index==next_index)
	# Three participants keep the fourth quadrant empty and non-interactive.
	coop.stop()
	coop.open()
	for device in [-1,0,1]: coop.join(device)
	coop.start_run()
	await coop.wave_completed()
	await process_frame; await process_frame
	assert(coop.panels.size()==4)
	assert(coop.panels[3].get_node("Empty").visible)
	assert(not coop.panels[3].get_node("Margin").visible)
	assert(coop.panels[3].controls.is_empty())
	assert(coop.panels[3].get_theme_stylebox("panel").bg_color==coop.COLORS[3])
	assert(coop.panels[3].get_theme_stylebox("panel").border_color==coop.COLORS[3])
	assert(coop.panels[0].get_global_rect().size.is_equal_approx(coop.panels[3].get_global_rect().size))
	coop.stop()
	arena.queue_free()
	await process_frame; await process_frame
	print("PASS four fixed shop quadrants: ownership, offers, inventory details, stats, independent controller navigation, mouse hover, lock feedback and ready cancellation")
	quit()
