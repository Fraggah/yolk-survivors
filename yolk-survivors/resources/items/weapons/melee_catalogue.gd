extends RefCounted
# New melee additions, alongside the original scene-authored roster.
static func items(all_tiers: bool = false) -> Array[ItemWeapon]:
	var result: Array[ItemWeapon] = []
	for tier in range(1,5 if all_tiers else 2):
		result.append(load("res://resources/items/weapons/melee/spark_lighter/item_spark_lighter_%d.tres" % tier))
	return result
