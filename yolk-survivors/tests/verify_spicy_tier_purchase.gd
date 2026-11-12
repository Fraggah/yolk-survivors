extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	var mini=load("res://resources/items/weapons/chili/habanero/item_habanero.tres")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=mini
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	var player=global.player
	player.set_process(false)
	var shop=arena.shop_panel
	arena.start_panel.hide()
	global.game_paused=true
	shop.show()
	await process_frame
	shop.load_shop(1)
	global.coins=10000
	assert(player.current_weapons.size()==1)
	var before=global.coins
	assert(shop.try_purchase_item(mini))
	assert(global.coins==before-mini.get_shop_price(1))
	assert(player.current_weapons.size()==2,"Buying a second minipimer must equip a second instance")
	assert(global.equipped_weapons.size()==2)
	assert(player.current_weapons[0]!=player.current_weapons[1])
	var card=shop.weapon_container.get_child(0)
	shop._on_item_card_selected(card,false)
	assert(not shop.combine_button.disabled)
	shop._on_combine_button_pressed()
	await process_frame
	assert(player.current_weapons.size()==1 and player.current_weapons[0].data==mini.upgrade_to)
	assert(global.equipped_weapons==[mini.upgrade_to])
	# Buy every tier, checking both live equipment and its inventory card.
	var item=mini
	for tier in 4:
		assert(item.item_type==0 and item.type==2,"Ranged category and shop weapon category are independent")
		var count=player.current_weapons.size()
		assert(shop.try_purchase_item(item))
		assert(player.current_weapons.size()==count+1)
		var bought=shop.weapon_container.get_child(shop.weapon_container.get_child_count()-1)
		assert(bought.weapon_instance==player.current_weapons.back())
		assert(bought.weapon_instance.data==item)
		shop._on_item_card_selected(bought,false)
		shop._on_sell_weapon_button_pressed()
		await process_frame
		assert(player.current_weapons.size()==count)
		item=item.upgrade_to
	arena.queue_free()
	await process_frame
	print("PASS spicy tier purchase: second copy equipped, charged once, combine, all tiers and sell")
	quit()
