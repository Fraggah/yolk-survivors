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
	var item=load("res://resources/items/weapons/spicy/item_rocoto.tres").duplicate()
	item.stats=item.stats.duplicate(true)
	item.stats.crit_chance=0
	var weapon=item.scene.instantiate()
	player.add_child(weapon)
	weapon.setup_weapon(item)
	weapon.set_process(false)
	var effect=load("res://effects/spicy_pattern_effect.gd").new()
	effect.configure(weapon,item.stats.spicy_pattern,player.global_position)
	arena.add_child(effect)
	effect.set_process(false)
	assert(effect.settings.wave_duration==0.18 and effect.wave_visual!=null and effect.effect_material==null)
	var targets=[]
	for fraction in [0.1,0.5,0.95]:
		targets.append(enemy_at(effect.global_position+Vector2(effect.radius*fraction,0)))
	var outside=enemy_at(effect.global_position+Vector2(0,effect.radius*0.85))
	# A long frame crosses the whole front: every traversed enemy still gets one hit.
	effect._process(effect.settings.wave_duration*1.1)
	for target in targets: assert(is_equal_approx(target.health_component.current_health,10000-item.stats.damage))
	assert(outside.health_component.current_health==10000)
	assert(not effect.is_queued_for_deletion(),"Short visual dissipation survives the active front")
	var late=enemy_at(effect.global_position+Vector2(effect.radius*0.99,0))
	effect._process(0.02)
	assert(late.health_component.current_health==10000,"Visual echoes cannot damage a new target after the wave")
	for target in targets: assert(is_equal_approx(target.health_component.current_health,10000-item.stats.damage))
	assert(effect.wave_visual.sparks.multimesh.instance_count==effect.settings.shockwave_spark_count)
	global.game_paused=true
	var time=effect.wave_visual.elapsed
	effect._process(1)
	assert(effect.wave_visual.elapsed==time)
	global.game_paused=false
	effect._process(effect.settings.shockwave_visual_tail)
	assert(effect.is_queued_for_deletion())
	arena.queue_free()
	await process_frame
	print("PASS Rocoto: faster oval sweep, full traversal in long frames, one hit per enemy, visual-only tail, particles, pause and cleanup")
	quit()
