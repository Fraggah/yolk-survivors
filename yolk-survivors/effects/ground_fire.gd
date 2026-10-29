extends Node2D
## Shared ground-fire field: one contact pass and batched presentation.
@export var enabled := true
@export_range(1,12,1) var flames_per_patch := 4
@export_range(32.0,256.0,8.0) var cell_size := 96.0
@export_range(8,256,8) var contact_updates_per_frame := 32
@export var batch_burning := true
@export_range(2,12,1) var burned_flames_per_unit := 4
class FieldEntry extends RefCounted:
	var id: int
	var radius_squared: float
	var inverse_ratio: float
	var lifetime: float
	var original: Dictionary
class FieldPatch extends RefCounted:
	var ref: WeakRef
	var id: int
	var point: Vector2
	var extent: Vector2
	var radius: float
	var ratio: float
	var lifetime: float
	var fade_in: float
	var fade_out: float
	var flame_height: float
	var opacity: float
	var born: float
	var source: Player
	var hit: HitboxComponent
	var entries: Array[FieldEntry] = []
	var cell_keys: Array[Vector2i] = []
	var visual_slot := -1
	var owner_ref: WeakRef
	var item_effects: Array[StatusEffect] = []
	var fire_ticks := true
	var tick_interval := 0.5
class TrailToken extends Node:
	pass
class FieldRow extends RefCounted:
	var id: int
	var entry: FieldEntry
	var patch: FieldPatch
var patches: Array[FieldPatch] = []
var contacts: Dictionary = {}
var profiles: Dictionary = {}
var cells: Dictionary = {}
@onready var floor_batch: MultiMeshInstance2D = $Floor
@onready var flame_batch: MultiMeshInstance2D = $Flames
@onready var floor_material: ShaderMaterial = $Floor.material
@onready var flame_material: ShaderMaterial = $Flames.material
var visual_capacity := 0
var contact_cursor := 0
var enemy_previous: Dictionary = {}
var floor_buffer := PackedFloat32Array()
var flame_buffer := PackedFloat32Array()
@onready var burned_batch: MultiMeshInstance2D = $BurnedFlames
var burned_visuals: Array[WeakRef] = []
var burned_buffer := PackedFloat32Array()
var burned_capacity := 0
var owner_packets: Dictionary = {}
var column_effects: Dictionary = {}

func _ready() -> void:
	set_process(false)

func register_patch(node: Node2D) -> void:
	if not enabled: return
	var patch := FieldPatch.new()
	patch.ref = weakref(node)
	patch.id = node.get_instance_id()
	patch.point = node.global_position
	patch.radius = node.radius
	patch.ratio = node.settings.area_y_ratio
	patch.lifetime = node.trail_lifetime
	patch.fade_in = node.settings.trail_fade_in
	patch.fade_out = node.settings.trail_fade_out
	patch.flame_height = node.settings.trail_flame_height
	patch.opacity = node.settings.opacity
	patch.born = FireContacts.clock-node.elapsed
	patch.source = node.source
	patch.hit = node.hit
	patch.owner_ref = node.weapon_ref
	patch.item_effects.assign(node.trail_item_effects)
	patch.fire_ticks = node.settings.fire_ticks
	patch.tick_interval = node.settings.tick_interval
	for original in node.trail_entries:
		var entry := FieldEntry.new()
		entry.id = original.id
		entry.radius_squared = original.radius*original.radius
		entry.inverse_ratio = 1.0/original.ratio
		entry.lifetime = original.lifetime
		entry.original = original
		patch.entries.append(entry)
		patch.extent = patch.extent.max(Vector2(original.radius,original.radius*original.ratio))
	patches.append(patch)
	_index_patch(patch)
	set_process(true)

func _release_owner(id: int) -> void:
	if owner_packets.has(id):
		var packet: HitboxComponent = owner_packets[id]
		if is_instance_valid(packet): packet.free()
		owner_packets.erase(id)
	column_effects.erase(id)
	profiles.clear()

