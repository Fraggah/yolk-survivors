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
	player.stats.apply_stat_change("critical_chance", 100)
	player.stats.apply_stat_change("effects", 10)
	var chili = load("res://resources/items/weapons/spicy/item_jalapeno.tres")
	var normal = load("res://resources/items/weapons/melee/spatula/item_spatula_1.tres")
	var pepper = load("res://resources/items/passives/catalogue/item_040.tres")
	assert(pepper.ready_for_shop and pepper.effect_key == "pepper")
	assert(chili.get_effective_critical_chance(player.stats) == 0)
	assert(normal.get_effective_critical_chance(player.stats) == 1)
	var target = enemy_at(arena, Vector2(700, 0))
	var hit = load("res://scenes/components/hitbox_component.tscn").instantiate()
	arena.add_child(hit)
	hit.setup(10, false, 0, player)
	hit.roll_critical_per_target = true
	hit.critical_chance = 1
	hit.critical_multiplier = 3
	hit.weapon_damage_record = {"weapon":chili,"wave_damage":0.0,"total_damage":0.0}
	target.receive_hit(hit)
	assert(not hit.critical and target.health_component.current_health == 990)
	# Shared aura/trail records retain the same Chili restriction.
	var record = hit.weapon_damage_record
	hit.weapon_damage_record = {"contributors":[{"record":record,"weight":1.0}],"wave_damage":0.0,"total_damage":0.0}
	target.receive_hit(hit)
	assert(not hit.critical and target.health_component.current_health == 980)
	pepper.apply_passive_values()
	assert(player.stats.chili_crit_enabled and chili.get_effective_critical_chance(player.stats) == 1)
	target.receive_hit(hit)
	assert(hit.critical and target.health_component.current_health == 950)
	var effect = load("res://resources/status_effect.gd").new()
	effect.duration = 2.0
	load("res://effects/fire_status.gd").apply(target, "NoCriticalFire", hit, effect)
	var burn = target.get_node("NoCriticalFire")
	burn.set_process(false)
	assert(not burn.hit.critical_allowed and not burn.hit.roll_critical_per_target)
	var before = target.health_component.current_health
	# Fire remains noncritical even if the source was guaranteed critical.
	burn.hit.roll_critical_per_target = true
	burn.hit.critical_chance = 1
	burn.hit.critical_multiplier = 10
	burn._process(burn.interval)
	assert(not burn.hit.critical and is_equal_approx(before - target.health_component.current_health, burn.hit.base_damage))
	player.passive_items.replace_owned(player.passive_items.find_owned_record(pepper), null)
	assert(not player.stats.chili_crit_enabled and chili.get_effective_critical_chance(player.stats) == 0)
	assert(normal.get_effective_critical_chance(player.stats) == 1)
	hit.weapon_damage_record = record
	target.receive_hit(hit)
	assert(not hit.critical)
	var breaded = load("res://resources/items/breading.gd").add_tag(normal, 5)
	assert(breaded.get_effective_critical_chance(player.stats) == 0)
	print("PASS Chili criticals: blocked by default, shared effects, Pepper unlock/removal, normal weapons unaffected, fire ticks never crit, added Chili tags")
	arena.queue_free()
	await process_frame
	quit()
