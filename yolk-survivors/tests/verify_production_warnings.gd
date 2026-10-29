extends SceneTree
var checked := 0
var failed := 0
func _initialize(): call_deferred("verify")
func visit(directory: String):
	for file in DirAccess.get_files_at(directory):
		if not file.ends_with(".gd"): continue
		var path=directory.path_join(file)
		checked+=1
		var script=ResourceLoader.load(path,"GDScript",ResourceLoader.CACHE_MODE_IGNORE)
		if script==null or not script.can_instantiate():
			failed+=1
			print("WARNING_CHECK_FAILED ",path)
	for folder in DirAccess.get_directories_at(directory):
		if folder in [".godot","tests","addons"]: continue
		visit(directory.path_join(folder))
func verify():
	# Strict only for this test process; never save or weaken project settings.
	for setting in ProjectSettings.get_property_list():
		if "gdscript/warnings/" in setting.name and ProjectSettings.get_setting(setting.name) is int and ProjectSettings.get_setting(setting.name)==1:
			ProjectSettings.set_setting(setting.name,2)
	visit("res://")
	print("WARNING_CHECK ",checked," scripts, ",failed," failures")
	quit(1 if failed else 0)
