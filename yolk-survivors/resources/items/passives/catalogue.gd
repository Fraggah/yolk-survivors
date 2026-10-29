extends RefCounted

const DIRECTORY := "res://resources/items/passives/catalogue"
static var _cached: Array[ItemPassive] = []
static var _loaded := false

static func _resource_paths(directory: String) -> Array[String]:
	var paths: Array[String] = []
	for entry in DirAccess.get_files_at(directory):
		# Exported Godot resources may be listed with a .remap suffix.
		var filename: String = entry.trim_suffix(".remap")
		if filename.get_extension() != "tres": continue
		var path := directory.path_join(filename)
		if not paths.has(path): paths.append(path)
	paths.sort()
	return paths

static func items() -> Array[ItemPassive]:
	if not _loaded:
		for path in _resource_paths(DIRECTORY):
			var item = load(path)
			if item is ItemPassive: _cached.append(item)
		_loaded = true
	var available: Array[ItemPassive] = []
	for item in _cached:
		if item.get("ready_for_shop") == true: available.append(item)
	return available
