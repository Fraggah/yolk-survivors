extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	var global=root.get_node("Global")
	global.game_paused=false
	var pool=load("res://scenes/projectiles/projectile_pool.gd").new()
	root.add_child(pool)
	assert(pool.available.size()==pool.PREWARM)
	assert(get_nodes_in_group("projectiles").is_empty())
	var first=pool.acquire_drop()
	var identity=first.get_instance_id()
	first.setup_projectile(Vector2(100,0),9,true,0,null,20)
	first.remaining_bounces=3
	first.hit_targets[42]=true
	first.hitbox._hit_hurtboxes[42]=true
	global.game_paused=true
	first._process(1)
	assert(first.distance_travelled==0)
	global.game_paused=false
	first._process(1)
	assert(not first.leased and not first.visible)
	await process_frame
	await process_frame
	assert(pool.leased.is_empty() and pool.available.size()==pool.PREWARM)
	var reused=pool.acquire_drop()
	assert(reused.get_instance_id()==identity)
	reused.setup_projectile(Vector2(100,0),2,false,0,null,100)
	assert(reused.hit_targets.is_empty() and reused.hitbox._hit_hurtboxes.is_empty())
	assert(reused.remaining_bounces==0 and reused.distance_travelled==0)
	assert(reused.hitbox.damage==2 and not reused.hitbox.critical)
	for i in pool.CAPACITY-1: pool.acquire_drop().set_process(false)
	assert(pool.created==pool.CAPACITY and pool.leased.size()==pool.CAPACITY)
	var overflow=pool.acquire_drop()
	assert(overflow.pool==null and overflow.is_in_group("projectiles"),"Pool capacity never discards a damaging shot")
	overflow.finish()
	pool.clear()
	assert(pool.leased.is_empty() and pool.available.size()==pool.CAPACITY)
	await process_frame
	assert(get_nodes_in_group("projectiles").is_empty())
	var external=pool.acquire_drop()
	external.finish()
	external.queue_free()
	await process_frame
	await process_frame
	assert(pool.created==pool.CAPACITY-1 and pool.leased.is_empty())
	pool.release(null)
	pool.clear()
	pool.clear()
	pool.queue_free()
	print("PASS projectile pool: prewarm, reuse, state reset, pause/range, no damage cap, external deletion, idempotent clear")
	quit()
