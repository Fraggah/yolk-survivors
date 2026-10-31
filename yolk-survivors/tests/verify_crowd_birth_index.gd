extends SceneTree
var failures := 0
func _initialize(): call_deferred("verify")
func check(value: bool, message: String):
	if not value:
		failures += 1
		push_error(message)
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	root.get_node("Global").game_paused = false
	var crowd = root.get_node("EnemyCrowd")
	var scene = load("res://scenes/units/enemies/enemy_chaser_mid.tscn")
	var first = scene.instantiate()
	arena.add_child(first)
	first.global_position = Vector2(1000, 1000)
	first.set_process(false)
	crowd._process(0.0)
	var time_left: float = crowd.grid_left
	var second = scene.instantiate()
	arena.add_child(second)
	second.global_position = Vector2(2000, 2000)
	second.set_process(false)
	check(crowd.grid_left == time_left, "Birth does not invalidate the whole crowd grid")
	crowd._process(0.001)
	check(crowd.nearest(second.global_position, 20) == second, "New member indexed after final spawn positioning")
	check(crowd.nearest(first.global_position, 20) == first, "Existing cells retained")
	check(crowd.pending_members.is_empty(), "Pending births drained")
	var third = scene.instantiate()
	arena.add_child(third)
	var id: int = third.get_instance_id()
	third.free()
	check(not crowd.pending_members.has(id) and not crowd.members.has(id), "Early exit removes pending member")
	arena.queue_free()
	await process_frame
	check(crowd.members.is_empty() and crowd.pending_members.is_empty(), "Wave cleanup removes all members and pending births")
	print("CROWD BIRTH INDEX: ", "PASS" if failures == 0 else "FAIL (%s)" % failures)
	quit(0 if failures == 0 else 1)
