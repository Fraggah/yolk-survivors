extends Node
## Run-local ownership and item hooks. Never mutate catalogue resources.
var player: Player
var counts: Dictionary = {}
var owned_records: Array[Dictionary] = []
var golden_yolks := 0
var breading_charges := 0
var shell_uses := 0
var _oil_interval_total := 0.0
var _oil_duration_total := 0.0
var shell_invulnerability := 0.0
var extra_shell_used := false
var kills := 0
var force_horde := false
var alcohol_fire: StatusEffect
var fire_spread_chance := 0.0
var fire_spread_radius := 80.0
var yolk_heal_chance := 0.0
var yolk_heal_amount := 0.1
var yolk_magnet_chance := 0.0
## Stress-test override; negative means ordinary item-driven probability.
var debug_yolk_magnet_chance := -1.0
var controlled_damage_percent := 0.0
var airbourne_collision_damage_percent := 0.0
var airbourne_explosion_damage_percent := 0.0
var airbourne_explosion_radius := 60.0
var burning_regen_total := 0.0
var flambe_damage_per_enemy := 0.0
var level_regen_bonus := 0.0
var electric_slow_strength := 0.0
var electric_slow_duration := 0.0
var mushroom_runtime: Node
var last_bite_active := false
var last_bite_dash_multiplier := 1.0
var liquidation_data: ItemPassive
const PRIMARY = ["health", "hp_regen", "life_steal", "damage_percent", "melee_damage", "ranged_damage", "effects", "weapon_range", "attack_speed", "critical_chance", "armor", "block_chance", "speed", "luck", "harvesting"]
var slip_left := 0.0
var _slip_bonus := 0.0

func count(key: String) -> int:
	return int(counts.get(key, 0))

func refresh_last_bite(_current: float = 0.0, _maximum: float = 0.0) -> void:
	var health := player.health_component
	var push_percent := 0.0
	var dash_reduction := 0.0
	last_bite_active = false
	for record in owned_records:
		var item: ItemPassive = record.item
		if item.effect_key != "last_bite": continue
		if health.current_health > 0.0 and health.current_health < health.max_health * item.last_bite_health_threshold:
			last_bite_active = true
			push_percent += item.last_bite_push_percent
			dash_reduction += item.last_bite_dash_reduction
	player.stats.conditional_push_multiplier = maxf(0.0, 1.0 + push_percent / 100.0)
	last_bite_dash_multiplier = maxf(0.0, 1.0 - dash_reduction)
	player.refresh_dash_cooldown()

