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
@export var show_projectile_count_in_damage := false
@export var damage_only_on_explosion := false
@export var burning_description_format := ""
@export var damage_label := "Damage"
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

func get_display_cooldown(player_stats: UnitStats = null) -> float:
	var ranged := stats.ranged_settings
	return ranged.burst_interval if ranged and ranged.burst_count > 1 else get_effective_cooldown(player_stats)

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

static func _scaling_component(stat_id: String, coefficient: float) -> String:
	var icon := "damage_ranged"
	match stat_id:
		"melee_damage": icon = "damage_melee"
		"effects": icon = "damage_effects"
		"luck": icon = "luck_die"
	return "%s%% [img width=22 height=22 color=green]res://assets/sprites/UI/%s.svg[/img]" % [format_number(coefficient * 100.0), icon]

func get_damage_description(player_stats: UnitStats = null, multiplier: float = 1.0, for_explosion: bool = false) -> String:
	if damage_only_on_explosion and not for_explosion:
		return "0"
	var components := PackedStringArray()
	var stat_id := get_damage_scaling_stat_id()
	if not stat_id.is_empty():
		components.append(_scaling_component(stat_id, stats.damage_scaling * multiplier))
	if scales_with_effects and stat_id != "effects":
		components.append(_scaling_component("effects", effects_damage_scaling * multiplier))
	for key in extra_damage_scalings:
		components.append(_scaling_component(str(key), float(extra_damage_scalings[key]) * multiplier))
	var damage := format_number(get_effective_damage(player_stats, for_explosion) * multiplier)
	if show_projectile_count_in_damage and stats.ranged_settings:
		damage += "x%d" % stats.ranged_settings.projectile_count
	return "%s (%s)" % [damage, " + ".join(components)] if not components.is_empty() else damage

func get_direct_damage_description(player_stats: UnitStats = null) -> String:
	var ranged := stats.ranged_settings
	return get_damage_description(player_stats, ranged.airbourne_direct_damage_multiplier if ranged and ranged.applies_airbourne else 1.0)

