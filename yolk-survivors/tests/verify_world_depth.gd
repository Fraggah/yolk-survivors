extends SceneTree

func _initialize(): call_deferred("verify")

func marker(unit, color):
	var contact=unit.get_node_or_null("HitboxComponent")
	if contact: contact.disable()
	unit.set_process(false)
	unit.set_physics_process(false)
	unit.anim_player.stop()
	unit.scale = Vector2.ONE
	unit.visuals.scale = Vector2.ONE
	for child in unit.visuals.get_children():
		if child is CanvasItem: child.hide()
	unit.sprite.show()
	unit.sprite.position = Vector2(0,-40)
	unit.sprite.scale = Vector2.ONE
	unit.sprite.rotation = 0
	unit.sprite.material = null
	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([color,color])
	var texture = GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 128
	texture.height = 128
	unit.sprite.texture = texture
	assert(unit.sprite.z_as_relative and unit.sprite.z_index == 0)

func check_pixel(point, expected):
	if RenderingServer.get_rendering_device() == null: return
	await process_frame
	await RenderingServer.frame_post_draw
	var image = root.get_texture().get_image()
	var screen = root.canvas_transform * point
	var color = image.get_pixelv(Vector2i(screen))
	assert(color.is_equal_approx(expected), "Ground Y must order the entire visual subtree: %s versus %s" % [color,expected])

