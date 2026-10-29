extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
 load("res://tests/progression_fixture.gd").prepare(root)
 var arena=load("res://scenes/arena/arena.tscn").instantiate()
 root.add_child(arena)
 current_scene=arena
 var navigation=root.get_node("MenuInput")
 for device in navigation.connected_gamepads.duplicate(): navigation._on_joy_connection_changed(device,false)
 await process_frame
 await process_frame
 navigation._on_joy_connection_changed(77,true)
 for i in 3: await process_frame
 assert(root.gui_get_focus_owner().name=="PlayButton")
 for down in [true,false]:
  var pad=InputEventJoypadButton.new()
  pad.device=0
  pad.button_index=JOY_BUTTON_A
  pad.pressed=down
  Input.parse_input_event(pad)
  for i in 3: await process_frame
 assert(arena.selection_panel.visible and not arena.start_panel.visible,"Controller must open Play Game")
 arena.selection_panel._on_custom_button_exit_pressed()
 navigation._on_joy_connection_changed(77,false)
 for i in 3: await process_frame
 var button=arena.start_panel.get_node("MarginContainer/VBoxContainer/PlayButton")
 assert(button.mouse_filter==Control.MOUSE_FILTER_STOP)
 var point=button.get_global_rect().get_center()
 var motion=InputEventMouseMotion.new()
 motion.position=point
 root.push_input(motion,true)
 await process_frame
 for down in [true,false]:
  var click=InputEventMouseButton.new()
  click.position=point
  click.button_index=MOUSE_BUTTON_LEFT
  click.pressed=down
  root.push_input(click,true)
  await process_frame
 assert(arena.selection_panel.visible and not arena.start_panel.visible,"Actual mouse click must open character selection")
 print("PASS main menu: controller confirmation and real pointer click opens Play Game; native button filters and labels preserve access")
 arena.queue_free()
 await process_frame
 quit()