func spawn_trail(weapon: Weapon, settings: SpicyPatternSettings, point: Vector2, column: bool = false) -> Node:
	var source := weapon.get_parent() as Player
	var id := weapon.get_instance_id()
	if not owner_packets.has(id):
		owner_packets[id] = HitboxComponent.new()
		weapon.tree_exiting.connect(_release_owner.bind(id),CONNECT_ONE_SHOT)
	var packet: HitboxComponent = owner_packets[id]
	packet.status_effects.clear()
	packet.impact_feedback = false
	packet.setup(weapon.data.get_effective_damage(source.stats),false,0.0,source)
	weapon.weapon_behaviour.configure_hit_criticals(packet)
	packet.life_steal_chance = weapon.data.get_effective_life_steal(source.stats)
	packet.weapon_damage_record = weapon.damage_record
	var patch := FieldPatch.new()
	var token := TrailToken.new()
	add_child(token)
	token.add_to_group("projectiles")
	if column: token.add_to_group("reaper_trails")
	patch.ref = weakref(token)
	patch.id = token.get_instance_id()
	patch.owner_ref = weakref(weapon)
	patch.point = point
	patch.radius = settings.radius*Global.GAME_ENTITY_SCALE*source.stats.get_area_radius_multiplier()
	patch.ratio = settings.area_y_ratio
	patch.fade_in = settings.trail_fade_in
	patch.fade_out = settings.trail_fade_out
	patch.flame_height = settings.trail_flame_height
	patch.opacity = settings.opacity
	patch.born = FireContacts.clock
	patch.source = source
	patch.hit = packet
	patch.item_effects.assign(source.stats.attack_effects)
	patch.fire_ticks = settings.fire_ticks
	patch.tick_interval = settings.tick_interval
	var originals: Array[Dictionary] = []
	if column:
		if not column_effects.has(id):
			var effects: Array[StatusEffect] = []
			for effect in weapon.data.on_hit_effects:
				if not effect: continue
				var copy: StatusEffect = effect.duplicate()
				copy.damage *= settings.column_trail_damage_multiplier
				copy.set_meta("stack_id","ReaperTrail_%s_%s" % [id,effect.get_instance_id()])
				effects.append(copy)
			column_effects[id] = effects
		originals.append({"id":id,"record":weapon.damage_record,"radius":patch.radius,"ratio":patch.ratio,"lifetime":settings.lifetime*source.stats.effect_duration_multiplier(),"damage":packet.base_damage*settings.column_trail_damage_multiplier,"effects":column_effects[id]})
	else:
		for equipped in weapon.weapon_behaviour.trail_contributors():
			var config: SpicyPatternSettings = equipped.data.stats.spicy_pattern
			originals.append({"id":equipped.get_instance_id(),"record":equipped.damage_record,"radius":config.radius*Global.GAME_ENTITY_SCALE*source.stats.get_area_radius_multiplier(),"ratio":config.area_y_ratio,"lifetime":config.lifetime*source.stats.effect_duration_multiplier(),"damage":equipped.data.get_effective_damage(source.stats),"effects":equipped.data.on_hit_effects})
	for original in originals:
		var entry := FieldEntry.new()
		entry.id = original.id
		entry.radius_squared = original.radius*original.radius
		entry.inverse_ratio = 1.0/original.ratio
		entry.lifetime = original.lifetime
		entry.original = original
		patch.entries.append(entry)
		patch.radius = maxf(patch.radius,original.radius)
		patch.lifetime = maxf(patch.lifetime,entry.lifetime)
		patch.extent = patch.extent.max(Vector2(original.radius,original.radius*original.ratio))
	patches.append(patch)
	_index_patch(patch)
	set_process(true)
	return token

func register_burning(visual: Node2D) -> void:
	burned_visuals.append(weakref(visual))
	set_process(true)

