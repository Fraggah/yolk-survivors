extends RefCounted
## One roll per entry into Burning. Iterative processing prevents recursive chains.
static var _pending: Array[Dictionary] = []
static var _processing := false

static func on_burning_started(target: Unit, key: String, template: HitboxComponent, settings: StatusEffect, damage_scaled: bool) -> void:
	if not target is Enemy or not template.source is Player: return
	var player := template.source as Player
	if not is_instance_valid(player.passive_items) or player.passive_items.fire_spread_chance <= 0.0: return
	_pending.append({"target":target, "key":key, "template":template, "settings":settings, "scaled":damage_scaled})
	if _processing: return
	_processing = true
	var index := 0
	while index < _pending.size():
		var entry: Dictionary = _pending[index]
		index += 1
		_try_spread(entry)
	_pending.clear()
	_processing = false

static func _try_spread(entry: Dictionary) -> void:
	var origin = entry.target
	var template = entry.template
	if not is_instance_valid(origin) or origin.is_queued_for_deletion() or not is_instance_valid(template): return
	if not is_instance_valid(template.source) or not template.source is Player: return
	var items = template.source.passive_items
	var nearest: Enemy = null
	var distance_squared: float = items.fire_spread_radius * items.fire_spread_radius
	for candidate in origin.get_tree().get_nodes_in_group("combat_enemies"):
		if candidate == origin or not is_instance_valid(candidate) or candidate.is_queued_for_deletion(): continue
		if not candidate.targetable or candidate.is_retiring or candidate.health_component.current_health <= 0.0: continue
		if candidate.has_status(Unit.State.BURNING): continue
		var distance: float = origin.global_position.distance_squared_to(candidate.global_position)
		if distance <= distance_squared:
			nearest = candidate
			distance_squared = distance
	if nearest == null: return
	# One roll for this newly burning enemy, never one roll per tick or candidate.
	if not Global.get_chance_succes(items.fire_spread_chance): return
	load("res://effects/fire_status.gd").apply(nearest, entry.key, template, entry.settings, entry.scaled)
