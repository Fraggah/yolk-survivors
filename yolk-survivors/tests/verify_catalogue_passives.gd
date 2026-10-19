extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	load("res://tests/progression_fixture.gd").prepare(root)
	var global = root.get_node("Global")
	global.main_player_selected = load("res://resources/units/players/player_well_rounded.tres")
	var player = global.get_selected_player()
	root.add_child(player)
	player.set_process(false)
	var catalogue = load("res://resources/items/passives/catalogue.gd").items()
	assert(catalogue.size() == 72)
	for item in catalogue:
		assert(item.item_icon != null and item.ready_for_shop)
	var miniature = load("res://resources/items/passives/catalogue/item_019.tres")
	var weapon_data = load("res://resources/items/weapons/melee/spatula/item_spatula_1.tres")
	var base_range: float = weapon_data.stats.max_range
	miniature.apply_passive_values()
	miniature.apply_passive_values()
	assert(player.stats.weapon_range == 50.0 and player.stats.area_of_effect == -20.0)
	assert(weapon_data.get_effective_range(player.stats) == base_range + 50.0)
	assert(weapon_data.stats.max_range == base_range)
	player.add_weapon(weapon_data)
	assert(player.current_weapons.back().collision.shape.radius == base_range + 50.0)
	var life_steal: float = player.stats.life_steal
	var regen: float = player.stats.hp_regen
	var paprika = load("res://resources/items/passives/catalogue/item_001.tres")
	paprika.apply_passive_values()
	paprika.apply_passive_values()
	assert(is_equal_approx(player.stats.life_steal, life_steal + 4.0 * player.stats.get_stat_gain_multiplier("life_steal")))
	assert(is_equal_approx(player.stats.hp_regen, regen - 2.0))
	var luck: float = player.stats.luck
	var cinnamon = load("res://resources/items/passives/catalogue/item_004.tres")
	cinnamon.apply_passive_values()
	cinnamon.apply_passive_values()
	assert(player.stats.experience_gain == 20.0)
	assert(is_equal_approx(player.stats.luck, luck - 4.0))
	var xp = load("res://resources/run_experience.gd").new()
	for index in 5: xp.add_experience(1, player.stats.experience_gain)
	assert(xp.experience == 6, "Small XP rewards retain fractional bonuses")
	xp.reset()
	assert(xp.experience == 0 and xp.fractional_experience == 0.0)
	var original_block: float = player.stats.block_chance
	var cocoa = load("res://resources/items/passives/catalogue/item_014.tres")
	cocoa.apply_passive_values()
	cocoa.apply_passive_values()
	assert(is_equal_approx(player.stats.block_chance, original_block + 6.0 * player.stats.get_stat_gain_multiplier("block_chance")))
	player.stats.apply_stat_change("block_chance", 100)
	assert(player.stats.get_block_chance() == 70.0)
	player.stats.apply_stat_change("block_chance", -200)
	assert(player.stats.get_block_chance() == 0.0)
	for id in [13, 79, 85, 86, 96, 97]:
		load("res://resources/items/passives/catalogue/item_%03d.tres" % id).apply_passive_values()
	assert(player.get_weapon_limit() == 7)
	assert(player.passive_items.count("double_yolk") == 1)
	assert(player.stats.bounces == 1)
	var hp: float = player.stats.health
	player.stats.apply_stat_change("armor", 3)
	assert(is_equal_approx(player.stats.health, hp + 6))
	player.stats.apply_stat_change("melee_damage", 5)
	assert(player.stats.melee_damage == 0 and player.stats.effects >= 5)
	load("res://resources/items/passives/catalogue/item_062.tres").apply_passive_values()
	player.health_component.take_damage(9999)
	assert(player.health_component.current_health > 0)
	assert(player.passive_items.extra_shell_used)
	player.health_component.take_damage(9999)
	assert(player.health_component.current_health > 0)
	player.passive_items.begin_wave()
	assert(not player.passive_items.extra_shell_used)
	load("res://resources/items/passives/catalogue/item_072.tres").apply_passive_values()
	var speed: float = player.stats.speed
	player.passive_items.on_block()
	player.passive_items.on_block()
	assert(is_equal_approx(player.stats.speed, speed * 1.2))
	player.passive_items._process(3.1)
	assert(is_equal_approx(player.stats.speed, speed))
	for id in [93, 94, 95]:
		assert(not load("res://resources/items/passives/catalogue/item_%03d.tres" % id).ready_for_shop)
	var initial_attack: float = player.stats.attack_speed
	load("res://resources/items/passives/catalogue/item_090.tres").apply_passive_values()
	player.stats.apply_stat_change("speed", speed * 0.1)
	assert(is_equal_approx(player.stats.attack_speed, initial_attack + 20.0))
	load("res://resources/items/passives/catalogue/item_088.tres").apply_passive_values()
	var damage: float = player.stats.damage_percent
	player.passive_items.on_status_applied(StatusEffect.Kind.ELECTRICITY, false)
	player.passive_items.on_status_applied(StatusEffect.Kind.ELECTRICITY, true)
	assert(is_equal_approx(player.stats.damage_percent, damage + 5.0 * player.stats.get_stat_gain_multiplier("damage_percent")))
	load("res://resources/items/passives/catalogue/item_089.tres").apply_passive_values()
	var attack: float = player.stats.attack_speed
	player.passive_items.on_status_applied(StatusEffect.Kind.FIRE, false)
	assert(is_equal_approx(player.stats.attack_speed, attack + 5.0))
	assert(load("res://resources/items/passives/catalogue/item_034.tres").get_shop_price(20) == 1)
	for copy in 5: load("res://resources/items/passives/catalogue/item_079.tres").apply_passive_values()
	assert(player.get_weapon_limit() == 9)
	assert(not load("res://resources/items/passives/catalogue/item_079.tres").available_for(player))
	global.player = null
	player.queue_free()
	await process_frame
	print("Catalogue passives verified")
	quit()

