extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
 load("res://tests/progression_fixture.gd").prepare(root)
 var arena=load("res://scenes/arena/arena.tscn").instantiate()
 root.add_child(arena)
 current_scene=arena
 arena.start_panel.hide()
 arena.upgrade_panel.load_upgrades(20)
 arena.upgrade_panel.show()
 for i in 4:
  arena.upgrade_panel.item_container.get_child(i).item=load("res://resources/items/upgrades/data/effects/upgrade_effects_%d.tres"%(i+1))
 for i in 4: await process_frame
 for i in 4:
  var card=arena.upgrade_panel.item_container.get_child(i)
  var header=card.get_node("RarityMarker")
  assert(header.visible and header.size.x>=card.size.x-8,"Tier header must span the card")
  assert(header.get_node("Text").text==["COMMON","RARE","EPIC","LEGENDARY"][i])
  assert(header.get_theme_stylebox("panel").bg_color==root.get_node("UITheme").palette.rarity(i))
  assert(card.get_global_rect().encloses(header.get_global_rect()))
 if OS.get_cmdline_user_args().has("--capture"):
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/upgrade-rarity-headers.png"))
 print("PASS native upgrade headers: common, rare, epic, legendary text/color and full-width scene geometry")
 arena.queue_free()
 await process_frame
 quit()
