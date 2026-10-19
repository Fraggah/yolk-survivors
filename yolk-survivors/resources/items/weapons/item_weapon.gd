extends ItemBase
class_name ItemWeapon

enum Type {
	MELEE,
	RANGE,
	SPICY
}

enum Tag { MELEE, RANGED, EXPLOSIVE, PYRO, ELECTRIC, CHILI, CONTROL, PET }
const TAG_LABELS := ["Melee", "Ranged", "Explosive", "Pyro", "Electric", "Chili", "Control", "Pet"]
@export var tags: Array[Tag] = []
## Run-local Rebozado additions, separate from native behavior and scaling.
@export var breading_tags: Array[Tag] = []
@export var extra_damage_scalings: Dictionary = {}
@export var breading_chili_damage_percent := 0.0
@export var breading_pet_damage_percent := 0.0
@export var breading_explosion_radius := 0.0
@export var breading_explosion_damage_ratio := 0.0
@export var breading_slow_strength := 0.0
@export var breading_slow_duration := 0.0
@export var breading_status_effects: Array[StatusEffect] = []
@export var scales_with_effects := false
## Flat Effects coefficient; 1.0 means 100%, independent of melee/ranged scaling.
@export var effects_damage_scaling := 1.0

enum DamageScalingStat { AUTO, MELEE, RANGED, NONE, EFFECTS }
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
	if damage_scaling_stat == DamageScalingStat.EFFECTS: return "effects"
	if damage_scaling_stat == DamageScalingStat.NONE: return ""
	if has_tag(Tag.MELEE): return "melee_damage"
	if has_tag(Tag.RANGED): return "ranged_damage"
	return ""

func get_effective_damage(player_stats: UnitStats = null, force_explosive: bool = false) -> float:
	var flat := stats.damage
	if player_stats:
		var stat_id := get_damage_scaling_stat_id()
		if not stat_id.is_empty(): flat += float(player_stats.get(stat_id)) * stats.damage_scaling
		if scales_with_effects and stat_id != "effects": flat += player_stats.effects * effects_damage_scaling
		for key in extra_damage_scalings: flat += float(player_stats.get(key)) * float(extra_damage_scalings[key])
	var percent := player_stats.get_damage_percent_multiplier(has_tag(Tag.CHILI), force_explosive or has_tag(Tag.EXPLOSIVE)) if player_stats else 1.0
	return maxf(1.0, flat * percent) * (get_breading_tag_multiplier() if player_stats else 1.0)

## Recontextualize derived explosions without applying explosive damage twice.
static func explosion_damage_ratio(record: Dictionary, player_stats: UnitStats) -> float:
	if record.has("contributors"):
		var ratio := 0.0
		for share in record.contributors: ratio += float(share.weight) * explosion_damage_ratio(share.record, player_stats)
		return ratio
	var item = record.get("weapon")
	if item is ItemWeapon:
		return item.get_effective_damage(player_stats, true) / maxf(0.00001, item.get_effective_damage(player_stats))
	return player_stats.get_damage_percent_multiplier(false, true) / maxf(0.00001, player_stats.get_damage_percent_multiplier())

static func status_damage_multiplier(record: Dictionary, player_stats: UnitStats) -> float:
	if record.has("contributors"):
		var multiplier := 0.0
		for share in record.contributors: multiplier += float(share.weight) * status_damage_multiplier(share.record, player_stats)
		return multiplier
	var item = record.get("weapon")
	return player_stats.get_damage_percent_multiplier(item.has_tag(Tag.CHILI) if item is ItemWeapon else false, item.has_tag(Tag.EXPLOSIVE) if item is ItemWeapon else false)

func get_effective_critical_multiplier(player_stats: UnitStats = null) -> float:
	if not player_stats: return stats.crit_damage
	return maxf(1.0, stats.crit_damage * maxf(0.0, 1.0 + player_stats.unmodified_stat("critical_multiplier") / 100.0)) * player_stats.final_multiplier("critical_multiplier")

func get_effective_cooldown(player_stats: UnitStats = null) -> float:
	var bonus := player_stats.attack_speed if player_stats else 0.0
	var duration := stats.cooldown / (1.0 + bonus / 100.0) if bonus >= 0.0 else stats.cooldown * (1.0 + absf(bonus) / 100.0)
	return maxf(0.05, duration)

func get_effective_critical_chance(player_stats: UnitStats = null) -> float:
	if has_tag(Tag.CHILI) and (player_stats == null or not player_stats.chili_crit_enabled): return 0.0
	return clampf((stats.crit_chance + (player_stats.unmodified_stat("critical_chance") / 100.0 if player_stats else 0.0)) * (player_stats.final_multiplier("critical_chance") if player_stats else 1.0), 0.0, 1.0)

static func record_allows_critical(record: Dictionary, player_stats: UnitStats) -> bool:
	if player_stats.chili_crit_enabled: return true
	if record.has("contributors"):
		for share in record.contributors:
			if not record_allows_critical(share.record, player_stats): return false
	var item = record.get("weapon")
	return not item is ItemWeapon or not item.has_tag(Tag.CHILI)

func get_effective_life_steal(player_stats: UnitStats = null) -> float:
	return maxf(0.0, stats.life_steal + (player_stats.life_steal / 100.0 if player_stats else 0.0))