func get_description(player_stats: UnitStats = null) -> String:
	if selection_only: return "Ability not available yet.\nStart without equipment."
	var damage_description := "%s: [color=green]%s[/color]" % [damage_label, get_direct_damage_description(player_stats)]
	var ranged := stats.ranged_settings
	var description := "%s\nCooldown: [color=green]%s s[/color]" % [damage_description, format_number(get_display_cooldown(player_stats))]
	if not has_tag(Tag.CHILI):
		description += "\nRange: [color=green]%s[/color]" % get_range_description(player_stats)
		description += "\nCritical chance: [color=green]%s%%[/color]" % format_number(get_effective_critical_chance(player_stats) * 100.0)
	if has_tag(Tag.RANGED):
		if stats.unlimited_piercing: description += "\nPiercing: [color=green]∞[/color]"
		elif get_effective_piercing(player_stats) > 0: description += "\nPiercing: [color=green]%d[/color]" % get_effective_piercing(player_stats)
		if shows_bounce_count() and get_effective_bounces(player_stats) > 0: description += "\nBounces: [color=green]%d[/color]" % get_effective_bounces(player_stats)
	var status_description := get_status_damage_description(player_stats)
	if not stats.spicy_explosion_settings: description += status_description
	if breading_chili_damage_percent > 0.0: description += "\n+%s%% damage per equipped Chili (includes self)" % format_number(breading_chili_damage_percent)
	if breading_pet_damage_percent > 0.0: description += "\n+%s%% damage per equipped Pet (includes self)" % format_number(breading_pet_damage_percent)
	var attack_text := attack_description
	if "{push}" in attack_text:
		var push := player_stats.get_push_force(stats.knockback) if player_stats else stats.knockback
		attack_text = attack_text.replace("{push}", "[color=green]%s[/color]" % format_number(push))
	if ranged and "{pit_damage}" in attack_text:
		var pit_damage := get_damage_description(player_stats, ranged.pit_damage_multiplier)
		attack_text = attack_text.replace("{pit_damage}", "[color=green]%s[/color]" % pit_damage)
	if ranged and not shows_bounce_count():
		var bounce_chance := ranged.get_plate_bounce_chance(player_stats.luck if player_stats else 0.0)
		var scaling := _scaling_component("luck", ranged.plate_bounce_chance_per_luck * 100.0)
		attack_text = attack_text.replace("{bounce_chance}", "[color=green]%s%% (%s)[/color]" % [format_number(bounce_chance * 100.0), scaling])
	if ranged and "{pin_duration}" in attack_text:
		attack_text = attack_text.replace("{pin_duration}", format_number(ranged.harpoon_pin_duration))
	if ranged and ranged.burst_count > 1 and "{reload_cooldown}" in attack_text:
		var shot_span := (ranged.burst_count - 1) * ranged.burst_interval
		var reload_cooldown := maxf(0.01 if ranged.lock_burst_aim else 0.0, get_effective_cooldown(player_stats) - shot_span)
		attack_text = attack_text.format({"burst_count": ranged.burst_count, "reload_cooldown": format_number(reload_cooldown)})
	if ranged and ("{fuse}" in attack_text or "{explosion_damage}" in attack_text):
		attack_text = attack_text.format({
			"fuse": format_number(ranged.fuse),
			"explosion_damage": "[color=green]%s[/color]" % get_damage_description(player_stats, ranged.explosion_damage_multiplier, true),
		})
	if "{airbourne_damage}" in attack_text and ((ranged and ranged.applies_airbourne) or stats.melee_settings):
		var collision_multiplier := ranged.airbourne_damage_multiplier if ranged and ranged.applies_airbourne else stats.melee_settings.collision_damage_multiplier
		var collision_damage := get_damage_description(player_stats, collision_multiplier)
		attack_text = attack_text.replace("{airbourne_damage}", "[color=green]%s[/color]" % collision_damage)
	var has_ketchup_splatter := ranged != null and stats.projectile_scene != null and stats.projectile_scene.resource_path == "res://scenes/projectiles/projectile_ketchup_capsule.tscn"
	if has_ketchup_splatter:
		attack_text = attack_text.replace("{droplets}", str(ranged.splatter_count))
	if not attack_text.is_empty(): description += "\n" + attack_text
	if stats.spicy_explosion_settings: description += status_description
	if has_ketchup_splatter:
		description += "\nDamage per droplet: [color=green]%s[/color]" % get_damage_description(player_stats, ranged.splatter_damage_multiplier)
	if ranged and stats.projectile_scene and stats.projectile_scene.resource_path == "res://scenes/projectiles/projectile_bomb_corn.tscn":
		var luck := player_stats.luck if player_stats else 0.0
		var bonus_multiplier := status_damage_multiplier({"weapon": self}, player_stats) if player_stats else 1.0
		var blast_ratio := explosion_damage_ratio({"weapon": self}, player_stats) if player_stats else 1.0
		var blast_damage := maxf(0.0, get_effective_damage(player_stats) + ranged.get_corn_explosion_bonus(luck) * bonus_multiplier)
		blast_damage *= ranged.explosion_damage_multiplier * blast_ratio
		description += "\nExplosion chance: [color=green]%s%% (%s)[/color]" % [format_number(ranged.get_corn_explosion_chance(luck) * 100.0), _scaling_component("luck", ranged.corn_chance_per_luck * 100.0)]
		description += "\nExplosion damage: [color=green]%s (%s)[/color]" % [format_number(blast_damage), _scaling_component("luck", ranged.corn_damage_per_luck)]
	var special_color := UITheme.color_hex("negative" if has_tag(Tag.CHILI) else "accent")
	for stat_id in final_stat_modifiers:
		var modifier := float(final_stat_modifiers[stat_id])
		var direct_label: String = {"fire_tick_speed": "Fire tick speed", "slow_strength": "Slow potency", "effect_duration": "Effect duration", "enemy_count": "Enemy spawn rate", "enemy_speed": "Enemy speed"}.get(stat_id, "")
		if not direct_label.is_empty():
			description += "\n[color=%s]%s%s%% %s[/color]" % [
				special_color, "+" if modifier > 0.0 else "", format_number(modifier), direct_label,
			]
			continue
		var stat_name := str(CharacterPassive.STAT_LABELS.get(stat_id, str(stat_id).replace("_", " ").capitalize()))
		if stat_id == "damage_percent": stat_name = "Damage"
		if stat_id == "area_of_effect": stat_name = "AOE"
		description += "\n[color=%s]%s bonuses are %s%% %s.[/color]" % [
			special_color, stat_name, format_number(absf(modifier)), "stronger" if modifier > 0.0 else "weaker",
		]
	if health_drain_per_second > 0.0: description += "\n[color=%s]Health cost: %s HP/s[/color]" % [special_color, format_number(health_drain_per_second)]
	if max_health_drain_percent_per_second > 0.0: description += "\n[color=%s]Health cost: %s%% max HP/s[/color]" % [special_color, format_number(max_health_drain_percent_per_second)]
	return description

