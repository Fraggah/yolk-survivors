extends RefCounted

const IDS := ["bell_pepper", "jalapeno", "habanero", "cayenne", "poblano", "carolina_reaper", "ghost_pepper", "aji_amarillo", "scotch_bonnet", "rocoto"]

static func items(all_tiers: bool = false) -> Array[ItemWeapon]:
	var result: Array[ItemWeapon] = []
	for id in IDS:
		var item := load("res://resources/items/weapons/chili/%s/item_%s.tres" % [id, id]) as ItemWeapon
		while item:
			result.append(item)
			if not all_tiers: break
			item = item.upgrade_to
	return result