func acquire(item: ItemPassive, previous_gains: Dictionary = {}) -> void:
	if not item.available_for(player): return
	var key: String = item.effect_key
	var conversions_before := player.stats.character_passives.size()
	counts[key] = count(key) + 1
	match key:
		"ayahuasca":
			var result: Dictionary = load("res://resources/items/ayahuasca.gd").apply(player, item)
			var arena = get_tree().current_scene
			if arena is Arena: arena.shop_panel.call_deferred("show_ayahuasca_result", result.get("message", ""))
		"golden_yolk": golden_yolks += 1
		"breading": breading_charges += 1
		"flambe": flambe_damage_per_enemy += item.flambe_damage_per_enemy
		"liquidation":
			liquidation_data = item
		"fridge_magnet":
			electric_slow_strength = maxf(electric_slow_strength, item.electric_slow_strength)
			electric_slow_duration = maxf(electric_slow_duration, item.electric_slow_duration)
		"aged_egg":
			level_regen_bonus += item.regen_per_level
		"thermal_glove":
			burning_regen_total += item.burning_regen_bonus
		"fierce_saute":
			airbourne_explosion_damage_percent += item.airbourne_explosion_damage_percent
			airbourne_explosion_radius = item.effect_radius
		"pancake":
			airbourne_collision_damage_percent += item.airbourne_collision_damage_percent
		"slow_cooking":
			controlled_damage_percent += item.controlled_damage_percent
		"oil_bath":
			player.stats.fire_interval_reduction += item.fire_interval_reduction
			player.stats.fire_duration_reduction += item.fire_duration_reduction
		"yellow_magnet":
			yolk_magnet_chance = minf(1.0, yolk_magnet_chance + item.proc_chance)
		"vitamin_b":
			yolk_heal_chance = minf(1.0, yolk_heal_chance + item.proc_chance)
			yolk_heal_amount = item.heal_amount
		"hot_splash":
			fire_spread_chance = minf(1.0, fire_spread_chance + item.proc_chance)
			fire_spread_radius = item.effect_radius
		"alcohol":
			if not item.on_hit_effects.is_empty():
				var config: StatusEffect = item.on_hit_effects[0]
				if alcohol_fire == null:
					alcohol_fire = config.duplicate()
					alcohol_fire.chance = 0.0
					player.stats.attack_effects.append(alcohol_fire)
				alcohol_fire.chance = minf(1.0, alcohol_fire.chance + config.chance)
		"chocolate_coin":
			var arena = player.get_tree().current_scene
			if arena is Arena: arena.shop_panel.resolve_chocolate_coin()
		"energy_shake":
			player.stats.energy_shakes += 1
			player.stats.apply_stat_change("speed", 0)
		"horde": force_horde = true
		"refrito": player.stats.apply_stat_change("bounces", 1)
		"iron_apron":
			var apron_conversion := CharacterPassive.new()
			apron_conversion.source_stat = "armor"
			apron_conversion.target_stat = "health"
			apron_conversion.bonus_amount = 2.0
			player.stats.character_passives.append(apron_conversion)
			player.stats.apply_stat_change("health", 0)
		"grocery": redistribute(50, 40)
		"stage_pan", "stage_pot", "stage_oven", "stage_wok":
			var arena = get_tree().current_scene
			if arena is Arena:
				var stage_ids := {"stage_pan":"nonstick_pan", "stage_pot":"cooking_pot", "stage_oven":"oven_tray", "stage_wok":"deep_wok"}
				var stage = load("res://resources/environments/stages/%s.tres" % stage_ids[key])
				var wave: int = arena.spawner.wave_index + 1
				arena.environment_controller.selected_stages[wave] = stage
				arena.shop_panel.set_next_stage(stage, wave)
		"reduction":
			player.stats.infernal_reduction = true
			player.stats.apply_stat_change("effects", 0)
	if not is_consumable(item):
		var deltas: Dictionary = {}
		for stat_id in previous_gains:
			var delta := float(player.stats._stat_gains[stat_id]) - float(previous_gains[stat_id])
			if not is_zero_approx(delta): deltas[stat_id] = delta
		var conversion: CharacterPassive = null
		if player.stats.character_passives.size() > conversions_before: conversion = player.stats.character_passives.back()
		owned_records.append({"item": item, "deltas": deltas, "conversion": conversion})
	if key == "oil_bath":
		_oil_interval_total += item.fire_interval_reduction
		_oil_duration_total += item.fire_duration_reduction
	player.refresh_equipment_modifiers()
	refresh_burning_regen()
	refresh_flambe_damage()
	player.health_component.max_health = maxf(1.0, player.stats.health)
	player.health_component.current_health = minf(player.health_component.current_health, player.health_component.max_health)
	player.health_component.on_health_changed.emit(player.health_component.current_health, player.health_component.max_health)

func begin_wave() -> void:
	if not is_instance_valid(mushroom_runtime):
		mushroom_runtime = load("res://resources/items/unknown_mushroom.gd").new()
		mushroom_runtime.manager = self
		add_child(mushroom_runtime)
	mushroom_runtime.reset()
	extra_shell_used = false
	shell_uses = 0
	shell_invulnerability = 0.0
	_clear_slip()
	player.stats.set_temporary_stat_bonus("thermal_glove", "hp_regen", 0.0)

func on_level_gained() -> void:
	if level_regen_bonus > 0.0: player.stats.apply_stat_change("hp_regen", level_regen_bonus)

func refresh_burning_regen() -> void:
	var bonus := burning_regen_total if player.has_status(Unit.State.BURNING) else 0.0
	player.stats.set_temporary_stat_bonus("thermal_glove", "hp_regen", bonus)

func on_yolks_collected(amount: int) -> void:
	if Global.game_paused or amount <= 0 or yolk_heal_chance <= 0.0: return
	var health := player.health_component
	if health.current_health <= 0.0 or health.current_health >= health.max_health: return
	var successes := 0
	for yolk in amount:
		if Global.get_chance_succes(yolk_heal_chance): successes += 1
	if successes == 0: return
	var before := health.current_health
	health.heal(yolk_heal_amount * successes)
	var healed := health.current_health - before
	if healed > 0.0: Global.on_create_heal_text.emit(player, healed)

func should_attract_spawned_yolk() -> bool:
	var chance := debug_yolk_magnet_chance if debug_yolk_magnet_chance>=0 else yolk_magnet_chance
	return chance > 0.0 and player.health_component.current_health > 0.0 and Global.get_chance_succes(chance)

func on_block() -> void:
	if count("slippery_shell") == 0: return
	if slip_left <= 0.0:
		_slip_bonus = player.stats.unmodified_stat("speed") * 0.2 * maximum_power("slippery_shell")
		player.stats.apply_stat_change("speed", _slip_bonus)
	slip_left = 3.0 * maximum_power("slippery_shell")

