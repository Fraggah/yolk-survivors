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
	var item=load("res://resources/items/weapons/chili/cayenne/item_cayenne.tres")
	var weapon=item.scene.instantiate()
	player.add_child(weapon)
	weapon.setup_weapon(item)
	weapon.set_process(false)
	var patch=load("res://effects/spicy_pattern_effect.gd").new()
	patch.configure(weapon,item.stats.spicy_pattern,Vector2.ZERO)
	arena.add_child(patch)
	patch.set_process(false)
	var target=enemy_at(Vector2(-patch.radius*2,0))
	patch._process(0.01)
	assert(not target.has_node("FireVisual"))
	target.position=Vector2.ZERO
	var hp=target.health_component.current_health
	patch._process(0.01)
	assert(target.has_node("FireVisual"), "Entry ignites between damage ticks")
	assert(target.health_component.current_health==hp, "Contact does not add a ground damage tick")
	var burns=target.get_children().filter(func(node): return node.get_script()==load("res://effects/fire_status.gd"))
	assert(burns.size()==1)
	var burn=burns[0]
	burn.set_process(false)
	burn._process(0.2)
	var tick=burn.tick_left
	patch._process(0.01)
	assert(burn.tick_left==tick, "Remaining inside does not reset fire tick timer")
	var crossing=enemy_at(Vector2(-patch.radius*2,0))
	patch._process(0.01)
	crossing.position=Vector2(patch.radius*2,0)
	var crossing_hp=crossing.health_component.current_health
	patch._process(0.01)
	assert(crossing.has_node("FireVisual"), "Full crossing between frames still ignites")
	assert(crossing.health_component.current_health==crossing_hp)
	var outside=enemy_at(Vector2(-patch.radius*2,patch.radius*0.8))
	patch._process(0.01)
	outside.position=Vector2(patch.radius*2,patch.radius*0.8)
	patch._process(0.01)
	assert(not outside.has_node("FireVisual"), "Sweeps respect the oval footprint")
	global.game_paused=true
	var paused=enemy_at(Vector2.ZERO)
	patch._process(0.1)
	assert(not paused.has_node("FireVisual"))
	global.game_paused=false
	patch._process(0.01)
	assert(paused.has_node("FireVisual"))
	arena.queue_free()
	await process_frame
	print("PASS Cayenne: immediate ignition between ticks, swept crossing, no extra contact damage, oval, pause and burn timer")
	quit()
