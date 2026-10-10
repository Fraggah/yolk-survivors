extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
 load("res://tests/progression_fixture.gd").prepare(root)
 var model = load("res://resources/run_experience.gd").new()
 model.add_experience(42)
 assert(model.level == 3 and model.experience == 1 and model.pending_levels == [2, 3])
 model.reset()
 assert(model.level == 1 and model.experience == 0 and model.pending_levels.is_empty())
 var arena = load("res://scenes/arena/arena.tscn").instantiate()
 root.add_child(arena)
 var global = root.get_node("Global")
 global.main_player_selected = arena.selection_panel.player_list[0]
 global.main_weapon_selected = arena.weapon_selection_panel.weapons_list[0]
 arena.start_panel.hide()
 arena._on_level_selected(0)
 arena.spawner.spawn_timer.stop()
 var player = global.player
 player.health_component.take_damage(5)
 var hp = player.health_component.current_health
 var max_hp = player.stats.health
 global.collect_yolk(30)
 global.get_harvesting_coins()
 assert(arena.run_experience.experience == 0)
 var enemy = load("res://scenes/units/enemies/enemy_chaser.tscn").instantiate()
 enemy.stats = enemy.stats.duplicate()
 enemy.stats.experience_reward = 42
 arena.add_child(enemy)
 arena._on_enemy_died(enemy)
 arena._on_enemy_died(enemy)
 assert(arena.run_experience.level == 3 and arena.run_experience.experience == 1)
 assert(player.stats.health == max_hp + 2)
 assert(player.health_component.current_health == hp + 2)
 assert(player.health_component.max_health == player.stats.health)
 enemy.queue_free()
 arena.wave_active = false
 global.game_paused = true
 arena.show_upgrades()
 assert(arena.upgrade_panel.visible)
 var keys = []
 for card in arena.upgrade_panel.item_container.get_children():
  assert(not keys.has(card.item.get_offer_key()))
  keys.append(card.item.get_offer_key())
 arena.upgrade_panel.item_container.get_child(0)._on_custom_button_pressed()
 assert(arena.upgrade_panel.visible and arena.run_experience.pending_levels == [3])
 arena.upgrade_panel.item_container.get_child(0)._on_custom_button_pressed()
 assert(arena.shop_panel.visible and not arena.upgrade_panel.visible)
 arena._on_upgrade_selected()
 assert(arena.run_experience.pending_levels.is_empty())
 arena._on_pause_panel_on_exit_pressed()
 global.main_player_selected = arena.selection_panel.player_list[0]
 global.main_weapon_selected = arena.weapon_selection_panel.weapons_list[0]
 arena._on_level_selected(0)
 assert(arena.run_experience.level == 1 and arena.run_experience.experience == 0)
 arena.spawner.spawn_timer.stop()
 arena.spawner.wave_timer.stop()
 arena._on_spawner_on_wave_completed()
 await create_timer(1.15).timeout
 assert(arena.shop_panel.visible and not arena.upgrade_panel.visible)
 print("PASS: kill-only XP, duplicate guard, multiple levels/remainder, max/current HP, unique sequential upgrades, no-level shop and fresh run")
 quit()
