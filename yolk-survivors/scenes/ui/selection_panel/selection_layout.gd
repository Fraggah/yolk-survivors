extends RefCounted
## Scene-backed layout access. Geometry is authored in each selection scene.
var menu: Control
var body: Control
var right_players: GridContainer
var back: Button
var weapon_scroll: ScrollContainer
var authored_panel_offsets: Vector4
func setup(panel: Control) -> void:
	menu=panel
	body=menu.get_node("Viewport/RosterLayout")
	right_players=body.get_node("RightPlayersContainer")
	back=body.get_node("CustomButtonExit")
	weapon_scroll=body.get_node_or_null("WeaponRosterScroll")
	authored_panel_offsets=Vector4(menu.player_panel.offset_left,menu.player_panel.offset_top,menu.player_panel.offset_right,menu.player_panel.offset_bottom)
func refresh() -> void:
	if menu.player_panel.get_meta("selection_transition_active",false) and not menu.transitioning:
		menu.player_panel.offset_left=authored_panel_offsets.x
		menu.player_panel.offset_top=authored_panel_offsets.y
		menu.player_panel.offset_right=authored_panel_offsets.z
		menu.player_panel.offset_bottom=authored_panel_offsets.w
		menu.player_panel.set_meta("selection_transition_active",false)
func player_slot_rects(_count: int, weapon_mode: bool=false) -> Array[Rect2]:
	var target=menu.player_panel
	var arena=menu.get_tree().current_scene
	if weapon_mode and arena is Arena: target=arena.weapon_selection_panel.player_panel
	var rect=target.get_rect()
	if _count<=1: return [rect]
	var rows=target.get_node("CoopRows/Rows")
	var gap=rows.get_theme_constant("separation")
	var height=(rect.size.y-gap*(_count-1))/_count
	var result: Array[Rect2]=[]
	for i in _count: result.append(Rect2(rect.position+Vector2(0,i*(height+gap)),Vector2(rect.size.x,height)))
	return result
func weapon_roster_rect() -> Rect2:
	return weapon_scroll.get_rect() if weapon_scroll else menu.weapons_container.get_rect()
func content_rect() -> Rect2:
	return Rect2(Vector2(back.position.x,menu.player_panel.position.y),Vector2(body.size.x-2*back.position.x,menu.player_panel.size.y))
func refresh_player_detail() -> void:
	pass
func fit_descriptions() -> void:
	# Text fields and scroll settings are authored; never force a runtime font size.
	pass
