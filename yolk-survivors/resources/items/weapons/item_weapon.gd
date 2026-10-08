extends ItemBase
class_name ItemWeapon

enum Type {
	MELEE,
	RANGE
}

@export var type: Type
@export var scene: PackedScene
@export var stats: WeaponStats
@export var upgrade_to: ItemWeapon

func matches_for_upgrade(other: ItemWeapon) -> bool:
	return other != null and scene != null and scene == other.scene \
		and type == other.type and item_tier == other.item_tier

func get_effective_damage(player_stats: UnitStats = null) -> float:
	var flat_bonus := 0.0
	var percent_bonus := 0.0
	if player_stats:
		flat_bonus = player_stats.melee_damage if type == Type.MELEE else player_stats.ranged_damage
		percent_bonus = player_stats.damage_percent
	return maxf(1.0, (stats.damage + flat_bonus * stats.damage_scaling) * (1.0 + percent_bonus / 100.0))

func get_effective_cooldown(player_stats: UnitStats = null) -> float:
	var bonus := player_stats.attack_speed if player_stats else 0.0
	var duration := stats.cooldown / (1.0 + bonus / 100.0) if bonus >= 0.0 else stats.cooldown * (1.0 + absf(bonus) / 100.0)
	return maxf(0.05, duration)

static func format_number(value: float) -> String:
	return ("%.2f" % value).trim_suffix("0").trim_suffix("0").trim_suffix(".")

func get_description(player_stats: UnitStats = null) -> String:
	return "Damage: [color=green]%s[/color]\nScaling: [color=green]%s%% %s[/color]\nCooldown: [color=green]%s s[/color]\nRange: [color=green]%s[/color]\nCritical chance: [color=green]%s%%[/color]\nAccuracy: [color=green]%s%%[/color]\nKnockback: [color=green]%s[/color]" % [format_number(get_effective_damage(player_stats)), format_number(stats.damage_scaling * 100.0), "melee" if type == Type.MELEE else "ranged", format_number(get_effective_cooldown(player_stats)), format_number(stats.max_range), format_number(stats.crit_chance * 100.0), format_number(stats.accuracy * 100.0), format_number(stats.knockback)]

func get_offer_key() -> String:
	return "weapon:%s:%s" % [type, scene.resource_path if scene else item_name]
