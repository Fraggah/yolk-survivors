extends SceneTree

# Regenerate the editor preview after editing the palette resources.
# godot --headless --path <project> --script res://tools/build_ui_theme.gd
func _initialize() -> void:
	call_deferred("build")

func build() -> void:
	var themes = root.get_node("UITheme")
	var id := "cream"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--palette="): id = arg.trim_prefix("--palette=")
	themes.set_palette(id)
	var error := ResourceSaver.save(themes.ui_theme, "res://resources/ui/default_theme.tres")
	if error != OK: push_error("Unable to save editor theme: %s" % error)
	else: print("Editor theme generated: ", themes.palette.display_name)
	quit(error)
