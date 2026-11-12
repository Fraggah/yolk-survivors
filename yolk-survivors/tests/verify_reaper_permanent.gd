extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	var global=root.get_node("Global")
	global.main_player_selected=arena.selection_panel.player_list[0]
	global.main_weapon_selected=load("res://resources/items/weapons/range/knifer/item_knifer_1.tres")
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	var player=global.player
	player.set_process(false)
	player.health_component.debug_invulnerable=true
	for equipped in player.current_weapons: equipped.set_process(false)
	var weapons=[]
	var total=0
	for tier in [1,3,2,1,4]:
		var suffix="" if tier==1 else "_"+str(tier)
		var item=load("res://resources/items/weapons/chili/carolina_reaper/item_carolina_reaper"+suffix+".tres")
		assert(item.stats.spicy_pattern.count==tier and item.stats.spicy_pattern.lifetime==0)
		var weapon=item.scene.instantiate()
		player.add_child(weapon)
		weapon.setup_weapon(item)
		weapon.set_process(false)
		weapons.append(weapon)
		var behaviour=weapon.weapon_behaviour
		behaviour.execute_attack()
		assert(behaviour.owned.size()==tier and not behaviour.can_execute_attack())
		var identities=[]
		for reference in behaviour.owned:
			var column=reference.get_ref()
			column.set_process(false)
			column.elapsed=120.0
			column._process(0.01)
			assert(not column.is_queued_for_deletion())
			assert(column.column_visual.fill_material.get_shader_parameter("fade")==1.0)
			identities.append(column.get_instance_id())
		behaviour.execute_attack()
		assert(behaviour.owned.size()==tier)
		for index in tier: assert(behaviour.owned[index].get_ref().get_instance_id()==identities[index])
		total+=behaviour.owned.size()
	assert(total==11,"Copies and mixed tiers add their permanent tornado counts")
	var owner=weapons[1].weapon_behaviour
	owner.owned[0].get_ref().queue_free()
	assert(owner.can_execute_attack())
	var survivor=owner.owned[1].get_ref()
	owner.execute_attack()
	assert(owner.owned.size()==3 and owner.owned[0].get_ref()==survivor,"Only missing columns are replenished")
	owner.reset_attack()
	assert(owner.owned.is_empty() and survivor.is_queued_for_deletion())
	assert(not weapons[0].weapon_behaviour.owned[0].get_ref().is_queued_for_deletion(),"Reset does not remove another copy's columns")
	var orphan=weapons[0].weapon_behaviour.owned[0].get_ref()
	weapons[0].queue_free()
	orphan._process(0.01)
	assert(orphan.is_queued_for_deletion(),"Removing the weapon cleans up its permanent tornado")
	arena.queue_free()
	await process_frame
	print("PASS permanent Reaper: 1/2/3/4 per tier, additive copies, no expiry/fade, no duplicates, replenish, reset and removal")
	quit()