func _clear_slip() -> void:
	if _slip_bonus != 0.0: player.stats.apply_stat_change("speed", -_slip_bonus)
	_slip_bonus = 0.0
	slip_left = 0.0

func _process(delta: float) -> void:
	if burning_regen_total > 0.0: refresh_burning_regen()
	shell_invulnerability = maxf(0.0, shell_invulnerability - delta)
	if slip_left > 0.0:
		slip_left -= delta
		if slip_left <= 0.0: _clear_slip()

func prevent_lethal() -> bool:
	if shell_uses >= floori(maximum_power("extra_shell") + 0.00001): return false
	shell_uses += 1
	extra_shell_used = true
	shell_invulnerability = 1.0
	player.hit_invulnerability_left = maxf(player.hit_invulnerability_left, 1.0)
	return true

func on_status_applied(kind: int, was_active: bool) -> void:
	# A refresh of an existing state is not a new self-infliction.
	if was_active: return
	if kind == StatusEffect.Kind.FIRE and count("reheated") > 0:
		player.stats.apply_stat_change("attack_speed", 5.0 * power("reheated"))
	if kind == StatusEffect.Kind.ELECTRICITY and count("overload") > 0:
		player.stats.apply_stat_change("damage_percent", 5.0 * power("overload"))

func redistribute(gain: float, loss: float) -> void:
	var chosen: String = PRIMARY.pick_random()
	player.stats.apply_stat_change(chosen, gain)
	var others: Array = PRIMARY.filter(func(stat): return stat != chosen)
	for point in floori(loss):
		player.stats.apply_stat_change(others.pick_random(), -1.0)
	if loss > floorf(loss): player.stats.apply_stat_change(others.pick_random(), -(loss - floorf(loss)))

func finish_wave() -> void:
	if is_instance_valid(mushroom_runtime): mushroom_runtime.reset()
	for record in owned_records:
		if record.item.effect_key == "lunchbox": redistribute(5 * record.item.golden_multiplier, 3 * record.item.golden_penalty_multiplier)

func enemy_killed(enemy: Enemy) -> void:
	if not enemy.last_hit_grants_rewards or enemy.get_meta("stage_hazard", false) or count("printer") == 0: return
	kills += 1
	if kills % 100 != 0 or count("printer") == 0: return
	var candidates: Array = []
	for item in load("res://resources/items/passives/catalogue.gd").items():
		if item.item_tier == Global.UpgradeTier.COMMON and count(item.effect_key) > 0: candidates.append(item)
	if candidates.is_empty(): return
	for copy in discrete_power("printer"):
		var item: ItemPassive = candidates.pick_random()
		var arena = get_tree().current_scene
		if arena is Arena: arena.shop_panel._on_item_purchased(item)


static func is_consumable(item: ItemPassive) -> bool:
	return item.effect_key in ["ayahuasca", "golden_yolk", "breading", "chocolate_coin", "stage_pan", "stage_pot", "stage_oven", "stage_wok", "grocery", "horde"]

func power(key: String) -> float:
	var total := 0.0
	for record in owned_records:
		if record.item.effect_key == key: total += record.item.golden_multiplier
	return total

func discrete_power(key: String) -> int:
	var total := 0
	for record in owned_records:
		if record.item.effect_key == key:
			total += maxi(1, floori(record.item.golden_multiplier + 0.00001))
	return total

func weapon_slot_bonus() -> int:
	var total := 0
	for record in owned_records:
		if record.item.effect_key == "extra_slot": total += 2 if record.item.golden_perfect else 1
	return total

func find_owned_record(item: ItemPassive) -> Dictionary:
	for record in owned_records:
		if record.item == item: return record
	return {}

func replace_owned(record: Dictionary, replacement: ItemPassive) -> void:
	var old: ItemPassive = record.item
	var adjustments: Dictionary = {}
	var new_deltas: Dictionary = {}
	var gain_factor := replacement.golden_multiplier / old.golden_multiplier if replacement else 0.0
	var loss_factor := replacement.golden_penalty_multiplier / old.golden_penalty_multiplier if replacement and old.golden_penalty_multiplier > 0.0 else 0.0
	for stat_id in record.deltas:
		var previous := float(record.deltas[stat_id])
		var updated := previous * (gain_factor if previous > 0.0 else loss_factor)
		# Bounces and other integer stats gain whole units only.
		if stat_id in ["bounces", "piercing"]: updated = floorf(updated + 0.00001)
		new_deltas[stat_id] = updated
		adjustments[stat_id] = updated - previous
	player.stats.adjust_owned_item_gains(adjustments)
	for effect in old.on_hit_effects:
		player.stats.attack_effects.erase(effect)
	if replacement:
		record.item = replacement
		record.deltas = new_deltas
		if old.effect_key != "alcohol": player.stats.attack_effects.append_array(replacement.on_hit_effects)
		if record.conversion: record.conversion.bonus_amount = 2.0 * replacement.golden_multiplier
	else:
		counts[old.effect_key] = maxi(0, count(old.effect_key) - 1)
		if record.conversion: player.stats.character_passives.erase(record.conversion)
		owned_records.erase(record)
	_rebuild_continuous_effects()

