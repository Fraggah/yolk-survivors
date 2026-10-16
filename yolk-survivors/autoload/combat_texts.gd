extends Node
## Reusable label nodes; one animation loop per active text, without per-hit Tweens.
const CAPACITY := 384
const PREWARM := 64
const TEXT_SCENE := preload("res://scenes/ui/floating_text/floating_text.tscn")
var active: Array = []
var available: Array = []
var created := 0
var pending_damage: Dictionary = {}

func queue_damage(unit: Node2D, amount: float, tint: Color, critical: bool) -> void:
	var id := unit.get_instance_id()
	if pending_damage.has(id):
		pending_damage[id].amount += amount
		if critical: pending_damage[id].tint = tint
	else:
		pending_damage[id] = {"position": unit.global_position, "amount": amount, "tint": tint}

func _process(_delta: float) -> void:
	if Global.game_paused: return
	# Combine simultaneous hits on the same enemy, preserving the total displayed damage.
	for entry in pending_damage.values():
		var text = acquire()
		text.global_position = entry.position + Vector2.RIGHT.rotated(randf_range(0, TAU))
		text.setup_text(ItemWeapon.format_number(entry.amount), entry.tint)
	pending_damage.clear()

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
