extends SceneTree
func _initialize(): call_deferred("verify")
func strip_scripts(node: Node):
	for child in node.get_children(): strip_scripts(child)
	node.set_script(null)
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var scene=load("res://scenes/ui/shop/shop_panel.tscn")
	var preview=scene.instantiate()
	strip_scripts(preview)
	root.add_child(preview)
	await process_frame
	await process_frame
	var paths=["MarginContainer/Control/EquipmentArea","MarginContainer/Control/EquipmentArea/GoldenControl","MarginContainer/Control/EquipmentArea/BreadingControl","MarginContainer/Control/StatsContainer","MarginContainer/Control/RefreshHeader"]
	for name in ["GoldenControl","BreadingControl"]:
		var button=preview.get_node("MarginContainer/Control/EquipmentArea/"+name)
		assert(button.size.is_equal_approx(Vector2(64,64)),"Consumable must stay square in the editor")
		assert(button.get_combined_minimum_size().x<=64 and button.get_combined_minimum_size().y<=64,"Icon must not enlarge the button")
		assert(button.get_node("Icon").size.is_equal_approx(Vector2(40,40)))
		var count=button.get_node("Count")
		assert(count.get_rect().end.x<=-12,"Charge count must remain outside the button")
		assert(is_equal_approx(count.get_rect().get_center().y,button.size.y*.5),"Count must align vertically with its button")
	var rects: Array=[]
	for path in paths: rects.append(preview.get_node(path).get_global_rect())
	assert(preview.get_node("WeaponActions/Content/CombineButton")!=null)
	assert(not preview.get_node("WeaponActions").visible)
	assert(not preview.has_node("MarginContainer/Control/VBoxContainer/CombineButton"))
	assert(preview.get_node("MarginContainer/Control/EquipmentArea/BreadingControl/Icon").texture.resource_path.ends_with("081.png"))
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/shop-native-editor-preview.png"))
	preview.queue_free()
	await process_frame
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	await process_frame
	arena.start_panel.hide()
	var shop=arena.shop_panel
	shop.show()
	await process_frame
	await process_frame
	for i in paths.size():
		assert(shop.get_node(paths[i]).get_global_rect().is_equal_approx(rects[i]),"Scene/runtime layout differs: "+paths[i])
	var authored=scene.instantiate()
	var button=authored.get_node("MarginContainer/Control/EquipmentArea/GoldenControl")
	button.position+=Vector2(-23,7)
	var expected=button.position
	var stats=authored.get_node("MarginContainer/Control/StatsContainer")
	var row=stats.get_node("MarginContainer/VBoxContainer/health")
	row.custom_minimum_size.y=42
	root.add_child(authored)
	await process_frame
	await process_frame
	assert(button.position.is_equal_approx(expected),"Runtime must respect edited scene offsets")
	assert(row.custom_minimum_size.y==42,"Runtime must respect edited row height")
	print("PASS native shop scene: editor/runtime geometry, contextual actions, icons and authored overrides respected")
	authored.queue_free()
	arena.queue_free()
	await process_frame
	quit()
