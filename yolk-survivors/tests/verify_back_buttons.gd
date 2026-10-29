extends SceneTree
func _initialize(): call_deferred("verify")
func click(button: Button):
 for i in 3: await process_frame
 assert(button.is_visible_in_tree(),"Hidden Back target: "+str(button.get_path()))
 var point=button.get_global_rect().get_center()
 var motion=InputEventMouseMotion.new()
 motion.position=point
 motion.relative=Vector2(10,10)
 root.push_input(motion,true)
 await process_frame
 for down in [true,false]:
  var event=InputEventMouseButton.new()
  event.position=point
  event.button_index=MOUSE_BUTTON_LEFT
  event.pressed=down
  root.push_input(event,true)
  for i in 3: await process_frame
func verify():
 load("res://tests/progression_fixture.gd").prepare(root)
 var arena=load("res://scenes/arena/arena.tscn").instantiate()
 root.add_child(arena)
 current_scene=arena
 var menu=root.get_node("MenuInput")
 for device in menu.connected_gamepads.duplicate(): menu._on_joy_connection_changed(device,false)
 await click(arena.start_panel.get_node("MarginContainer/VBoxContainer/OptionsButton"))
 await click(arena.options_panel.get_node("CustomButton"))
 assert(arena.start_panel.visible and not arena.options_panel.visible)
 await click(arena.start_panel.get_node("MarginContainer/VBoxContainer/CreditsButton"))
 await click(arena.credits_panel.get_node("CustomButton"))
 assert(arena.start_panel.visible and not arena.credits_panel.visible)
 await click(arena.start_panel.get_node("MarginContainer/VBoxContainer/PlayButton"))
 await click(arena.selection_panel.roster_layout.back)
 assert(arena.start_panel.visible and not arena.selection_panel.visible)
 arena._on_start_panel_on_play_pressed()
 await arena._on_selection_panel_on_selection_completed()
 await click(arena.weapon_selection_panel.roster_layout.back)
 assert(arena.selection_panel.visible and not arena.weapon_selection_panel.visible)
 await arena._on_selection_panel_on_selection_completed()
 arena._on_weapon_selection_completed()
 for i in 3: await process_frame
 var level_back=arena.level_panel.get_node("CustomButton")
 var player_back=arena.selection_panel.roster_layout.back
 var weapon_back=arena.weapon_selection_panel.roster_layout.back
 assert(level_back.size.is_equal_approx(player_back.size),"Difficulty Back differs from character Back: "+str(level_back.size)+" versus "+str(player_back.size))
 assert(level_back.size.is_equal_approx(weapon_back.size),"Difficulty Back differs from weapon Back")
 assert(level_back.global_position.is_equal_approx(player_back.global_position))
 await click(level_back)
 assert(arena.weapon_selection_panel.visible and not arena.level_panel.visible)
 print("PASS actual Back clicks: characters, weapons, difficulty, options and credits")
 arena.queue_free()
 await process_frame
 quit()
