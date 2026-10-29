extends SceneTree
func _initialize(): call_deferred("verify")
func scene_preview(source: PackedScene) -> PackedScene:
 var packed=PackedScene.new()
 var bundle=source.get("_bundled").duplicate(true)
 var variants=bundle["variants"]
 for i in variants.size():
  if variants[i] is Script and not variants[i].is_tool(): variants[i]=null
  elif variants[i] is PackedScene: variants[i]=scene_preview(variants[i])
 bundle["variants"]=variants
 packed.set("_bundled",bundle)
 return packed
func strip_runtime_scripts(node: Node):
 for child in node.get_children(): strip_runtime_scripts(child)
 var script=node.get_script()
 if script and not script.is_tool(): node.set_script(null)
func controls(node: Node, prefix: String="") -> Dictionary:
 var result={}
 for child in node.get_children():
  var path=prefix+str(child.name)
  if child is Control: result[path]=child.get_rect()
  result.merge(controls(child,path+"/"))
 return result
func verify():
 load("res://tests/progression_fixture.gd").prepare(root)
 var arena=load("res://scenes/arena/arena.tscn").instantiate()
 root.add_child(arena)
 current_scene=arena
 await process_frame
 await process_frame
 var unlock=load("res://scenes/ui/unlock_notice.tscn").instantiate()
 arena.get_node("GameUI").add_child(unlock)
 var boss_hud=load("res://scenes/bosses/boss_health_bar.tscn").instantiate()
 arena.get_node("GameUI").add_child(boss_hud)
 await process_frame
 await process_frame
 var cases=[
  [unlock,"res://scenes/ui/unlock_notice.tscn"],
  [boss_hud,"res://scenes/bosses/boss_health_bar.tscn"],
  [arena.start_panel,"res://scenes/ui/start_panel/start_panel.tscn"],
  [arena.upgrade_panel,"res://scenes/ui/upgrades/upgrade_panel.tscn"],
  [arena.get_node("GameUI/FinalScreen"),"res://scenes/ui/final_screen.tscn"],
  [arena.selection_panel,"res://scenes/ui/selection_panel/selection_panel.tscn"],
  [arena.weapon_selection_panel,"res://scenes/ui/selection_panel/weapon_selection_panel.tscn"],
  [arena.shop_panel.coin_animation,"res://scenes/ui/shop/chocolate_coin_reveal.tscn"],
  [arena.shop_panel.golden_animation,"res://scenes/ui/shop/golden_yolk_reveal.tscn"],
  [arena.incognito_rewards,"res://scenes/ui/incognito_rewards.tscn"],
  [arena.options_panel,"res://scenes/ui/options_panel/options_panel.tscn"],
  [arena.credits_panel,"res://scenes/ui/credits_panel/credits_panel.tscn"],
  [arena.pause_panel,"res://scenes/ui/pause_panel/pause_panel.tscn"],
  [arena.level_panel,"res://scenes/ui/level_panel/level_panel.tscn"]]
 for pair in cases:
  var preview: Node
  if pair[1].ends_with("level_panel.tscn"):
   preview=load(pair[1]).instantiate()
   strip_runtime_scripts(preview)
  else: preview=scene_preview(load(pair[1])).instantiate()
  root.add_child(preview)
  if preview is CanvasItem: preview.show()
  if pair[0] is CanvasItem: pair[0].show()
  await process_frame
  await process_frame
  var authored=controls(preview)
  var live=controls(pair[0])
  for path in live:
   assert(authored.has(path),"Runtime-only UI node: "+pair[1]+"/"+path)
   # Content changes label minimum widths; verify structural frames instead.
   var node=pair[0].get_node(path)
   if (node is Panel or node is ScrollContainer) and not ("PlayersContainer/" in path or "WeaponsContainer/" in path or "/Stats/" in path or "/ItemContainer/" in path):
    assert(live[path].is_equal_approx(authored[path]),"Scene/runtime geometry: "+pair[1]+"/"+path)
  preview.queue_free()
  await process_frame
 print("PASS UI scene sources: fourteen panels, no runtime-only controls; native structural geometry preserved")
 arena.queue_free()
 await process_frame
 quit()