func _rebuild_continuous_effects() -> void:
	fire_spread_chance = 0.0
	fire_spread_radius = 0.0
	yolk_heal_chance = 0.0
	yolk_heal_amount = 0.0
	yolk_magnet_chance = 0.0
	controlled_damage_percent = 0.0
	airbourne_collision_damage_percent = 0.0
	airbourne_explosion_damage_percent = 0.0
	airbourne_explosion_radius = 0.0
	burning_regen_total = 0.0
	flambe_damage_per_enemy = 0.0
	level_regen_bonus = 0.0
	electric_slow_strength = 0.0
	electric_slow_duration = 0.0
	liquidation_data = null
	var interval := 0.0
	var duration := 0.0
	var alcohol_chance := 0.0
	for record in owned_records:
		var item = record.item
		match item.effect_key:
			"flambe": flambe_damage_per_enemy += item.flambe_damage_per_enemy
			"liquidation": liquidation_data = item
			"fridge_magnet":
				electric_slow_strength = maxf(electric_slow_strength, item.electric_slow_strength)
				electric_slow_duration = maxf(electric_slow_duration, item.electric_slow_duration)
			"aged_egg": level_regen_bonus += item.regen_per_level
			"thermal_glove": burning_regen_total += item.burning_regen_bonus
			"fierce_saute":
				airbourne_explosion_damage_percent += item.airbourne_explosion_damage_percent
				airbourne_explosion_radius = maxf(airbourne_explosion_radius, item.effect_radius)
			"pancake": airbourne_collision_damage_percent += item.airbourne_collision_damage_percent
			"slow_cooking": controlled_damage_percent += item.controlled_damage_percent
			"oil_bath":
				interval += item.fire_interval_reduction
				duration += item.fire_duration_reduction
			"yellow_magnet": yolk_magnet_chance += item.proc_chance
			"vitamin_b":
				yolk_heal_chance += item.proc_chance
				yolk_heal_amount = maxf(yolk_heal_amount, item.heal_amount)
			"hot_splash":
				fire_spread_chance += item.proc_chance
				fire_spread_radius = maxf(fire_spread_radius, item.effect_radius)
			"alcohol":
				if not item.on_hit_effects.is_empty(): alcohol_chance += item.on_hit_effects[0].chance
	if alcohol_fire:
		alcohol_fire.chance = minf(1.0, alcohol_chance)
		if alcohol_chance <= 0.0:
			player.stats.attack_effects.erase(alcohol_fire)
			alcohol_fire = null
	player.stats.fire_interval_reduction += interval - _oil_interval_total
	player.stats.fire_duration_reduction += duration - _oil_duration_total
	_oil_interval_total = interval
	_oil_duration_total = duration
	player.stats.energy_shakes = power("energy_shake")
	player.stats.infernal_reduction = count("reduction") > 0
	player.stats.infernal_reduction_multiplier = maxf(1.0, maximum_power("reduction"))
	player.stats.adjust_owned_item_gains({})
	player.refresh_equipment_modifiers()
	refresh_burning_regen()
	refresh_flambe_damage()

func penalty_power(key: String) -> float:
	var total := 0.0
	for record in owned_records:
		if record.item.effect_key == key: total += record.item.golden_penalty_multiplier
	return total

func maximum_power(key: String) -> float:
	var highest := 0.0
	for record in owned_records:
		if record.item.effect_key == key: highest = maxf(highest, record.item.golden_multiplier)
	return highest

func get_tortilla_relaunch() -> Dictionary:
	var chance := 0.0
	var speed_multiplier := 0.0
	var duration_multiplier := 0.0
	var maximum := 0
	for record in owned_records:
		var item = record.item
		if item.effect_key != "tortilla_flip": continue
		chance += item.proc_chance
		speed_multiplier = maxf(speed_multiplier, item.relaunch_speed_multiplier)
		duration_multiplier = maxf(duration_multiplier, item.relaunch_duration_multiplier)
		maximum = maxi(maximum, item.relaunch_maximum)
	return {"chance": minf(1.0, chance), "speed_multiplier": speed_multiplier, "duration_multiplier": duration_multiplier, "maximum": maximum}

func refresh_flambe_damage() -> void:
	var amount: float = flambe_damage_per_enemy * load("res://effects/status_controller.gd").burning_enemy_count
	player.stats.set_temporary_stat_bonus("flambe", "damage_percent", amount)
