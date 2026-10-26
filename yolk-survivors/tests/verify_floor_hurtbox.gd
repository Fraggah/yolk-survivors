extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var global=root.get_node("Global")
	global.main_player_selected=load("res://resources/units/players/player_well_rounded.tres")
	var player=global.get_selected_player()
	root.add_child(player)
	player.set_process(false)
	var item=load("res://resources/items/weapons/range/knifer/item_knifer_1.tres")
	player.add_weapon(item)
	var weapon=player.current_weapons[0]
	weapon.set_process(false)
	for size in [0.5,1.0,2.0]:
		var enemy=load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
		enemy.visual_scale=size
		var area=enemy.get_node("HurtboxComponent")
		var collision=area.get_node("CollisionShape2D")
		var scene_point: Vector2=area.position+collision.position
		root.add_child(enemy)
		enemy.set_process(false)
		enemy.position=Vector2(200,100)
		var expected: Vector2=enemy.to_global(scene_point*size)
		assert(enemy.get_aim_position().distance_to(expected)<0.001,"Combined scene offsets must scale together")
		assert(enemy.get_aim_position().distance_to(collision.global_position)<0.001)
		assert(enemy.get_aim_position().distance_to(area.global_position)>10,"Fixture must distinguish area origin from feet")
		var before: Vector2=enemy.get_aim_position()
		enemy.visuals.scale.x*=-1
		assert(enemy.get_aim_position()==before,"Visual facing cannot shift floor collisions")
		collision.position+=Vector2(11,7)
		assert(enemy.get_aim_position()==collision.global_position,"Authored shape adjustments must remain authoritative")
		weapon.closest_target=enemy
		weapon.weapon_spread=0
		weapon.rotation=weapon.get_rotation_to_target()
		weapon.weapon_behaviour._spawn_projectile(0)
		var shot=get_nodes_in_group("projectiles").back()
		assert(shot.velocity.normalized().dot(shot.global_position.direction_to(enemy.get_aim_position()))>0.99999,"Projectile must aim from its actual muzzle to the feet")
		shot.queue_free()
		enemy.queue_free()
	player.queue_free()
	global.player=null
	await process_frame
	print("PASS floor hurtboxes: combined offsets at half/normal/double scale, actual collision centers, visual flips, editable offsets and muzzle-correct projectile aim")
	quit()
