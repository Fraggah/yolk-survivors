extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	var global=root.get_node("Global")
	global.game_paused=false
	var scene=Node2D.new()
	root.add_child(scene)
	current_scene=scene
	var pool=load("res://effects/mayonnaise_particles.gd").new()
	scene.add_child(pool)
	var config=load("res://resources/items/weapons/ranged_settings.gd").new()
	config.stream_impact_particles=200
	assert(pool.free_particles.size()==1800 and pool.particles.is_empty())
	assert(pool.instances.instance_count==5400 and pool.instances.visible_instance_count==0)
	for i in 12: pool.emit_splash(Vector2(100,100),Vector2.RIGHT,config,true)
	assert(pool.particles.size()==1800 and pool.free_particles.is_empty(),"Fixed capacity does not allocate extra particles under load")
	pool._process(0.001)
	assert(pool.instances.visible_instance_count==5400)
	assert(pool.instances.get_instance_color(0).a>0)
	global.game_paused=true
	var point=pool.particles[0].position
	pool._process(1)
	assert(pool.particles[0].position==point and pool.particles.size()==1800)
	global.game_paused=false
	pool._process(10)
	assert(pool.particles.is_empty() and pool.free_particles.size()==1800)
	assert(pool.instances.visible_instance_count==0,"Expired slots are hidden rather than leaving stale drops")
	config.stream_impact_particles=10
	pool.emit_splash(Vector2.ZERO,Vector2.RIGHT,config,true)
	pool._process(0.01)
	assert(pool.particles.size()==10 and pool.free_particles.size()==1790 and pool.instances.visible_instance_count==30)
	pool.clear()
	pool.clear()
	assert(pool.free_particles.size()==1800 and pool.particles.is_empty() and pool.instances.visible_instance_count==0,"Clear returns slots exactly once")
	pool.emit_splash(Vector2.ZERO,Vector2.RIGHT,config,true)
	assert(pool.particles.size()==10,"Pool is reusable after wave cleanup")
	print("PASS mayonnaise MultiMesh: fixed allocation, layered colors, full capacity, pause, expiry, idempotent clear and reuse")
	quit()
