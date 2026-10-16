extends ItemBase
class_name ItemWeapon

enum Type {
	MELEE,
	RANGE,
	SPICY
}

@export var unlock_id: String
@export var selection_only := false
@export var type: Type
@export var scene: PackedScene
@export var stats: WeaponStats
@export var upgrade_to: ItemWeapon
@export_multiline var attack_description: String
## Percentage deltas summed across equipped copies, applied after all ordinary stats.
@export var final_stat_modifiers: Dictionary = {}
@export var health_drain_per_second := 0.0
@export var on_hit_effects: Array[StatusEffect] = []

func matches_for_upgrade(other: ItemWeapon) -> bool:
	return other != null and scene != null and scene == other.scene \
		and type == other.type and item_tier == other.item_tier

func get_category_label() -> String:
	if type == Type.SPICY: return "Spicy"
	if stats and stats.ranged_settings and stats.ranged_settings.explodes: return "Explosive weapon"
	return "Melee weapon" if type == Type.MELEE else "Ranged weapon"

func get_effective_damage(player_stats: UnitStats = null) -> float:
	var flat_bonus := 0.0
	var percent_bonus := 0.0
	if player_stats:
		flat_bonus = player_stats.melee_damage if type == Type.MELEE else player_stats.ranged_damage if type == Type.RANGE else 0.0
		percent_bonus = player_stats.unmodified_stat("damage_percent")
	var amount := maxf(1.0, (stats.damage + flat_bonus * stats.damage_scaling) * (1.0 + percent_bonus / 100.0))
	if player_stats: amount *= player_stats.final_multiplier("damage_percent")
	return amount * player_stats.get_effect_multiplier() if type == Type.SPICY and player_stats else amount

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
	if type == Type.SPICY: return format_number(get_effective_damage(player_stats))
	var icon := "damage_melee" if type == Type.MELEE else "damage_ranged"
	return "%s (%s%% [img width=22 height=22 color=green]res://assets/sprites/UI/%s.svg[/img])" % [format_number(get_effective_damage(player_stats)), format_number(stats.damage_scaling * 100.0), icon]

func get_description(player_stats: UnitStats = null) -> String:
	if selection_only: return "Ability not available yet.\nStart without equipment."
	var description := "Damage: [color=green]%s[/color]\nCooldown: [color=green]%s s[/color]\nRange: [color=green]%s[/color]\nCritical chance: [color=green]%s%%[/color]" % [get_damage_description(player_stats), format_number(get_effective_cooldown(player_stats)), get_range_description(), format_number(get_effective_critical_chance(player_stats) * 100.0)]
	if type == Type.RANGE:
		if stats.unlimited_piercing: description += "\nPiercing: [color=green]Unlimited[/color]"
		elif get_effective_piercing(player_stats) > 0: description += "\nPiercing: [color=green]%d[/color]" % get_effective_piercing(player_stats)
		if get_effective_bounces(player_stats) > 0: description += "\nBounces: [color=green]%d[/color]" % get_effective_bounces(player_stats)
	if not attack_description.is_empty(): description += "\n" + attack_description
	for stat_id in final_stat_modifiers:
		description += "\n%s: %s%s%% final" % [str(stat_id).replace("_", " ").capitalize(), "+" if float(final_stat_modifiers[stat_id]) > 0.0 else "", format_number(final_stat_modifiers[stat_id])]
	if health_drain_per_second > 0.0: description += "\nHealth cost: %s HP/s" % format_number(health_drain_per_second)
	return description

func get_effective_piercing(player_stats: UnitStats = null) -> int:
	return maxi(0, stats.piercing + (player_stats.piercing if player_stats else 0))

func get_effective_bounces(player_stats: UnitStats = null) -> int:
	if stats.unlimited_piercing: return 0
	return maxi(0, stats.bounces + (player_stats.bounces if player_stats else 0))

func get_offer_key() -> String:
	return "weapon:%s:%s" % [type, scene.resource_path if scene else item_name]