static func format_number(value: float) -> String:
	return ("%.2f" % value).trim_suffix("0").trim_suffix("0").trim_suffix(".")

func get_effective_range(player_stats: UnitStats = null) -> float:
	return maxf(1.0, stats.max_range + (player_stats.weapon_range if player_stats else 0.0))

func get_range_description(player_stats: UnitStats = null) -> String:
	return format_number(get_effective_range(player_stats))

func get_damage_description(player_stats: UnitStats = null) -> String:
	var components := PackedStringArray()
	var stat_id := get_damage_scaling_stat_id()
	if not stat_id.is_empty():
		var icon := "damage_melee" if stat_id == "melee_damage" else "damage_ranged"
		if stat_id == "effects": components.append("%s%% Effects" % format_number(stats.damage_scaling * 100.0))
		else: components.append("%s%% [img width=22 height=22 color=green]res://assets/sprites/UI/%s.svg[/img]" % [format_number(stats.damage_scaling * 100.0), icon])
	if scales_with_effects and stat_id != "effects": components.append("%s%% Effects" % format_number(effects_damage_scaling * 100.0))
	for key in extra_damage_scalings:
		var icon := "damage_melee" if key == "melee_damage" else "damage_ranged"
		components.append("%s%% [img width=22 height=22 color=green]res://assets/sprites/UI/%s.svg[/img]" % [format_number(float(extra_damage_scalings[key]) * 100.0), icon])
	return "%s (%s)" % [format_number(get_effective_damage(player_stats)), " + ".join(components)] if not components.is_empty() else format_number(get_effective_damage(player_stats))

func get_description(player_stats: UnitStats = null) -> String:
	if selection_only: return "Ability not available yet.\nStart without equipment."
	var description := "Damage: [color=green]%s[/color]\nCooldown: [color=green]%s s[/color]\nRange: [color=green]%s[/color]\nCritical chance: [color=green]%s%%[/color]" % [get_damage_description(player_stats), format_number(get_effective_cooldown(player_stats)), get_range_description(player_stats), format_number(get_effective_critical_chance(player_stats) * 100.0)]
	if has_tag(Tag.RANGED):
		if stats.unlimited_piercing: description += "\nPiercing: [color=green]Unlimited[/color]"
		elif get_effective_piercing(player_stats) > 0: description += "\nPiercing: [color=green]%d[/color]" % get_effective_piercing(player_stats)
		if get_effective_bounces(player_stats) > 0: description += "\nBounces: [color=green]%d[/color]" % get_effective_bounces(player_stats)
	description += get_status_damage_description(player_stats)
	if breading_chili_damage_percent > 0.0: description += "\n+%s%% damage per equipped Chili (includes self)" % format_number(breading_chili_damage_percent)
	if breading_pet_damage_percent > 0.0: description += "\n+%s%% damage per equipped Pet (includes self)" % format_number(breading_pet_damage_percent)
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

func get_breading_tag_multiplier() -> float:
	if breading_chili_damage_percent == 0.0 and breading_pet_damage_percent == 0.0: return 1.0
	if not is_instance_valid(Global.player): return 1.0
	var bonus := 0.0
	for equipped: Weapon in Global.player.current_weapons:
		if not is_instance_valid(equipped) or equipped.is_queued_for_deletion(): continue
		if equipped.data.has_tag(Tag.CHILI): bonus += breading_chili_damage_percent
		if equipped.data.has_tag(Tag.PET): bonus += breading_pet_damage_percent
	return 1.0 + bonus / 100.0

func get_breading_burning_damage(base_damage: float, player_stats: UnitStats) -> float:
	var extra := 0.0
	for key in extra_damage_scalings: extra += float(player_stats.get(key)) * float(extra_damage_scalings[key])
	return maxf(0.1, base_damage + extra) * get_breading_tag_multiplier()

## State damage is independent from the weapon's direct hit and its scaling stat.
func get_status_damage_description(player_stats: UnitStats = null) -> String:
	var result := ""
	for effect in on_hit_effects + breading_status_effects:
		if effect == null: continue
		if effect.kind == StatusEffect.Kind.FIRE and not effect.configured_fire_damage: continue
		var amount: float = player_stats.get_effect_damage(effect.damage, effect.damage_scaling) if player_stats else effect.damage
		if effect.kind == StatusEffect.Kind.FIRE: amount = maxf(0.1, amount)
		if player_stats: amount *= status_damage_multiplier({"weapon": self}, player_stats)
		var formula := "%s + %s%% Effects" % [format_number(effect.damage), format_number(effect.damage_scaling * 100.0)]
		var label := "Burning / tick" if effect.kind == StatusEffect.Kind.FIRE else "Electricity"
		result += "\n%s: [color=green]%s[/color] (%s)" % [label, format_number(amount), formula]
		if effect.kind == StatusEffect.Kind.FIRE:
			var interval: float = player_stats.get_fire_interval() if player_stats else StatusEffect.BASE_FIRE_INTERVAL
			var duration: float = player_stats.get_fire_duration(effect.duration) if player_stats else effect.duration
			result += " — every %s s, for %s s" % [format_number(interval), format_number(duration)]
		if effect.chance < 1.0: result += " — %s%% chance" % format_number(effect.chance * 100.0)
	return result
