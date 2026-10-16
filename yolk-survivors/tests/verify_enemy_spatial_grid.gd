extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var global=root.get_node("Global")
	var crowd=root.get_node("EnemyCrowd")
	global.main_player_selected=load("res://resources/units/players/player_well_rounded.tres")
	var player=global.get_selected_player()
	root.add_child(player)
	player.set_process(false)
	player.global_position=Vector2.ZERO
	global.game_paused=false
	var enemies=[]
	for point in [Vector2(120,0),Vector2(180,0),Vector2(700,0)]:
		var enemy=load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
		root.add_child(enemy)
		enemy.global_position=point
		enemy.set_process(false)
		enemies.append(enemy)
	await process_frame
	crowd.rebuild()
	crowd._calculate(enemies[0],enemies[0].get_instance_id())
	crowd._calculate(enemies[1],enemies[1].get_instance_id())
	assert(crowd.separation(enemies[0]).x<0 and crowd.separation(enemies[1]).x>0,"Neighbors repel each other")
	assert(crowd.nearest(Vector2.ZERO,100)==null)
	assert(crowd.nearest(Vector2.ZERO,150)==enemies[0])
	assert(crowd.nearest(Vector2(1500,0),1000)==enemies[2],"Large resource ranges are not truncated by the grid window")
	var excluded={}
	for enemy in enemies: excluded[enemy.get_node("HurtboxComponent").get_instance_id()]=true
	assert(crowd.random_target(excluded)==null,"Bounces stop when all living targets were hit")
	excluded.erase(enemies[1].get_node("HurtboxComponent").get_instance_id())
	for i in 20: assert(crowd.random_target(excluded)==enemies[1])
	enemies[0].health_component.current_health=0
	crowd.rebuild()
	assert(crowd.nearest(Vector2.ZERO,200)==enemies[1],"Dead entries cannot be targeted")
	for enemy in enemies:
		assert(not enemy.vision_area.monitoring and enemy.vision_area.get_node("CollisionShape2D").disabled)
		assert(not enemy.get_node("HurtboxComponent/CollisionShape2D").disabled,"Combat hurtboxes are preserved")
	var old_clock=crowd.clock
	global.game_paused=true
	crowd._process(1)
	assert(crowd.clock==old_clock)
	global.game_paused=false
	var ids=[]
	for enemy in enemies:
		ids.append(enemy.get_instance_id())
		enemy.queue_free()
	await process_frame
	for id in ids: assert(not crowd.members.has(id),"Leaving the tree unregisters grid entries")
	assert(crowd.members.is_empty())
	assert(crowd.member_ids.is_empty())
	global.player=null
	player.queue_free()
	print("PASS enemy spatial grid: separation, radius-limited targeting, dead/freed cleanup, pause and untouched hurtboxes")
	quit()
