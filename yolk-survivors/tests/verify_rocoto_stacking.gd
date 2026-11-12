extends SceneTree
var arena
var global
var player
func _initialize(): call_deferred("verify")
func enemy_at(point):
	var enemy=load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	enemy.stats=enemy.stats.duplicate()
	enemy.stats.block_chance=0
	arena.add_child(enemy)
	enemy.global_position=point
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.health_component.max_health=10000
	enemy.health_component.current_health=10000
	return enemy
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	global=root.get_node("Global")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=load("res://resources/items/weapons/range/knifer/item_knifer_1.tres")
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	player=global.player
	player.set_process(false)
	player.health_component.debug_invulnerable=true
	for weapon in player.current_weapons: weapon.set_process(false)
	for old in player.current_weapons: old.queue_free()
	player.current_weapons.clear()
	var base=load("res://resources/items/weapons/chili/rocoto/item_rocoto.tres")
	var items=[base,base,base.upgrade_to,base.upgrade_to,base.upgrade_to.upgrade_to]
	for item in items: player.add_weapon(item)
	for equipped in player.current_weapons:
		equipped.set_process(false)
		equipped.data=equipped.data.duplicate()
		equipped.data.stats=equipped.data.stats.duplicate(true)
		equipped.data.stats.crit_chance=0
		equipped.weapon_behaviour.execute_attack()
	var leaders=[]
	var count=0
	for equipped in player.current_weapons:
		count+=equipped.weapon_behaviour.owned.size()
		if not equipped.weapon_behaviour.owned.is_empty(): leaders.append(equipped)
	assert(count==3 and leaders.size()==3,"Only one effect per distinct tier")
	assert(not player.current_weapons[1].can_use_weapon() and not player.current_weapons[3].can_use_weapon())
	var target=enemy_at(player.global_position+Vector2(20,0))
	var expected=0.0
	for equipped in player.current_weapons: expected+=equipped.data.get_effective_damage(player.stats)
	for leader in leaders:
		var wave=leader.weapon_behaviour.owned[0].get_ref()
		wave.set_process(false)
		wave._process(wave.settings.wave_duration)
	assert(is_equal_approx(target.health_component.current_health,10000-expected),"Merged waves preserve every copy's damage")
	for equipped in player.current_weapons:
		assert(is_equal_approx(equipped.damage_record.wave_damage,equipped.data.get_effective_damage(player.stats)),"Each copy retains individual damage attribution")
	var removed=player.current_weapons.pop_front()
	removed.queue_free()
	var survivor=player.current_weapons[0]
	assert(survivor.weapon_behaviour.can_execute_attack())
	survivor.weapon_behaviour.execute_attack()
	assert(survivor.weapon_behaviour.owned.size()==1)
	var wave=survivor.weapon_behaviour.owned[0].get_ref()
	wave.set_process(false)
	assert(is_equal_approx(wave.hit.base_damage,survivor.data.get_effective_damage(player.stats)))
	var tier=base
	var previous_area=0.0
	var previous_damage=0.0
	var previous_cooldown=INF
	while tier:
		assert(tier.stats.spicy_pattern.radius>previous_area)
		assert(tier.stats.damage>previous_damage and tier.stats.cooldown<previous_cooldown)
		assert(tier.stats.spicy_pattern.color.r<0.8 and tier.stats.spicy_pattern.shockwave_core_color.g<0.3,"Warm dark pepper red, no white luminous core")
		previous_area=tier.stats.spicy_pattern.radius
		previous_damage=tier.stats.damage
		previous_cooldown=tier.stats.cooldown
		tier=tier.upgrade_to
	arena.queue_free()
	await process_frame
	print("PASS Rocoto grouping: same-tier single wave, separate tiers, summed damage, individual records, leader removal, darker palette and tier cadence")
	quit()
