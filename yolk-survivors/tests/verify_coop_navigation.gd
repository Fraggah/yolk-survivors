extends SceneTree
func _initialize(): call_deferred("verify")

func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena=load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena); current_scene=arena
	await process_frame
	arena._on_start_panel_on_play_pressed()
	var flow=arena.coop_selection
	flow.set_process(false)
	flow.enable(-1)
	for device in [0,1,2]: flow._join_device(device)
	await process_frame
	var checks:=0
	for weapons in [false,true]:
		flow.mode="weapons" if weapons else "characters"
		arena.selection_panel.visible=not weapons
		arena.weapon_selection_panel.visible=weapons
		flow.refresh()
		await process_frame
		await process_frame
		var cards=flow._roster_cards(weapons)
		var choices=flow._choices(weapons)
		for session in arena.coop.sessions:
			if weapons: session.character=flow._choices(false)[arena.coop.sessions.find(session)]
			# Repeat all directions for every player and their own restrictions.
			for origin in cards:
				var item=origin.get_meta("selection_data")
				if not choices.has(item): continue
				for step in [-1,1,-8 if weapons else -3,8 if weapons else 3]:
					if weapons: session.weapon=item
					else: session.character=item
					session.cursor=999 # Movement must use the visible selection, not a stale filtered index.
					var before: Array=[]
					for other in arena.coop.sessions: before.append(other.weapon if weapons else other.character)
					flow.move_cursor(session,step)
					var after=session.weapon if weapons else session.character
					assert(choices.has(after))
					var direction=Vector2(signi(step),0) if absi(step)<(8 if weapons else 3) else Vector2(0,signi(step))
					var same_axis: Control=null
					var nearest:=INF
					for card in cards:
						var candidate=card.get_meta("selection_data")
						if not choices.has(candidate): continue
						var offset: Vector2=card.get_global_rect().get_center()-origin.get_global_rect().get_center()
						if offset.dot(direction)>1 and absf(offset.cross(direction))<1 and offset.length()<nearest:
							nearest=offset.length(); same_axis=card
					if same_axis: assert(after==same_axis.get_meta("selection_data"),"Directional movement must reach the next valid card in its actual row/column")
					for i in arena.coop.sessions.size():
						if arena.coop.sessions[i]!=session: assert(before[i]==(arena.coop.sessions[i].weapon if weapons else arena.coop.sessions[i].character))
					checks+=1
	arena.queue_free()
	await process_frame; await process_frame
	print("PASS co-op navigation: ",checks," directional checks across four players, characters and weapons, visual gaps, restrictions, stale cursors and independent choices")
	quit()
