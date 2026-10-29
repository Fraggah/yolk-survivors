extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var catalogue=load("res://resources/items/passives/catalogue.gd")
	var listed=catalogue.items()
	var expected=[]
	for path in catalogue._resource_paths(catalogue.DIRECTORY):
		var item=load(path)
		if item.get("ready_for_shop")==true: expected.append(item)
	assert(listed.size()==expected.size())
	for item in expected: assert(listed.has(item),"Ready item omitted: "+item.resource_path)
	var newly_ready=load("res://resources/items/passives/catalogue/item_028.tres")
	assert(listed.has(newly_ready),"Bicarbonato must not require an ID whitelist")
	newly_ready.ready_for_shop=false
	assert(not catalogue.items().has(newly_ready),"Cached catalogue must respect ready changes")
	newly_ready.ready_for_shop=true
	assert(catalogue.items().has(newly_ready))
	var folder="user://catalogue_discovery_fixture"
	DirAccess.make_dir_recursive_absolute(folder)
	for name in ["item_999.tres","item_999.tres.remap","ignored.png"]:
		var file=FileAccess.open(folder.path_join(name),FileAccess.WRITE)
		file.store_string("")
		file.close()
	var paths=catalogue._resource_paths(folder)
	assert(paths==[folder.path_join("item_999.tres")],"New IDs and remapped export resources must be discovered without duplicates")
	for name in ["item_999.tres","item_999.tres.remap","ignored.png"]: DirAccess.remove_absolute(folder.path_join(name))
	DirAccess.remove_absolute(folder)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene=arena
	await process_frame
	for item in expected: assert(arena.shop_panel.shop_items.has(item),"Shop did not receive ready item: "+item.resource_path)
	print("PASS passive discovery: ",listed.size()," ready items, no whitelist, current flags, future IDs/remap paths and shop catalogue integration")
	arena.queue_free()
	await process_frame
	quit()
