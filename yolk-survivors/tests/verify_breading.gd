extends "res://tests/verify_status_system.gd"

func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var global = root.get_node("Global")
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	global.main_player_selected = load("res://resources/units/players/player_well_rounded.tres")
	var player = global.get_selected_player()
	arena.add_child(player)
	player.set_process(false)
	await process_frame
	var shop = arena.shop_panel
	var manager = player.passive_items
	var breading = load("res://resources/items/breading.gd")
	var consumable = load("res://resources/items/passives/catalogue/item_081.tres")
	for index in 10: shop._on_item_purchased(consumable)
	assert(manager.breading_charges == 10 and shop.passive_container.get_child_count() == 0)
	shop.breading_control.confirmation.confirmed.emit()
	assert(shop.breading_control.selecting and manager.breading_charges == 10)
	shop.golden_control.confirmation.confirmed.emit()
	assert(not shop.breading_control.selecting and shop.golden_control.selecting)
	shop.cancel_consumable_selection()
	var spatula = load("res://resources/items/weapons/melee/spatula/item_spatula_1.tres")
	shop._on_item_purchased(spatula)
	var card = shop.weapon_container.get_child(0)
	player.stats.apply_stat_change("melee_damage", 8)
	player.stats.apply_stat_change("ranged_damage", 12)
	var original_damage = spatula.get_effective_damage(player.stats)
	assert(shop.apply_breading(card, 1)) # Ranged
	assert(card.item.has_tag(1) and card.item.get_damage_scaling_stat_id() == "melee_damage")
	assert(is_equal_approx(card.item.get_effective_damage(player.stats), original_damage + 3))
	assert(not spatula.has_tag(1) and spatula.extra_damage_scalings.is_empty())
	assert(manager.breading_charges == 9 and not shop.apply_breading(card, 1))
	assert(manager.breading_charges == 9)
	assert(shop.apply_breading(card, 5)) # Chili, counting self
	assert(is_equal_approx(card.item.get_effective_damage(player.stats), (original_damage + 3) * 1.1))
	assert(shop.apply_breading(card, 7)) # Pet, counting self too
	assert(is_equal_approx(card.item.get_effective_damage(player.stats), (original_damage + 3) * 1.2))
	shop._on_item_purchased(spatula)
	var other = shop.weapon_container.get_child(1)
	assert(shop.apply_breading(other, 5))
	assert(is_equal_approx(card.item.get_effective_damage(player.stats), (original_damage + 3) * 1.3))
	# Adding Melee to a ranged weapon preserves its original Ranged scaling.
	var rifle = null
	for candidate in shop.shop_items:
		if candidate.item_type == 0 and candidate.has_tag(1) and not candidate.has_tag(0):
			rifle = candidate
			break
	assert(rifle != null)
	var melee_added = breading.add_tag(rifle, 0)
	assert(melee_added.get_damage_scaling_stat_id() == "ranged_damage")
	assert(is_equal_approx(melee_added.get_effective_damage(player.stats), rifle.get_effective_damage(player.stats) + 2))
	# Test real hit behavior with deterministic 100% test proc chances.
	var settings = consumable.duplicate()
	settings.breading_proc_chance = 1.0
	var tagged = breading.add_tag(spatula, 2, settings) # explosion
	tagged = breading.add_tag(tagged, 6, settings) # slow
	tagged = breading.add_tag(tagged, 3, settings) # fire
	tagged = breading.add_tag(tagged, 4, settings) # electric
	var target = enemy_at(arena, Vector2(600, 500))
	var neighbor = enemy_at(arena, Vector2(620, 500))
	var distant = enemy_at(arena, Vector2(1000, 500))
	var hit = load("res://scenes/components/hitbox_component.tscn").instantiate()
	arena.add_child(hit)
	hit.setup(20, false, 0, player)
	hit.weapon_damage_record = {"weapon": tagged, "instance_id": 500, "wave_damage": 0.0, "total_damage": 0.0}
	assert(target.receive_hit(hit))
	assert(target.has_status_named("Burning") and target.has_status_named("Shoked"))
	assert(target.has_status_named("Slow"))
	assert(is_equal_approx(target.get_status_movement_multiplier(), 0.8))
	assert(neighbor.health_component.current_health < 1000 and distant.health_component.current_health == 1000)
	assert(hit.weapon_damage_record.total_damage > 20 and hit.weapon_damage_record.total_damage < 100)
	# Secondary explosions/statuses must not recursively generate more effects.
	var explosions = 0
	for node in arena.get_children():
		if node.get_script() and node.get_script().resource_path == "res://scenes/projectiles/ranged_area_effect.gd": explosions += 1
	assert(explosions == 1)
	var enhanced = load("res://resources/items/golden_enhancement.gd").improve(tagged, 0.25)
	assert(enhanced.golden_multiplier == 1.25 and enhanced.breading_status_effects[0].get_meta("breading_generated"))
	assert(tagged.breading_status_effects[0].duration != enhanced.breading_status_effects[0].duration)
	var remaining = manager.breading_charges
	for tag in breading.available_tags(card.item, player): assert(shop.apply_breading(card, tag))
	assert(breading.available_tags(card.item, player).is_empty())
	remaining = manager.breading_charges
	assert(not shop.apply_breading(card) and manager.breading_charges == remaining)
	# Native Cayena ticks honor added scaling and contributor-specific effects.
	var cayena = null
	for candidate in shop.shop_items:
		if candidate.item_type == 0 and candidate.stats.spicy_pattern and candidate.stats.spicy_pattern.mode == 0:
			cayena = candidate
			break
	assert(cayena != null)
	var scaled_trail = breading.add_tag(cayena, 1)
	scaled_trail = breading.add_tag(scaled_trail, 7)
	scaled_trail = breading.add_tag(scaled_trail, 6)
	shop._on_item_purchased(scaled_trail)
	var trail_record = player.current_weapons.back().damage_record
	var trail_target = enemy_at(arena, Vector2(2000, 2000))
	var fire_settings = load("res://resources/status_effect.gd").new()
	var fire_template = load("res://scenes/components/hitbox_component.tscn").instantiate()
	arena.add_child(fire_template)
	fire_template.setup(1, false, 0, player)
	fire_template.weapon_damage_record = trail_record
	load("res://effects/fire_status.gd").apply(trail_target, "NativeTrail", fire_template, fire_settings)
	var burn = trail_target.get_node("NativeTrail")
	var expected = scaled_trail.get_effective_damage(player.stats)
	assert(is_equal_approx(burn.hit.base_damage, expected))
	burn._process(0.5)
	assert(trail_target.has_status_named("Slow"))
	assert(trail_record.total_damage > 0)
	assert(not neighbor.has_status_named("Slow"), "Electricity itself still does not slow")
	# Combining retains added tags and golden upgrades without mutating catalogue.
	var inherited = shop._inherit_golden_upgrade(spatula.upgrade_to, [card.item, other.item])
	assert(inherited.breading_tags.size() == card.item.breading_tags.size())
	assert(inherited.tags.size() == 8)
	assert(spatula.tags.size() == 1)
	print("PASS Rebozado: stored charges, selection/cancel, eight tags, native scaling preserved, 25% extra scaling, 10% self-inclusive Chili/Pet, real statuses/slow/explosion, no recursion, no duplicate tags, inheritance")
	arena.queue_free()
	await process_frame
	quit()
