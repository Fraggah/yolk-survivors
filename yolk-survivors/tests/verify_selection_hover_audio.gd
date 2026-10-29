extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
 load("res://tests/progression_fixture.gd").prepare(root)
 var arena=load("res://scenes/arena/arena.tscn").instantiate()
 root.add_child(arena)
 current_scene=arena
 var menu=root.get_node("MenuInput")
 for device in menu.connected_gamepads.duplicate(): menu._on_joy_connection_changed(device,false)
 var sound=root.get_node("SoundManager")
 var tone=AudioStreamWAV.new()
 tone.mix_rate=22050
 tone.data=PackedByteArray()
 tone.data.resize(2205)
 sound.selection_hover=tone
 arena._on_start_panel_on_play_pressed()
 for panel in [arena.selection_panel,arena.weapon_selection_panel]:
  arena.selection_panel.hide()
  arena.weapon_selection_panel.hide()
  panel.show()
  for i in 4: await process_frame
  var card=panel.players_container.get_child(0) if panel==arena.selection_panel else panel.weapons_container.get_child(0)
  var handlers=card.mouse_entered.get_connections().filter(func(c): return c.callable==card._on_mouse_entered)
  assert(handlers.size()==1,"Hover SFX must have exactly one handler")
  for player in sound.stream_players: player.stop()
  sound.event_times.erase("selection_hover")
  var outside=InputEventMouseMotion.new()
  outside.position=Vector2(2,2)
  root.push_input(outside,true)
  await process_frame
  var event=InputEventMouseMotion.new()
  event.position=card.get_global_rect().get_center()
  event.relative=Vector2(10,10)
  root.push_input(event,true)
  for i in 4: await process_frame
  assert(sound.event_times.has("selection_hover"),"Actual mouse hover must play selection_hover")
 print("PASS hover audio: real pointer entry on character and weapon cards, exactly one SFX handler")
 arena.queue_free()
 await process_frame
 quit()
