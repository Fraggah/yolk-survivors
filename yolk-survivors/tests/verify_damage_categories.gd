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
	global.game_paused = false
	var stats = player.stats
	stats.damage_percent = 30
	stats.effects = 10
	stats.chili_power = 20
	stats.explosive_damage = 15
	var item = load("res://resources/items/weapons/item_weapon.gd").new()
	item.stats = load("res://resources/items/weapons/weapon_stats.gd").new()
	item.stats.damage = 10
	item.scales_with_effects = true
	item.effects_damage_scaling = 0.5
	item.damage_scaling_stat = 3
	assert(is_equal_approx(item.get_effective_damage(stats), 19.5))
	item.tags.assign([5])
	assert(is_equal_approx(item.get_effective_damage(stats), 22.5))
	item.tags.append(2)
	assert(is_equal_approx(item.get_effective_damage(stats), 24.75))
	assert(item.get_damage_description(stats).contains("50% [img") and item.get_damage_description(stats).contains("damage_effects.svg"))
	# Direct hits and explosions on an explosive weapon both gain the bonus once.
	var template = load("res://scenes/components/hitbox_component.tscn").instantiate()
	arena.add_child(template)
	template.setup(item.get_effective_damage(stats), false, 0, player)
	template.weapon_damage_record = {"weapon":item,"wave_damage":0.0,"total_damage":0.0}
	var config = load("res://resources/items/weapons/ranged_settings.gd").new()
	config.explosion_radius = 100
	config.explosion_damage_multiplier = 1
	var blast = load("res://scenes/projectiles/ranged_area_effect.gd").new()
	arena.add_child(blast)
	blast.setup(template, config, false)
	assert(is_equal_approx(blast.hit.base_damage, 24.75))
	# A derived explosion from a nonexplosive weapon adds the category, without compounding.
	item.tags.erase(2)
	template.setup(item.get_effective_damage(stats), false, 0, player)
	var secondary = load("res://scenes/projectiles/ranged_area_effect.gd").new()
	arena.add_child(secondary)
	secondary.setup(template, config, false)
	assert(is_equal_approx(secondary.hit.base_damage, 24.75))
	var third = load("res://scenes/projectiles/ranged_area_effect.gd").new()
	arena.add_child(third)
	third.setup(secondary.hit, config, false)
	assert(is_equal_approx(third.hit.base_damage, 24.75))
	# Electricity receives flat Effects times its own coefficient, then general damage.
	var enemy = enemy_at(arena, Vector2(2000, 0))
	var effect = load("res://resources/status_effect.gd").new()
	effect.kind = 1
	effect.damage = 2
	effect.damage_scaling = 0.5
	effect.maximum_chain_targets = 0
	load("res://effects/status_controller.gd").apply_effect(enemy, effect, template)
	assert(is_equal_approx(enemy.health_component.current_health, 989.5))
	# New stats participate in normal item gains, penalties and Inspector choices.
	var passive = load("res://resources/items/passives/item_passive.gd").new()
	passive.add_stats_id = "chili_power"
	passive.add_value = 10
	passive.add_stats_id_2 = "explosive_damage"
	passive.add_value_2 = -5
	passive.apply_passive_values()
	assert(stats._stat_gains.chili_power == 10 and stats._stat_gains.explosive_damage == -5)
	var script = load("res://scenes/ui/stats/stats_container.gd")
	assert(not script.PERCENT_STATS.has("effects"))
	assert(script.SECONDARY.has("chili_power") and script.SECONDARY.has("explosive_damage") and script.SECONDARY.has("effects"))
	print("PASS damage categories: flat Effects coefficients, additive percentages, tag isolation, direct/explosion no double dip, derived explosions, electricity, item stats and UI")
	arena.queue_free()
	await process_frame
	quit()
