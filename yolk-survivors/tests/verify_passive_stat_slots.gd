extends SceneTree

func _initialize(): call_deferred("verify")

func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var global = root.get_node("Global")
	global.main_player_selected = load("res://resources/units/players/player_well_rounded.tres")
	var player = global.get_selected_player()
	root.add_child(player)
	player.set_process(false)
	var item = load("res://resources/items/passives/item_passive.gd").new()
	var ids = ["health", "armor", "melee_damage", "ranged_damage", "speed", "luck", "crowd_control"]
	var values = [5.0, -2.0, 3.0, -4.0, 6.0, 7.0, -8.0]
	var before = {}
	for i in 7:
		var suffix = "" if i == 0 else "_%d" % (i + 1)
		item.set("add_stats_id" + suffix, ids[i])
		item.set("add_value" + suffix, values[i])
		before[ids[i]] = player.stats.get(ids[i])
		var found = false
		for property in item.get_property_list():
			if property.name == "add_stats_id" + suffix:
				assert(property.hint == PROPERTY_HINT_ENUM)
				for stat_id in load("res://resources/character_passives/character_passive.gd").STAT_LABELS:
					assert(property.hint_string.split(",").has(stat_id))
				found = true
		assert(found)
	assert(item.get_stat_changes().size() == 7)
	var description = item.get_description()
	assert(description.contains("+5 health") and description.contains("-2 armor"))
	assert(not description.contains("--") and not description.contains("+-"))
	item.apply_passive_values()
	for i in 7:
		var gain = values[i] * (player.stats.get_stat_gain_multiplier(ids[i]) if values[i] > 0 else 1.0)
		assert(is_equal_approx(player.stats.get(ids[i]), before[ids[i]] + gain), ids[i])
	var improved = load("res://resources/items/golden_enhancement.gd").improve(item, 0.5)
	for i in 7:
		var field = "add_value" + ("" if i == 0 else "_%d" % (i + 1))
		assert(is_equal_approx(improved.get(field), values[i] * (1.5 if values[i] > 0 else 0.5)))
		assert(item.get(field) == values[i])
	item.add_stats_id_7 = ""
	assert(item.get_stat_changes().size() == 6)
	var paprika = load("res://resources/items/passives/catalogue/item_001.tres")
	assert(paprika.add_stats_id_2 == "hp_regen" and paprika.add_value_2 == -1)
	var old_rage = load("res://resources/items/passives/data/passive_item_rage.tres")
	assert(old_rage.get_script() == item.get_script(), "Legacy resources load with the new schema; their balance remains editable")
	print("PASS passive stat slots: seven signed changes, dropdowns, descriptions, character gains, golden enhancement, empty slots and migrated resources")
	player.queue_free()
	await process_frame
	quit()