func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var global = root.get_node("Global")
	global.main_player_selected = arena.selection_panel.player_list[0]
	global.main_weapon_selected = load("res://resources/items/weapons/chili/carolina_reaper/item_carolina_reaper.tres")
	arena._on_level_selected(0)
	arena.spawner.spawn_timer.stop()
	assert(arena.y_sort_enabled)
	for node in arena.find_children("*", "CanvasLayer", true, false): node.visible = false
	var player = global.player
	player.health_component.debug_invulnerable=true
	player.get_node("HurtboxComponent").collision_layer=0
	player.get_node("HurtboxComponent").collision_mask=0
	for weapon in player.current_weapons:
		weapon.set_process(false)
		weapon.hide()
		weapon.weapon_behaviour.set_process(false)
	var enemy = load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	enemy.stats = enemy.stats.duplicate()
	arena.add_child(enemy)
	marker(player,Color.RED)
	marker(enemy,Color.BLUE)
	var origin = player.global_position
	enemy.global_position = origin + Vector2(0,20)
	await check_pixel(origin-Vector2(0,40),Color.BLUE)
	enemy.global_position = origin - Vector2(0,20)
	await check_pixel(origin-Vector2(0,40),Color.RED)
	var column = load("res://effects/spicy_pattern_effect.gd").new()
	var weapon = player.current_weapons[0]
	column.configure(weapon,weapon.data.stats.spicy_pattern,origin+Vector2(0,30))
	arena.add_child(column)
	column.set_process(false)
	assert(column.z_index == 0 and column.column_visual.fill_sprite.z_index == 0)
	for child in column.column_visual.get_children():
		if child is CanvasItem: child.hide()
	var rectangle = ColorRect.new()
	rectangle.color = Color.GREEN
	rectangle.position = Vector2(-64,-150)
	rectangle.size = Vector2(128,180)
	column.column_visual.add_child(rectangle)
	await check_pixel(origin-Vector2(0,40),Color.GREEN)
	column.global_position.y = origin.y-10
	await check_pixel(origin-Vector2(0,40),Color.RED)
	player.sprite.position.y -= 15
	await check_pixel(origin-Vector2(0,40),Color.RED)
	# Fueguito belongs to the pan controller, rather than directly to Arena.
	# Every grouping node along that path must participate in the same sort.
	var pan = load("res://scenes/arena/mechanics/pan_mechanic.tscn").instantiate()
	arena.stage_mechanics.add_child(pan)
	assert(arena.stage_mechanics.y_sort_enabled and pan.y_sort_enabled)
	var flame = load("res://scenes/units/enemies/enemy_fueguito.tscn").instantiate()
	pan.add_child(flame)
	marker(flame,Color.MAGENTA)
	flame.global_position = origin+Vector2(0,20)
	await check_pixel(origin-Vector2(0,40),Color.MAGENTA)
	flame.global_position.y = origin.y-30
	await check_pixel(origin-Vector2(0,40),Color.RED)
	flame.global_position.y = origin.y+20
	column.global_position.y = origin.y+40
	await check_pixel(origin-Vector2(0,40),Color.GREEN)
	flame.hide()
	enemy.hide()
	for file in DirAccess.get_files_at("res://scenes/projectiles"):
		if not file.begins_with("projectile_") or not file.ends_with(".tscn"): continue
		var shot = load("res://scenes/projectiles/"+file).instantiate()
		arena.add_child(shot)
		shot.set_process(false)
		shot.hitbox.disable()
		assert(shot.z_index==0 and shot.z_as_relative,"Projectile must share actor depth: "+file)
		for child in shot.get_children():
			if child is CanvasItem: child.hide()
		var token=ColorRect.new()
		token.color=Color.YELLOW
		token.position=Vector2(-64,-100)
		token.size=Vector2(128,120)
		shot.scale=Vector2.ONE
		shot.add_child(token)
		column.global_position.y=origin.y-10
		shot.global_position=origin+Vector2(0,20)
		await check_pixel(origin-Vector2(0,40),Color.YELLOW)
		shot.global_position.y=origin.y-30
		await check_pixel(origin-Vector2(0,40),Color.RED)
		shot.global_position.y=origin.y+20
		column.global_position.y=origin.y+40
		await check_pixel(origin-Vector2(0,40),Color.GREEN)
		shot.queue_free()
	var drop=arena.projectile_pool.acquire_drop()
	drop.set_process(false)
	drop.hitbox.disable()
	assert(arena.projectile_pool.y_sort_enabled)
	var drop_token=ColorRect.new()
	drop_token.color=Color.YELLOW
	drop_token.position=Vector2(-64,-100)
	drop_token.size=Vector2(128,120)
	drop.add_child(drop_token)
	drop.scale=Vector2.ONE
	column.global_position.y=origin.y-10
	drop.global_position=origin+Vector2(0,20)
	await check_pixel(origin-Vector2(0,40),Color.YELLOW)
	drop.global_position.y=origin.y-30
	await check_pixel(origin-Vector2(0,40),Color.RED)
	drop.hide()
	for id in ["cayenne","ghost_pepper","scotch_bonnet","rocoto","poblano"]:
		var item=load("res://resources/items/weapons/chili/"+id+"/item_"+id+".tres")
		var pattern=load("res://effects/spicy_pattern_effect.gd").new()
		pattern.configure(weapon,item.stats.spicy_pattern,origin)
		arena.add_child(pattern)
		pattern.set_process(false)
		assert(pattern.z_index==0,"Spicy effects participate in world depth: "+id)
		for layer in pattern.find_children("*","CanvasItem",true,false):
			assert(layer.z_index<=0,"No foreground override inside "+id+": "+str(layer.get_path()))
		pattern.hide()
		pattern.queue_free()
	var rays=root.get_node("ElectricRays")
	var controller=player.status_controller
	rays.submit_aura(controller,Vector2(0,-40),Vector2(30,40),0.1,1.0,Color.CYAN,1.0,7)
	var bolts=controller.get_node("DepthBolts_7_0")
	assert(bolts.get_parent()==controller and bolts.capacity==1 and bolts.z_index==0)
	assert(bolts.count==1)
	var token=ColorRect.new()
	token.color=Color.CYAN
	token.position=Vector2(-64,-100)
	token.size=Vector2(128,120)
	bolts.add_child(token)
	column.global_position.y=origin.y+40
	await check_pixel(origin-Vector2(0,40),Color.GREEN)
	column.global_position.y=origin.y-40
	await check_pixel(origin-Vector2(0,40),Color.CYAN)
	arena.queue_free()
	await process_frame
	print("PASS world depth: native ground Y sorting, player/enemy crossings, column occlusion and animated sprite independence")
	quit()
