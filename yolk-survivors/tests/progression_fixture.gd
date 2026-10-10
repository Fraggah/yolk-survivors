extends RefCounted

# Tests use their own save file and cannot change the real player's unlock profile.
static func prepare(root: Node, unlock_all: bool = true) -> Node:
	ProjectSettings.set_setting("yolk/testing/unlock_characters_and_weapons", false)
	var progress := root.get_node("Progression")
	progress.save_path = "user://test_progress_%s.cfg" % OS.get_process_id()
	progress.completed.clear()
	progress.counters.clear()
	progress.run_active = false
	progress.dirty = false
	if unlock_all: progress.completed.assign(progress.ACHIEVEMENT_IDS)
	progress._rebuild_unlocks()
	return progress
