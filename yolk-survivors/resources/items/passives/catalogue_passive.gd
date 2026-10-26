extends ItemPassive
## Only fully specified effects enter the shop. Resource values remain editable.
@export var catalogue_id := 0
@export_multiline var description := ""
@export var effect_key := ""
@export var ready_for_shop := false
@export_multiline var pending_reason := ""
@export_range(0.0, 1.0, 0.001) var proc_chance := 0.0
@export_range(0.0, 1000.0, 1.0) var effect_radius := 80.0
@export_range(0.0, 100.0, 0.01) var heal_amount := 0.1
## Zero means unlimited copies.
@export_range(0, 99, 1) var max_copies := 0
@export_range(0.0, 1.0, 0.01) var fire_interval_reduction := 0.0
@export_range(0.0, 10.0, 0.01) var fire_duration_reduction := 0.0
@export_range(0.0, 1000.0, 1.0) var controlled_damage_percent := 0.0
@export_range(0.0, 1000.0, 1.0) var airbourne_collision_damage_percent := 0.0
@export_range(0.0, 1000.0, 1.0) var airbourne_explosion_damage_percent := 0.0
@export_range(0.0, 100.0, 0.1) var burning_regen_bonus := 0.0
@export_range(0.0, 100.0, 0.1) var regen_per_level := 0.0
@export_range(0.0, 1.0, 0.01) var electric_slow_strength := 0.0
@export_range(0.0, 30.0, 0.1) var electric_slow_duration := 0.0
@export_range(0, 90, 1) var minimum_discount_percent := 10
@export_range(0, 90, 1) var maximum_discount_percent := 90
@export_range(0.0, 1.0, 0.0001) var two_for_one_chance := 0.02
## Relative weights among percentage offers, after the separate 2x1 roll.
@export var discount_band_weights := PackedFloat32Array([50.0, 28.0, 14.0, 6.0])
## Break, +10%, +25%, +50%, perfect.
@export var golden_outcome_weights := PackedFloat32Array([25.0, 40.0, 23.0, 10.0, 2.0])
@export var flambe_damage_per_enemy := 10.0
@export var ayahuasca_outcome_weights := PackedFloat32Array([25.0, 25.0, 25.0, 25.0])
@export_range(1, 100, 1) var ayahuasca_levels := 10
@export_group("Hongo desconocido")
@export var mushroom_interval := 5.0
@export var mushroom_explosion_radius := 220.0
@export var mushroom_effects_scaling := 1.0
@export var mushroom_health_scaling := 0.1
@export var mushroom_damage_bonus := 100.0
@export var mushroom_speed_percent := 50.0
@export var mushroom_attack_speed_bonus := 100.0
@export var mushroom_buff_duration := 4.0
@export var mushroom_health_loss := 0.5
@export var mushroom_burn_duration := 4.0
@export var mushroom_burn_tick_health := 0.01
@export var mushroom_shock_health := 0.05
@export var mushroom_heal_health := 0.1
@export_group("Último bocado")
@export var last_bite_health_threshold := 0.25
@export var last_bite_push_percent := 50.0
@export var last_bite_dash_reduction := 0.5
@export_group("Giro de tortilla")
@export_range(0.0, 1.0, 0.01) var relaunch_speed_multiplier := 0.75
@export_range(0.0, 1.0, 0.01) var relaunch_duration_multiplier := 0.5
@export_range(0, 20, 1) var relaunch_maximum := 2
@export_group("Rebozado")
@export var breading_extra_scaling := 0.25
@export var breading_chili_damage_percent := 10.0
@export var breading_pet_damage_percent := 10.0
@export_range(0.0, 1.0, 0.01) var breading_proc_chance := 0.1
@export var breading_explosion_radius := 40.0
@export var breading_explosion_damage_ratio := 0.25
@export_range(0.0, 1.0, 0.01) var breading_slow_strength := 0.2
@export var breading_slow_duration := 1.0
@export_group("")

func get_shop_price(completed_wave: int) -> int:
	return 1 if effect_key == "chocolate_coin" else super.get_shop_price(completed_wave)

func get_description() -> String:
	return description

func apply_passive_values(target: Player = null) -> void:
	if not target: target=Global.player
	if is_instance_valid(target) and available_for(target):
		target.stats.initialize_character_passives()
		var previous_gains: Dictionary = target.stats._stat_gains.duplicate()
		# Catalogue stat items use the same gain/penalty pipeline as upgrades.
		if effect_key == "alcohol":
			apply_stat_values(target)
		else: super.apply_passive_values(target)
		target.passive_items.acquire(self, previous_gains)

func available_for(player: Player) -> bool:
	if max_copies > 0 and is_instance_valid(player.passive_items) and player.passive_items.count(effect_key) >= max_copies: return false
	return ready_for_shop and (effect_key != "extra_slot" or player.passive_items.count("extra_slot") < 3)

func roll_sale_discount() -> int:
	var minimum := clampi(minimum_discount_percent, 1, 90)
	var maximum := clampi(maximum_discount_percent, minimum, 90)
	var ranges := [Vector2i(10, 30), Vector2i(31, 50), Vector2i(51, 70), Vector2i(71, 90)]
	var total := 0.0
	for index in ranges.size():
		if maxi(minimum, ranges[index].x) > mini(maximum, ranges[index].y): continue
		if index < discount_band_weights.size(): total += maxf(0.0, discount_band_weights[index])
	if total <= 0: return randi_range(minimum, maximum)
	var roll := randf() * total
	for index in ranges.size():
		var low := maxi(minimum, ranges[index].x)
		var high := mini(maximum, ranges[index].y)
		if low > high or index >= discount_band_weights.size(): continue
		var weight := maxf(0.0, discount_band_weights[index])
		if weight <= 0: continue
		roll -= weight
		if roll <= 0: return randi_range(low, high)
	return minimum
