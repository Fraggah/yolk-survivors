extends SceneTree
func _initialize(): call_deferred("verify")
func unique(shop):
 var keys = []
 for card in shop.items_container.get_children():
  assert(not keys.has(card.shop_item.get_offer_key()))
  keys.append(card.shop_item.get_offer_key())
func verify():
 load("res://tests/progression_fixture.gd").prepare(root)
 var arena = load("res://scenes/arena/arena.tscn").instantiate()
 root.add_child(arena)
 var global = root.get_node("Global")
 global.main_player_selected = arena.selection_panel.player_list[0]
 global.main_weapon_selected = arena.weapon_selection_panel.weapons_list[0]
 arena.start_panel.hide()
 arena._on_level_selected(0)
 arena.spawner.spawn_timer.stop()
 var shop = arena.shop_panel
 shop.load_shop(1)
 shop.show()
 global.coins = 1000
 var card = shop.items_container.get_child(1)
 var item = card.shop_item
 var price = item.get_shop_price(card.shop_wave)
 card.lock_button.button_pressed = true
 assert(card.locked)
 assert(shop.try_reroll())
 assert(shop.items_container.get_child(1) == card and card.shop_item == item)
 unique(shop)
 shop.load_shop(6)
 assert(card.shop_item == item and card.shop_wave == 1 and card.item_cost.text == str(price))
 unique(shop)
 var coins = global.coins
 card._on_custom_button_pressed()
 assert(global.coins == coins - price)
 assert(not card.locked and card.shop_wave == 6)
 unique(shop)
 for offer in shop.items_container.get_children(): offer.set_locked(true)
 coins = global.coins
 assert(not shop.try_reroll() and global.coins == coins)
 shop.reset_offers()
 shop.clear_items()
 shop.load_shop(7)
 assert(shop._locked_offer_keys().is_empty())
 shop.hide()
 arena.run_experience.add_experience(41)
 arena.upgrade_panel.begin_wave_rewards(3)
 arena.show_upgrades()
 var pending = arena.run_experience.pending_levels.duplicate()
 var cost = arena.upgrade_panel.get_reroll_cost()
 global.coins = 0
 assert(not arena.upgrade_panel.try_reroll())
 global.coins = 100
 assert(arena.upgrade_panel.try_reroll())
 assert(global.coins == 100 - cost and arena.run_experience.pending_levels == pending)
 arena.upgrade_panel.item_container.get_child(0)._on_custom_button_pressed()
 assert(arena.upgrade_panel.reroll_count == 1)
 arena.upgrade_panel.item_container.get_child(0)._on_custom_button_pressed()
 assert(shop.reroll_count == 0)
 print("PASS: locked slot/item/price across reroll/waves, unique offers, locked purchase/refill/reset, all-locked no charge, upgrade reroll currency/pending/shared costs/separate shop")
 quit()
