extends SceneTree
func _initialize(): call_deferred("verify")
func key(code: Key):
 for down in [true,false]:
  var event=InputEventKey.new()
  event.keycode=code
  event.pressed=down
  Input.parse_input_event(event)
  for i in 4: await process_frame
func verify():
 load("res://tests/progression_fixture.gd").prepare(root)
 var arena=load("res://scenes/arena/arena.tscn").instantiate()
 root.add_child(arena)
 current_scene=arena
 var menu=root.get_node("MenuInput")
 for device in menu.connected_gamepads.duplicate(): menu._on_joy_connection_changed(device,false)
 for i in 4: await process_frame
 var play=arena.start_panel.get_node("MarginContainer/VBoxContainer/PlayButton")
 var hover=play.get_theme_stylebox("hover").bg_color
 assert(play.get_theme_stylebox("normal").bg_color!=hover,"Play must not save its hover as the base style")
 await key(KEY_DOWN)
 assert(root.gui_get_focus_owner().name=="OptionsButton","Keyboard Down must navigate without a controller")
 await key(KEY_UP)
 assert(root.gui_get_focus_owner()==play)
 assert(play.get_theme_stylebox("normal").bg_color==hover)
 var motion=InputEventMouseMotion.new()
 motion.position=Vector2(5,5)
 motion.relative=Vector2(10,10)
 root.push_input(motion,true)
 for i in 4: await process_frame
 assert(root.gui_get_focus_owner()==null)
 assert(play.get_theme_stylebox("normal").bg_color!=hover,"Mouse movement must clear keyboard hover")
 await key(KEY_UP)
 await key(KEY_ENTER)
 assert(arena.selection_panel.visible and not arena.start_panel.visible,"Enter must activate the focused menu button")
 print("PASS keyboard menu: arrows without gamepad, Enter, initial base style and hover cleared by mouse")
 arena.queue_free()
 await process_frame
 quit()