func _index_patch(patch: FieldPatch) -> void:
	var first := Vector2i(((patch.point-patch.extent)/cell_size).floor())
	var last := Vector2i(((patch.point+patch.extent)/cell_size).floor())
	var rows: Array[FieldRow] = []
	for entry in patch.entries:
		var row := FieldRow.new()
		row.id = row.get_instance_id()
		row.entry = entry
		row.patch = patch
		rows.append(row)
	for x in range(first.x,last.x+1):
		for y in range(first.y,last.y+1):
			var key := Vector2i(x,y)
			patch.cell_keys.append(key)
			if not cells.has(key): cells[key] = {}
			var bucket: Dictionary = cells[key]
			for row in rows:
				if not bucket.has(row.entry.id): bucket[row.entry.id] = []
				bucket[row.entry.id].append(row)

func _unindex_patch(patch: FieldPatch) -> void:
	for key in patch.cell_keys:
		var bucket: Dictionary = cells.get(key,{})
		for entry in patch.entries:
			var rows: Array = bucket.get(entry.id,[])
			for i in range(rows.size()-1,-1,-1):
				if rows[i].patch==patch: rows.remove_at(i)
			if rows.is_empty(): bucket.erase(entry.id)
		if bucket.is_empty(): cells.erase(key)
	patch.cell_keys.clear()

func _exit_tree() -> void:
	for packet in owner_packets.values():
		if is_instance_valid(packet): packet.free()
	owner_packets.clear()
	column_effects.clear()
	profiles.clear()
	contacts.clear()
	cells.clear()
	patches.clear()

func _process(_delta: float) -> void:
	if Global.game_paused: return
	var started := Time.get_ticks_usec() if FireContacts.profile_enabled else 0
	var alive: Array[FieldPatch] = []
	for patch in patches:
		var node = patch.ref.get_ref()
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			_unindex_patch(patch)
			continue
		var owner = patch.owner_ref.get_ref()
		if FireContacts.clock>=patch.born+patch.lifetime or not is_instance_valid(owner) or owner.is_queued_for_deletion() or not is_instance_valid(patch.source) or patch.source.health_component.current_health<=0.0:
			node.queue_free()
			_unindex_patch(patch)
			continue
		alive.append(patch)
	patches = alive
	FireContacts.finish_profile("ground_index",started)
	var contact_started := Time.get_ticks_usec() if FireContacts.profile_enabled else 0
	var intervals: Dictionary = {}
	var samples: Array = FireContacts.samples.values()
	for update in mini(contact_updates_per_frame,samples.size()):
		contact_cursor %= samples.size()
		var sample = samples[contact_cursor]
		contact_cursor += 1
		var enemy := sample.enemy as Enemy
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.health_component.current_health<=0.0: continue
		var enemy_id: int = enemy.get_instance_id()
		var point: Vector2 = enemy.global_position
		var previous: Vector2 = enemy_previous.get(enemy_id,sample.previous)
		enemy_previous[enemy_id] = point
		var current: Dictionary = {}
		var crossed: Dictionary = {}
		var visited: Dictionary = {}
		var first := Vector2i((point.min(previous)/cell_size).floor())
		var last := Vector2i((point.max(previous)/cell_size).floor())
		for x in range(first.x,last.x+1):
			for y in range(first.y,last.y+1):
				var bucket: Dictionary = cells.get(Vector2i(x,y),{})
				for weapon_id in bucket:
					if current.has(weapon_id): continue
					for value in bucket[weapon_id]:
						var row: FieldRow = value
						if visited.has(row.id): continue
						visited[row.id] = true
						var patch := row.patch
						var entry := row.entry
						if FireContacts.clock-patch.born>=entry.lifetime: continue
						var offset := point-patch.point
						var end := Vector2(offset.x,offset.y*entry.inverse_ratio)
						if end.length_squared()<=entry.radius_squared:
							current[weapon_id] = row
							crossed[weapon_id] = row
							break
						var old_offset := previous-patch.point
						var start := Vector2(old_offset.x,old_offset.y*entry.inverse_ratio)
						var travel := end-start
						var t := clampf(-start.dot(travel)/maxf(0.000001,travel.length_squared()),0.0,1.0)
						if (start+travel*t).length_squared()<=entry.radius_squared: crossed[weapon_id] = row
		var hit_groups: Dictionary = {}
		var ignition_groups: Dictionary = {}
		for id in current:
			var row: FieldRow = current[id]
			var source_id := row.patch.source.get_instance_id()
			if not intervals.has(source_id): intervals[source_id] = row.patch.source.stats.get_fire_interval()
			var interval: float = intervals[source_id] if row.patch.fire_ticks else row.patch.tick_interval
			if FireContacts.claim_ground(enemy_id,id,interval): _append(hit_groups,row)
		var old: Dictionary = contacts.get(enemy_id,{})
		for id in crossed:
			if old.has(id): continue
			if FireContacts.claim_ground(enemy_id,id,FireContacts.ground_ignition_refresh,true): _append(ignition_groups,crossed[id])
		for group in hit_groups.values(): _apply_group(enemy,group,false)
		for group in ignition_groups.values(): _apply_group(enemy,group,true)
		contacts[enemy_id] = current
	for id in contacts.keys():
		if not FireContacts.samples.has(id):
			contacts.erase(id)
			enemy_previous.erase(id)
	FireContacts.finish_profile("ground_queries",contact_started)
	var visual_started := Time.get_ticks_usec() if FireContacts.profile_enabled else 0
	_update_visuals()
	FireContacts.finish_profile("ground_buffers",visual_started)
	var burn_started := Time.get_ticks_usec() if FireContacts.profile_enabled else 0
	_update_burning(_delta)
	FireContacts.finish_profile("burn_buffers",burn_started)
	FireContacts.finish_profile("ground_field",started)
	if patches.is_empty():
		contacts.clear()
		enemy_previous.clear()
		profiles.clear()
		if burned_visuals.is_empty(): set_process(false)

