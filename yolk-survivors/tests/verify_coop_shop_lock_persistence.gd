extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena); current_scene=arena
	await process_frame
	var coop=arena.coop
	coop.set_process(false)
	coop.open()
	for device in [-1,0,1,2]: coop.join(device)
	coop.start_run(); await coop.wave_completed()
	var held: Array=[]
	for i in 4:
		var s=coop.sessions[i]
		held.append(s.offers[i])
		coop.toggle_lock(s,i)
		coop.activate(s,7)
	assert(coop.mode=="combat")
	for s in coop.sessions: assert(not s.saved_shop_offers.is_empty())
	coop.sessions[0].experience.grant_levels(1)
	coop.sessions[2].experience.grant_levels(1)
	var passive=null
	for item in arena.shop_panel.shop_items:
		if item.get("effect_key")=="oregano": passive=item; break
	coop.sessions[1].rewards.append(passive)
	await coop.wave_completed()
	assert(coop.mode=="rewards")
	var reward_panel=coop.panels[1]
	assert(reward_panel.controls.size()==2)
	assert(reward_panel.card.item_cost.text=="CONSERVAR")
	assert(not reward_panel.controls[0].get_node("HBoxContainer/TextureRect").visible)
	assert(reward_panel.sell_value.text.begins_with("VENDER ") and reward_panel.controls[1].has_node("SellContent/Row/Yolk"))
	for panel in coop.panels: assert(panel.get_theme_stylebox("panel") is StyleBoxEmpty)
	reward_panel.move_selector(Vector2.DOWN)
	assert(coop.sessions[1].cursor==1)
	if OS.get_cmdline_user_args().has("--capture"):
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/coop-reward-panel.png"))
	coop.activate(coop.sessions[1],1)
	assert(coop.mode=="upgrades")
	coop.activate(coop.sessions[0],0); coop.activate(coop.sessions[2],0)
	assert(coop.mode=="shop")
	for i in 4:
		var s=coop.sessions[i]
		assert(s.offers[i]==held[i] and s.locked[i])
		assert(coop.panels[i].offers[i].lock_button.text=="LOCKED")
		assert(coop.panels[i].offers[i].lock_button.button_pressed)
		assert(s.offers.size()==4 and s.saved_shop_offers.is_empty())
	# Unlocking removes persistence on the next visit.
	coop.toggle_lock(coop.sessions[0],0)
	for s in coop.sessions: coop.activate(s,7)
	await coop.wave_completed()
	assert(coop.mode=="shop" and not coop.sessions[0].locked[0])
	for i in [1,2,3]: assert(coop.sessions[i].offers[i]==held[i] and coop.sessions[i].locked[i])
	coop.stop(); arena.queue_free()
	await process_frame; await process_frame
	print("PASS shop locks persist for all four players through combat, rewards and upgrades; LOCKED label/state restored; unlock respected")
	quit()
