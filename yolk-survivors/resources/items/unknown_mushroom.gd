extends Node
## Combat time only. No timer at the exact end of a wave.
var manager: Node
var elapsed := 0.0
var next_activation := 5.0
var buffs: Dictionary = {}
var activation_count := 0

func configuration() -> ItemPassive:
	for record in manager.owned_records:
		if record.item.effect_key == "unknown_mushroom": return record.item
	return null

func reset() -> void:
	for stat_id in buffs: manager.player.stats.set_temporary_stat_bonus("mushroom_" + stat_id, stat_id, 0.0)
	buffs.clear()
	elapsed = 0.0
	activation_count = 0
	var item := configuration()
	next_activation = maxf(0.1, item.mushroom_interval) if item else 5.0

func _process(delta: float) -> void:
	var arena = get_tree().current_scene
	if Global.game_paused or not arena is Arena or not arena.wave_active: return
	if manager.player.health_component.current_health <= 0.0: return
	advance(delta, arena.spawner.wave_timer.wait_time)

func advance(delta: float, wave_duration: float) -> void:
	var item := configuration()
	if item == null:
		reset()
		return
	# Split long frames at activation boundaries so buffs retain their full duration.
	var destination := minf(elapsed + delta, wave_duration)
	while next_activation <= destination and next_activation < wave_duration:
		_age_buffs(maxf(0.0, next_activation - elapsed))
		elapsed = next_activation
		trigger(item)
		next_activation += maxf(0.1, item.mushroom_interval)
	_age_buffs(maxf(0.0, destination - elapsed))
	elapsed = destination

func _age_buffs(delta: float) -> void:
	for stat_id in buffs.keys():
		buffs[stat_id] -= delta
		if buffs[stat_id] <= 0.00001:
			manager.player.stats.set_temporary_stat_bonus("mushroom_" + stat_id, stat_id, 0.0)
			buffs.erase(stat_id)

func trigger(item: ItemPassive, outcome: int = -1) -> int:
	if outcome < 0: outcome = randi_range(0, 8)
	var player: Player = manager.player
	var health := player.health_component
	if health.current_health <= 0.0: return -1
	activation_count += 1
	match outcome:
		0:
			var template := HitboxComponent.new()
			template.setup(maxf(0.0, player.stats.effects * item.mushroom_effects_scaling + health.max_health * item.mushroom_health_scaling), false, 0.0, player)
			template.base_damage *= player.stats.get_damage_percent_multiplier(false, true)
			template.damage = template.base_damage
			template.explosive_bonus_applied = true
			template.status_effects.clear()
			template.breading_suppressed = true
			var settings := RangedSettings.new()
			settings.explosion_radius = item.mushroom_explosion_radius
			settings.explosion_damage_multiplier = 1.0
			settings.explosion_visual_duration = 0.22
			settings.explosion_color = Color("b45570")
			var blast = load("res://scenes/projectiles/ranged_area_effect.gd").new()
			get_tree().current_scene.add_child(blast)
			blast.global_position = player.global_position
			blast.setup(template, settings, false)
			template.free()
		1, 2, 3:
			var stat_id: String = ["damage_percent", "speed", "attack_speed"][outcome - 1]
			# Remove this item's previous speed bonus before taking the snapshot.
			player.stats.set_temporary_stat_bonus("mushroom_" + stat_id, stat_id, 0.0)
			var bonus: float = item.mushroom_damage_bonus if outcome == 1 else item.mushroom_attack_speed_bonus
			if outcome == 2: bonus = maxf(0.0, 100.0 + player.stats.unmodified_stat("speed")) * item.mushroom_speed_percent / 100.0
			player.stats.set_temporary_stat_bonus("mushroom_" + stat_id, stat_id, bonus)
			buffs[stat_id] = item.mushroom_buff_duration
		4:
			health.take_damage(health.current_health * clampf(item.mushroom_health_loss * item.golden_penalty_multiplier, 0.0, 0.999999))
		5, 6:
			# No attacking Unit source: player Effects/fire modifiers must not amplify self damage.
			var template := HitboxComponent.new()
			template.setup(0.0, false, 0.0, null)
			var status := StatusEffect.new()
			status.kind = StatusEffect.Kind.FIRE if outcome == 5 else StatusEffect.Kind.ELECTRICITY
			status.duration = (item.mushroom_burn_duration if outcome == 5 else 1.0) * item.golden_penalty_multiplier
			status.damage = health.max_health * (item.mushroom_burn_tick_health if outcome == 5 else item.mushroom_shock_health) * item.golden_penalty_multiplier
			status.chain_radius = 0.0
			status.maximum_chain_targets = 0
			status.color = Color("ff7235") if outcome == 5 else Color("63dcff")
			status.set_meta("stack_id", "unknown_mushroom")
			if status.duration > 0.0:
				load("res://effects/status_controller.gd").apply_effect(player, status, template, false)
			template.free()
		7, 8:
			var before := health.current_health
			health.heal(health.max_health * item.mushroom_heal_health if outcome == 7 else health.max_health)
			if health.current_health > before: Global.on_create_heal_text.emit(player, health.current_health - before)
	return outcome