func _update_burning(delta: float) -> void:
	var alive: Array[WeakRef] = []
	for reference in burned_visuals:
		var visual = reference.get_ref()
		if not is_instance_valid(visual) or visual.is_queued_for_deletion(): continue
		visual._process(delta)
		if not visual.is_queued_for_deletion(): alive.append(reference)
	burned_visuals = alive
	var total := alive.size()*burned_flames_per_unit
	if total>burned_capacity:
		burned_capacity = maxi(128,total*2)
		burned_batch.multimesh.instance_count = burned_capacity
		burned_buffer.resize(burned_capacity*16)
	var index := 0
	for reference in alive:
		var visual = reference.get_ref()
		if not visual.settings: continue
		var sprite: Sprite2D = visual.target.sprite
		var rect := sprite.get_rect()
		var sprite_transform := sprite.global_transform
		for i in burned_flames_per_unit:
			var phase := i*2.399963+float(visual.get_instance_id()%31)
			var height: float = rect.size.y*visual.settings.flame_sprite_height*(0.8+0.2*sin(phase))
			var anchor := Vector2(rect.get_center().x+sin(phase)*rect.size.x*0.32,rect.end.y-rect.size.y*(0.18+0.28*float(i)/burned_flames_per_unit))
			var instance_transform := sprite_transform*Transform2D(0.0,Vector2(height,height*1.25),0.0,anchor-Vector2(0,height*0.45))
			var at := index*16
			burned_buffer[at] = instance_transform.x.x
			burned_buffer[at+1] = instance_transform.y.x
			burned_buffer[at+3] = instance_transform.origin.x
			burned_buffer[at+4] = instance_transform.x.y
			burned_buffer[at+5] = instance_transform.y.y
			burned_buffer[at+7] = instance_transform.origin.y
			burned_buffer[at+8] = 1.0
			burned_buffer[at+9] = 1.0
			burned_buffer[at+10] = 1.0
			burned_buffer[at+11] = visual.fade*visual.settings.flame_opacity
			burned_buffer[at+12] = -1.0
			burned_buffer[at+13] = 1000000.0
			burned_buffer[at+14] = 0.01
			burned_buffer[at+15] = 0.2
			index += 1
	burned_batch.multimesh.buffer = burned_buffer
	burned_batch.multimesh.visible_instance_count = index

