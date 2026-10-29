extends RefCounted

const OWNED_FAMILY_CHANCE := 0.40
const SHARED_TAG_WEIGHT := 1.0

static func equipped(player: Player) -> Array[ItemWeapon]:
	var result: Array[ItemWeapon] = []
	if not is_instance_valid(player): return result
	for weapon in player.current_weapons:
		if is_instance_valid(weapon) and not weapon.is_queued_for_deletion(): result.append(weapon.data)
	return result

static func families(held: Array[ItemWeapon]) -> Array[String]:
	var result: Array[String] = []
	for item in held:
		if not result.has(item.get_offer_key()): result.append(item.get_offer_key())
	return result

static func shared_tags(held: Array[ItemWeapon]) -> Array[int]:
	var result: Array[int] = []
	for item in held:
		for tag in item.tags:
			if not result.has(tag): result.append(tag)
	return result

static func tag_weight(item: ItemWeapon, tags: Array[int]) -> float:
	var weight := 1.0
	for tag in tags:
		if item.has_tag(tag): weight += SHARED_TAG_WEIGHT
	return weight

static func weighted_weapon(candidates: Array, tags: Array[int]) -> ItemWeapon:
	var total := 0.0
	for item in candidates: total += tag_weight(item, tags)
	var roll := randf() * total
	for item in candidates:
		roll -= tag_weight(item, tags)
		if roll <= 0.0: return item
	return candidates.back()

## Called only AFTER rarity has been drawn. Preserve the existing weapon/passive
## proportion inside that tier; bias only the identity of weapon offers.
static func choose(candidates: Array, held: Array[ItemWeapon]) -> ItemBase:
	var weapons := candidates.filter(func(item): return item is ItemWeapon)
	if weapons.is_empty(): return candidates.pick_random()
	if weapons.size() < candidates.size() and randf() >= float(weapons.size()) / candidates.size():
		return candidates.filter(func(item): return not item is ItemWeapon).pick_random()
	var owned := families(held)
	var matches := weapons.filter(func(item): return owned.has(item.get_offer_key()))
	if not matches.is_empty() and randf() < OWNED_FAMILY_CHANCE:
		return weighted_weapon(matches, shared_tags(held))
	return weighted_weapon(weapons, shared_tags(held))

## Restrict tiers only when a full single-family loadout has at most one non-IV copy.
## A completed tier-IV loadout needs no further copies of that family.
static func useful_tier(item: ItemWeapon, held: Array[ItemWeapon], capacity: int) -> bool:
	if capacity <= 0 or held.size() < capacity or held.is_empty(): return true
	var family := held[0].get_offer_key()
	var lowest: int = held[0].item_tier
	var unfinished := 0
	for weapon in held:
		if weapon.get_offer_key() != family: return true
		lowest = mini(lowest, weapon.item_tier)
		if weapon.item_tier < 3: unfinished += 1
	if unfinished > 1: return true
	if item.get_offer_key() != family: return true
	return lowest < 3 and item.item_tier >= lowest
