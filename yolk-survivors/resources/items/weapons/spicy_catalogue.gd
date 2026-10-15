extends RefCounted

const IDS := ["bell_pepper", "jalapeno", "habanero", "cayenne", "poblano", "carolina_reaper", "ghost_pepper", "aji_amarillo", "scotch_bonnet", "rocoto"]

static func items() -> Array[ItemWeapon]:
	var result: Array[ItemWeapon] = []
	for id in IDS:
		result.append(load("res://resources/items/weapons/spicy/item_%s.tres" % id))
	return result