func _append(groups: Dictionary, row: FieldRow) -> void:
	var source_id: int = row.patch.source.get_instance_id()
	if not groups.has(source_id): groups[source_id] = []
	groups[source_id].append(row)

func _apply_group(enemy: Enemy, rows: Array, ignition: bool) -> void:
	var patch: FieldPatch = rows[0].patch
	var entries: Array[Dictionary] = []
	var key := str(patch.source.get_instance_id())
	for value in rows:
		var row: FieldRow = value
		entries.append(row.entry.original)
		key += ":%s/%s" % [row.entry.id,row.entry.original.damage]
	if profiles.has(key):
		var profile: Dictionary = profiles[key]
		patch.hit.base_damage = profile.damage
		patch.hit.damage = profile.damage
		patch.hit.weapon_damage_record = profile.record
		patch.hit.status_effects.assign(profile.effects)
	else:
		var profile: Dictionary = load("res://effects/trail_hit_profile.gd").build(entries,patch.item_effects)
		profiles[key] = profile
		patch.hit.base_damage = profile.damage
		patch.hit.damage = profile.damage
		patch.hit.weapon_damage_record = profile.record
		patch.hit.status_effects.assign(profile.effects)
	if ignition:
		for effect in patch.hit.status_effects:
			if effect and effect.kind==StatusEffect.Kind.FIRE and Global.get_chance_succes(effect.chance):
				load("res://effects/status_controller.gd").apply_effect(enemy,effect,patch.hit)
	else:
		enemy._on_hurtbox_component_on_damage(patch.hit)

func _write_instance(buffer: PackedFloat32Array, index: int, point: Vector2, size: Vector2, opacity: float, timing: Color) -> void:
	var at := index*16
	buffer[at] = size.x
	buffer[at+1] = 0.0
	buffer[at+2] = 0.0
	buffer[at+3] = point.x
	buffer[at+4] = 0.0
	buffer[at+5] = size.y
	buffer[at+6] = 0.0
	buffer[at+7] = point.y
	buffer[at+8] = 1.0
	buffer[at+9] = 1.0
	buffer[at+10] = 1.0
	buffer[at+11] = opacity
	buffer[at+12] = timing.r
	buffer[at+13] = timing.g
	buffer[at+14] = timing.b
	buffer[at+15] = timing.a

func _update_visuals() -> void:
	if patches.size()>visual_capacity:
		visual_capacity = maxi(64,patches.size()*2)
		floor_batch.multimesh.instance_count = visual_capacity
		flame_batch.multimesh.instance_count = visual_capacity*flames_per_patch
		floor_buffer.resize(visual_capacity*16)
		flame_buffer.resize(visual_capacity*flames_per_patch*16)
	floor_batch.multimesh.visible_instance_count = patches.size()
	flame_batch.multimesh.visible_instance_count = patches.size()*flames_per_patch
	for i in patches.size():
		var patch: FieldPatch = patches[i]
		var timing := Color(patch.born,patch.lifetime,patch.fade_in,patch.fade_out)
		var point: Vector2 = patch.point
		_write_instance(floor_buffer,i,point,Vector2(patch.radius*2.0,patch.radius*patch.ratio*2.0),0.35,timing)
		for j in flames_per_patch:
			var angle := (i*flames_per_patch+j)*2.399963
			var height: float = patch.radius*patch.flame_height
			var offset: Vector2 = Vector2(cos(angle),sin(angle)*patch.ratio)*patch.radius*0.55
			_write_instance(flame_buffer,i*flames_per_patch+j,point+offset-Vector2(0,height*0.4),Vector2(height,height*1.3),patch.opacity,timing)
	floor_batch.multimesh.buffer = floor_buffer
	flame_batch.multimesh.buffer = flame_buffer
	floor_material.set_shader_parameter("elapsed",FireContacts.clock)
	flame_material.set_shader_parameter("elapsed",FireContacts.clock)
