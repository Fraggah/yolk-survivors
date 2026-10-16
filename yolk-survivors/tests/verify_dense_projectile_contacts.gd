extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	root.get_node("Global").game_paused=false
	for budget in [Vector2i(0,0),Vector2i(2,0),Vector2i(0,3),Vector2i(2,3)]:
		var enemies=[]
		for i in 12:
			var enemy=load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
			root.add_child(enemy)
			enemy.set_process(false)
			enemy.global_position=Vector2(150,0)
			enemy.stats=enemy.stats.duplicate()
			enemy.stats.block_chance=0
			enemy.health_component.current_health=100
			enemy.health_component.max_health=100
			enemies.append(enemy)
		var projectile=load("res://scenes/projectiles/projectile_pistol.tscn").instantiate()
		root.add_child(projectile)
		projectile.setup_projectile(Vector2(500,0),3,false,0,null,500)
		projectile.remaining_piercing=budget.x
		projectile.remaining_bounces=budget.y
		for i in 50: await physics_frame
		var hit_count=0
		for enemy in enemies:
			assert(enemy.health_component.current_health==100 or enemy.health_component.current_health==97,"A target is damaged at most once")
			if enemy.health_component.current_health==97: hit_count+=1
		assert(hit_count==1+budget.x+budget.y,"Dense simultaneous overlaps must respect the projectile's contact budget")
		for enemy in enemies: enemy.queue_free()
		if is_instance_valid(projectile): projectile.queue_free()
		await process_frame
	print("PASS dense projectile contacts: normal, piercing, bounces and mixed budget, real overlaps, one damage per target")
	quit()
