extends RefCounted
class_name RangedCatalogue

const IDS := ["bomb_corn", "toothpick_shotgun", "pressure_cooker", "meatball_machinegun", "pepper_bazooka", "anchovy_doublebarrel", "baguette_harpoon", "plate_launcher", "olive_launcher", "fusilli_launcher"]

static func items(all_tiers: bool = false) -> Array[ItemWeapon]:
	var result: Array[ItemWeapon] = []
	for id in IDS:
		for tier in range(1, 5 if all_tiers else 2):
			result.append(load("res://resources/items/weapons/range/%s/item_%s_%d.tres" % [id, id, tier]))
	return result
