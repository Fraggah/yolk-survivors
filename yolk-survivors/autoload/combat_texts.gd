extends Node
## Reusable label nodes; one animation loop per active text, without per-hit Tweens.
const CAPACITY := 384
const PREWARM := 64
const TEXT_SCENE := preload("res://scenes/ui/floating_text/floating_text.tscn")
@export_range(32,384,16) var active_limit := 128
@export_range(0.0,0.25,0.01) var damage_group_interval := 0.08
@export_range(0.4,1.3,0.05) var damage_lifetime := 0.85
var group_left := 0.0
var active: Array = []
var available: Array = []
var created := 0
var pending_damage: Dictionary = {}

func queue_damage(unit: Node2D, amount: float, tint: Color, critical: bool) -> void:
	var id := unit.get_instance_id()
	if pending_damage.has(id):
		pending_damage[id].amount += amount
		pending_damage[id].position = unit.global_position
		if critical: pending_damage[id].tint = tint
	else:
		pending_damage[id] = {"position": unit.global_position, "amount": amount, "tint": tint,"unit":weakref(unit)}

func _process(_delta: float) -> void:
	if Global.game_paused: return
	group_left -= _delta
	if group_left>0.0: return
	group_left = damage_group_interval
	# Combine simultaneous hits on the same enemy, preserving the total displayed damage.
	for id in pending_damage.keys():
		var entry: Dictionary = pending_damage[id]
		var unit := entry.unit.get_ref() as Node2D
		var shown := floori(float(entry.amount)+0.00000001)
		if shown<1:
			if not is_instance_valid(unit): pending_damage.erase(id)
			continue
		var text = acquire()
		var position: Vector2 = unit.global_position if is_instance_valid(unit) and unit.is_inside_tree() else entry.position
		text.global_position = position + Vector2.RIGHT.rotated(randf_range(0, TAU))
		text.setup_text(str(shown), entry.tint,damage_lifetime)
		entry.amount = maxf(0.0,float(entry.amount)-shown)
		if entry.amount<=0.00000001: pending_damage.erase(id)

func _ready() -> void:
	for i in PREWARM: available.append(_create())

func _create():
	var text = TEXT_SCENE.instantiate()
	text.managed = true
	text.recycle = release.bind(text)
	text.pause_source = get_node("/root/Global")
	add_child(text)
	text.hide()
	created += 1
	return text

func acquire():
	if active.size()>=active_limit: release(active[0])
	if available.is_empty():
		if created<CAPACITY: available.append(_create())
		else: release(active[0])
	var text = available.pop_back()
	active.append(text)
	text.add_to_group("combat_texts")
	text.show()
	return text

func release(text) -> void:
	if not active.has(text): return
	active.erase(text)
	text.set_process(false)
	text.remove_from_group("combat_texts")
	text.hide()
	available.append(text)

func clear() -> void:
	pending_damage.clear()
	for text in active.duplicate(): release(text)