func get_effective_piercing(player_stats: UnitStats = null) -> int:
	return maxi(0, stats.piercing + (player_stats.piercing if player_stats else 0))

func shows_bounce_count() -> bool:
	return "{bounce_chance}" not in attack_description

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
	var burning_description := ""
	var display_effects := on_hit_effects + breading_status_effects
	if not burning_description_format.is_empty() and stats.spicy_explosion_settings and stats.spicy_explosion_settings.burn_duration > 0.0:
		var burn := StatusEffect.new()
		burn.kind = StatusEffect.Kind.FIRE
		burn.duration = stats.spicy_explosion_settings.burn_duration
		display_effects.append(burn)
	for effect in display_effects:
		if effect == null: continue
		var uses_base_burning := effect.kind == StatusEffect.Kind.FIRE and not effect.configured_fire_damage
		if uses_base_burning and burning_description_format.is_empty(): continue
		var amount: float = player_stats.get_effect_damage(effect.damage, effect.damage_scaling) if player_stats else effect.damage
		if effect.kind == StatusEffect.Kind.FIRE: amount = maxf(0.1, amount)
		if player_stats: amount *= status_damage_multiplier({"weapon": self}, player_stats)
		var formula := "%s + %s" % [format_number(effect.damage), _scaling_component("effects", effect.damage_scaling)]
		if uses_base_burning:
			amount = player_stats.get_burning_damage() * player_stats.get_damage_percent_multiplier(has_tag(Tag.CHILI), has_tag(Tag.EXPLOSIVE)) if player_stats else 0.1
			formula = _scaling_component("effects", UnitStats.BURNING_EFFECTS_SCALING * FireContacts.burn_tick_batch)
		if effect.kind == StatusEffect.Kind.FIRE:
			amount *= FireContacts.burn_tick_batch
			if not uses_base_burning:
				formula = _scaling_component("effects", effect.damage_scaling * FireContacts.burn_tick_batch)
		var label := "Burning / tick" if effect.kind == StatusEffect.Kind.FIRE else "Electricity"
		var damage_text := "[color=green]%s[/color] (%s)" % [format_number(amount), formula]
		var chance_text := " — %s%% chance" % format_number(effect.chance * 100.0) if effect.chance < 1.0 else ""
		if effect.kind == StatusEffect.Kind.FIRE:
			var interval: float = player_stats.get_fire_interval() if player_stats else StatusEffect.BASE_FIRE_INTERVAL
			interval *= FireContacts.burn_tick_batch
			var duration: float = player_stats.get_fire_duration(effect.duration) if player_stats else effect.duration
			if burning_description_format.is_empty():
				result += "\n%s: %s — every %s s, for %s s" % [label, damage_text, format_number(interval), format_number(duration)]
			else:
				burning_description += "\n" + burning_description_format.format({
					"damage": damage_text, "interval": format_number(interval), "duration": format_number(duration),
				}) + chance_text
				continue
		else:
			result += "\n%s: %s" % [label, damage_text]
		result += chance_text
	return result + burning_description
