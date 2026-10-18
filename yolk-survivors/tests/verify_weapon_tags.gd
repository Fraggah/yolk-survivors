extends SceneTree
func _initialize(): call_deferred("verify")
func scan(folder: String) -> int:
	var total := 0
	for file in DirAccess.get_files_at(folder):
		if not file.begins_with("item_") or not file.ends_with(".tres"): continue
		var item = load(folder.path_join(file))
		if item.get_script().resource_path != "res://resources/items/weapons/item_weapon.gd": continue
		assert(not item.tags.is_empty(), item.resource_path)
		assert(not item.get_category_label().contains("weapon"))
		assert(item.damage_scaling_stat != 0, "Scaling must be independent from tags")
		if item.upgrade_to:
			assert(item.tags == item.upgrade_to.tags)
			assert(item.matches_for_upgrade(item))
		total += 1
	for directory in DirAccess.get_directories_at(folder):
		total += scan(folder.path_join(directory))
	return total
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	assert(scan("res://resources/items/weapons") >= 160)
	var lighter = load("res://resources/items/weapons/melee/spark_lighter/item_spark_lighter_1.tres")
	assert(lighter.get_category_label() == "Melee · Pyro · Electric")
	assert(not lighter.has_tag(6))
	var pot = load("res://resources/items/weapons/range/pressure_cooker/item_pressure_cooker_1.tres")
	assert(pot.get_category_label() == "Ranged · Explosive · Control")
	var bell = load("res://resources/items/weapons/spicy/item_bell_pepper.tres")
	assert(bell.has_tag(1) and bell.get_damage_scaling_stat_id() == "" and bell.scales_with_effects)
	var cat = load("res://resources/items/weapons/pets/item_toaster_cat.tres")
	assert(cat.get_category_label() == "Pet" and cat.selection_only)
	print("PASS weapon tags: all resources and tiers verified")
	quit()
