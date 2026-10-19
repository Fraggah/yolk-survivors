extends RefCounted

## Explicit active index avoids loading textures of all pending items at runtime.
const ACTIVE_IDS := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 34, 40, 42, 44, 45, 46, 47, 56, 57, 58, 60, 61, 62, 63, 64, 65, 66, 67, 69, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 96, 97, 98, 99, 100]
static var _cached: Array[ItemPassive] = []

static func items() -> Array[ItemPassive]:
	if _cached.is_empty():
		for id in ACTIVE_IDS:
			var item = load("res://resources/items/passives/catalogue/item_%03d.tres" % id)
			if item.ready_for_shop: _cached.append(item)
	return _cached.duplicate()
