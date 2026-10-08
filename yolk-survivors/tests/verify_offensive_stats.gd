extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	var global = root.get_node("Global")
	var stats = load("res://resources/unit_stats.gd").new()
	var ranged = load("res://resources/items/weapons/range/hydrant/item_hydrant_1.tres").duplicate()
	ranged.stats = ranged.stats.duplicate()
	ranged.stats.damage = 10.0
	ranged.stats.damage_scaling = 0.5
	ranged.stats.cooldown = 0.8
	stats.ranged_damage = 8.0
	stats.melee_damage = 100.0
	stats.damage_percent = 25.0
	assert(is_equal_approx(ranged.get_effective_damage(stats), 17.5), "Typed scaling and percent order")
	var melee = ranged.duplicate()
	melee.type = 0
	assert(is_equal_approx(melee.get_effective_damage(stats), 75.0), "Melee uses only melee bonus")
	stats.damage_percent = -200.0
	assert(ranged.get_effective_damage(stats) == 1.0, "Minimum damage")
	for pair in [[0.0, 0.8], [50.0, 0.8 / 1.5], [100.0, 0.4], [-50.0, 1.2], [-100.0, 1.6], [10000.0, 0.05]]:
		stats.attack_speed = pair[0]
		assert(is_equal_approx(ranged.get_effective_cooldown(stats), pair[1]), "Cooldown or minimum mismatch")
	global.game_paused = true
	global.main_player_selected = load("res://resources/units/players/player_well_rounded.tres")
	var player = global.get_selected_player()
	root.add_child(player)
	player.set_process(false)
	player.set_physics_process(false)
	var panel = load("res://scenes/ui/upgrades/upgrade_panel.tscn").instantiate()
	root.add_child(panel)
	var new_offers := 0
	for offer in panel.upgrades:
		if offer.stat_id in ["damage_percent", "melee_damage", "ranged_damage", "attack_speed"]:
			var before: float = player.stats.get(offer.stat_id)
			offer.apply_upgrade()
			assert(player.stats.get(offer.stat_id) == before + offer.value)
			assert(offer.description == "+%s%s" % [str(int(offer.value)), "%" if offer.stat_id in ["damage_percent", "attack_speed"] else ""])
			new_offers += 1
	assert(new_offers == 18, "All offensive upgrade tiers in the real offer pool")
	for passive_name in ["ball", "rage"]:
		var passive = load("res://resources/items/passives/data/passive_item_%s.tres" % passive_name)
		var before_damage: float = player.stats.damage_percent
		passive.apply_passive_values()
		assert(player.stats.damage_percent == before_damage + passive.add_value)
		assert(passive.get_description().contains("% Damage"))
	player.stats.damage_percent = 25.0
	player.stats.melee_damage = 8.0
	player.stats.ranged_damage = 8.0
	player.stats.attack_speed = 100.0
	var count := 0
	for kind in ["melee", "range"]:
		var parent_dir = DirAccess.open("res://resources/items/weapons/" + kind)
		for folder in parent_dir.get_directories():
			var directory = DirAccess.open("res://resources/items/weapons/" + kind + "/" + folder)
			var previous_dps := 0.0
			for file in directory.get_files():
				if not file.begins_with("item_") or not file.ends_with(".tres"): continue
				var item = load("res://resources/items/weapons/" + kind + "/" + folder + "/" + file)
				var dps: float = item.get_effective_damage(player.stats) / item.get_effective_cooldown(player.stats)
				assert(dps >= previous_dps, "Tier must not lower DPS: " + folder)
				previous_dps = dps
				var weapon = item.scene.instantiate()
				player.add_child(weapon)
				weapon.setup_weapon(item)
				weapon.set_process(false)
				weapon.data = item.duplicate()
				weapon.data.stats = item.stats.duplicate()
				weapon.data.stats.crit_chance = 0.0
				var behavior = weapon.get_node("WeaponBehaviour")
				assert(is_equal_approx(behavior.get_damage(), item.get_effective_damage(player.stats)))
				weapon.data.stats.crit_chance = 1.0
				assert(is_equal_approx(behavior.get_damage(), item.get_effective_damage(player.stats) * item.stats.crit_damage))
				weapon.data.stats.crit_chance = 0.0
				behavior.get_damage()
				assert(not behavior.critical, "Crit resets per attack")
				var animation: float = item.stats.recoil_duration * 2.0 if kind == "range" else item.stats.recoil_duration + item.stats.attack_duration + item.stats.back_duration
				assert(animation * weapon.get_animation_time_scale(animation) < weapon.get_effective_cooldown())
				weapon.use_weapon()
				assert(is_equal_approx(weapon.cooldown_timer.wait_time, item.get_effective_cooldown(player.stats)))
				assert(not weapon.can_use_weapon(), "No overlapping attacks")
				weapon.queue_free()
				count += 1
	assert(count == 40)
	# Verify sustained attacks finish their animation under a capped, fast cooldown.
	var enemy = load("res://scenes/units/enemies/enemy_chaser.tscn").instantiate()
	root.add_child(enemy)
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.position = Vector2(1000, 1000)
	for item_path in ["res://resources/items/weapons/melee/blender/item_blender_1.tres", "res://resources/items/weapons/range/hydrant/item_hydrant_1.tres"]:
		var item = load(item_path)
		var weapon = item.scene.instantiate()
		player.add_child(weapon)
		weapon.setup_weapon(item)
		weapon.targets.append(enemy)
		player.stats.attack_speed = 1000.0
		var attacks := {"count": 0}
		weapon.cooldown_timer.timeout.connect(func(): attacks.count += 1)
		global.game_paused = false
		await create_timer(1.2).timeout
		global.game_paused = true
		assert(attacks.count >= 12, "Animation limits sustained fast attacks: " + item_path)
		await create_timer(0.1).timeout
		assert(not weapon.is_attacking)
		assert(weapon.sprite_2d.position.is_equal_approx(weapon.atk_start_pos))
		weapon.queue_free()
		await process_frame
	enemy.queue_free()
	for node in root.get_children():
		if node.has_method("setup_projectile"): node.queue_free()
	panel.queue_free()
	player.queue_free()
	global.player = null
	await process_frame
	print("PASS: damage fractions, typed scaling, penalties, crit order/reset, cooldown bonuses/penalties/cap, 18 upgrades and 40 live weapon tiers/animation safety")
	quit()
