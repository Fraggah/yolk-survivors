extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
 load("res://tests/progression_fixture.gd").prepare(root)
 var arena=load("res://scenes/arena/arena.tscn").instantiate()
 root.add_child(arena)
 current_scene=arena
 var global=root.get_node("Global")
 global.main_player_selected=arena.selection_panel.player_list[0]
 global.main_weapon_selected=load("res://resources/items/weapons/range/knifer/item_knifer_1.tres")
 arena.start_panel.hide()
 arena._on_level_selected(0)
 arena.spawner.spawn_timer.stop()
 arena.spawner.wave_timer.stop()
 for i in 3: await process_frame
 assert(arena.player_health_bar.health_value.is_visible_in_tree())
 for bar in [arena.player_health_bar,arena.experience_bar]:
  assert(bar.scene_file_path.ends_with("health_bar_ui.tscn"),"HUD must use the authored rounded UI variant")
  assert(bar.progress_bar.get_theme_stylebox("background").corner_radius_top_left==24)
  assert(bar.progress_bar.get_theme_stylebox("background").border_width_top==5)
  assert(bar.get_node("ProgressBar/Outline").visible)
 assert(arena.player_health_bar.clipped_fill.material!=arena.experience_bar.clipped_fill.material,"HP and XP fills must be independent")
 var xp=arena.experience_bar
 assert(xp.clipped_fill.size.is_equal_approx(xp.progress_bar.size),"XP fill must occupy the authored full track")
 global.player.stats.experience_gain=0
 arena.run_experience.add_experience(8)
 await process_frame
 assert(is_equal_approx(xp.progress_bar.ratio,0.5))
 assert(is_equal_approx(xp.clipped_fill.material.get_shader_parameter("ratio"),0.5))
 assert(xp.clipped_fill.material.get_shader_parameter("fill_color")==root.get_node("UITheme").palette.experience_fill)
 arena.run_experience.add_experience(9)
 await process_frame
 assert(arena.run_experience.level==2 and arena.run_experience.experience==1)
 assert(is_equal_approx(xp.clipped_fill.material.get_shader_parameter("ratio"),1.0/25.0))
 arena.run_experience.add_experience(11)
 await process_frame
 assert(is_equal_approx(xp.clipped_fill.material.get_shader_parameter("ratio"),12.0/25.0))
 arena.player_health_bar.update_bar(0.65,13)
 if OS.get_cmdline_user_args().has("--capture"):
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/rounded-combat-bars.png"))
 arena.wave_active=true
 arena.set_wave_paused(true)
 for i in 3: await process_frame
 assert(not arena.player_health_bar.health_value.is_visible_in_tree(),"HP text must hide during pause")
 assert(not arena.experience_bar.health_value.is_visible_in_tree(),"XP text must hide during pause")
 arena.set_wave_paused(false)
 for i in 3: await process_frame
 assert(arena.player_health_bar.health_value.is_visible_in_tree())
 global.player.passive_items.golden_yolks=2
 global.player.passive_items.breading_charges=2
 arena.shop_panel.load_shop(1)
 arena.shop_panel.show()
 for i in 4: await process_frame
 for name in ["GoldenControl","BreadingControl"]:
  var button=arena.shop_panel.get_node("MarginContainer/Control/EquipmentArea/"+name)
  assert(button.visible)
  assert(button.get_node("Count").get_rect().end.x<0,"Consumable count must not overlap its icon")
  var expected="078.png" if name=="GoldenControl" else "081.png"
  assert(button.get_node("Icon").texture.resource_path.ends_with(expected))
 assert(not arena.player_health_bar.is_visible_in_tree())
 assert(not arena.player_health_bar.health_value.is_visible_in_tree(),"HP text must hide with the combat HUD")
 assert(not arena.experience_bar.health_value.is_visible_in_tree(),"XP text must hide with the combat HUD")
 var found=false
 for slot in arena.shop_panel.weapon_container.get_children():
  var marker=slot.get_node("RarityMarker")
  if slot.item==null:
   assert(not marker.visible)
   continue
  found=true
  var bounds=slot.get_global_rect()
  var rect=marker.get_global_rect()
  print("TIER ",bounds," -> ",rect)
  assert(bounds.encloses(rect),"Tier must remain within the weapon slot")
  assert(rect.get_center().x>bounds.get_center().x and rect.get_center().y>bounds.get_center().y,"Tier must be in bottom-right quadrant")
 assert(found)
 if OS.get_cmdline_user_args().has("--capture"):
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../tmp/solo-shop-hud-tiers.png"))
 arena.shop_panel.hide()
 for i in 3: await process_frame
 assert(arena.player_health_bar.health_value.is_visible_in_tree())
 assert(arena.experience_bar.health_value.is_visible_in_tree())
 assert(arena.experience_bar.health_value.text.begins_with("LV"),"Visibility changes must preserve the experience caption")
 print("PASS solo shop: combat HP/XP hidden, restored in combat; native tier marker bottom-right and empty slots unmarked")
 arena.queue_free()
 await process_frame
 quit()
