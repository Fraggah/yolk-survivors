extends ItemBase
class_name ItemWeapon

enum Type {
	MELEE,
	RANGE,
	SPICY
}

enum Tag { MELEE, RANGED, EXPLOSIVE, PYRO, ELECTRIC, CHILY, CONTROL, PET }
const TAG_LABELS := ["Melee", "Ranged", "Explosive", "Pyro", "Electric", "Chily", "Control", "Pet"]
@export var tags: Array[Tag] = []
@export var scales_with_effects := false

enum DamageScalingStat { AUTO, MELEE, RANGED, NONE }
## Optional scaling-stat override without changing the weapon category.
@export var damage_scaling_stat := DamageScalingStat.AUTO

@export var unlock_id: String
@export var selection_only := false
## Legacy serialized value only. Classification uses tags.
@export_storage var type: Type
@export var scene: PackedScene
@export var stats: WeaponStats
@export var upgrade_to: ItemWeapon
@export_multiline var attack_description: String
## Percentage deltas summed across equipped copies, applied after all ordinary stats.
@export var final_stat_modifiers: Dictionary = {}
@export var health_drain_per_second := 0.0
@export var max_health_drain_percent_per_second := 0.0
@export var on_hit_effects: Array[StatusEffect] = []

func matches_for_upgrade(other: ItemWeapon) -> bool:
	return other != null and scene != null and scene == other.scene \
		and item_tier == other.item_tier

func has_tag(tag: Tag) -> bool:
	return tags.has(tag)

func get_category_label() -> String:
	var labels := PackedStringArray()
	for tag in tags:
		if not labels.has(TAG_LABELS[tag]): labels.append(TAG_LABELS[tag])
	return " · ".join(labels)

func get_damage_scaling_stat_id() -> String:
	if damage_scaling_stat == DamageScalingStat.MELEE: return "melee_damage"
	if damage_scaling_stat == DamageScalingStat.RANGED: return "ranged_damage"
	if damage_scaling_stat == DamageScalingStat.NONE: return ""
	if has_tag(Tag.MELEE): return "melee_damage"
	if has_tag(Tag.RANGED): return "ranged_damage"
	return ""

func get_effective_damage(player_stats: UnitStats = null) -> float:
	var flat_bonus := 0.0
	var percent_bonus := 0.0
	if player_stats:
		var stat_id := get_damage_scaling_stat_id()
		flat_bonus = float(player_stats.get(stat_id)) if not stat_id.is_empty() else 0.0
		percent_bonus = player_stats.unmodified_stat("damage_percent")
	var amount := maxf(1.0, (stats.damage + flat_bonus * stats.damage_scaling) * (1.0 + percent_bonus / 100.0))
	if player_stats: amount *= player_stats.final_multiplier("damage_percent")
	return amount * player_stats.get_effect_multiplier() if scales_with_effects and player_stats else amount

func get_effective_critical_multiplier(player_stats: UnitStats = null) -> float:
	if not player_stats: return stats.crit_damage
	return maxf(1.0, stats.crit_damage * maxf(0.0, 1.0 + player_stats.unmodified_stat("critical_multiplier") / 100.0)) * player_stats.final_multiplier("critical_multiplier")

func get_effective_cooldown(player_stats: UnitStats = null) -> float:
	var bonus := player_stats.attack_speed if player_stats else 0.0
	var duration := stats.cooldown / (1.0 + bonus / 100.0) if bonus >= 0.0 else stats.cooldown * (1.0 + absf(bonus) / 100.0)
	return maxf(0.05, duration)

func get_effective_critical_chance(player_stats: UnitStats = null) -> float:
	return clampf((stats.crit_chance + (player_stats.unmodified_stat("critical_chance") / 100.0 if player_stats else 0.0)) * (player_stats.final_multiplier("critical_chance") if player_stats else 1.0), 0.0, 1.0)

func get_effective_life_steal(player_stats: UnitStats = null) -> float:
	return maxf(0.0, stats.life_steal + (player_stats.life_steal / 100.0 if player_stats else 0.0))

static func format_number(value: float) -> String:
	return ("%.2f" % value).trim_suffix("0").trim_suffix("0").trim_suffix(".")

func get_range_description() -> String:
	return format_number(stats.max_range)

func get_damage_description(player_stats: UnitStats = null) -> String:
	var stat_id := get_damage_scaling_stat_id()
	if stat_id.is_empty(): return format_number(get_effective_damage(player_stats))
	var icon := "damage_melee" if stat_id == "melee_damage" else "damage_ranged"
	return "%s (%s%% [img width=22 height=22 color=green]res://assets/sprites/UI/%s.svg[/img])" % [format_number(get_effective_damage(player_stats)), format_number(stats.damage_scaling * 100.0), icon]

func get_description(player_stats: UnitStats = null) -> String:
	if selection_only: return "Ability not available yet.\nStart without equipment."
	var description := "Damage: [color=green]%s[/color]\nCooldown: [color=green]%s s[/color]\nRange: [color=green]%s[/color]\nCritical chance: [color=green]%s%%[/color]" % [get_damage_description(player_stats), format_number(get_effective_cooldown(player_stats)), get_range_description(), format_number(get_effective_critical_chance(player_stats) * 100.0)]
	if has_tag(Tag.RANGED):
		if stats.unlimited_piercing: description += "\nPiercing: [color=green]Unlimited[/color]"
		elif get_effective_piercing(player_stats) > 0: description += "\nPiercing: [color=green]%d[/color]" % get_effective_piercing(player_stats)
		if get_effective_bounces(player_stats) > 0: description += "\nBounces: [color=green]%d[/color]" % get_effective_bounces(player_stats)
	if not attack_description.is_empty(): description += "\n" + attack_description
	for stat_id in final_stat_modifiers:
		description += "\n%s: %s%s%% final" % [str(stat_id).replace("_", " ").capitalize(), "+" if float(final_stat_modifiers[stat_id]) > 0.0 else "", format_number(final_stat_modifiers[stat_id])]
	if health_drain_per_second > 0.0: description += "\nHealth cost: %s HP/s" % format_number(health_drain_per_second)
	if max_health_drain_percent_per_second > 0.0: description += "\nHealth cost: %s%% max HP/s" % format_number(max_health_drain_percent_per_second)
	return description

func get_effective_piercing(player_stats: UnitStats = null) -> int:
	return maxi(0, stats.piercing + (player_stats.piercing if player_stats else 0))

func get_effective_bounces(player_stats: UnitStats = null) -> int:
	if stats.unlimited_piercing: return 0
	return maxi(0, stats.bounces + (player_stats.bounces if player_stats else 0))

func get_offer_key() -> String:
	return "weapon:%s" % [scene.resource_path if scene else item_name]
