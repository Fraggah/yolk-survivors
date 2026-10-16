extends Node2D
## Electric slow and immobilization state shared by player and enemies.
var slows: Array[Dictionary] = []
var lightning_left := 0.0
var lightning_color := Color(0.5, 0.85, 1.0)
var arcs: Array[Vector2] = []
var electric_duration := 1.5
var electric_elapsed := 0.0
var electric_ray_count := 7
var electric_glow := 1.0
var electric_visual_scale := 1.0
var electric_hit: HitboxComponent
var impact_cooldown := 0.0

func _ready() -> void:
	add_to_group("status_controllers")
	z_as_relative = false
	z_index = 3
	set_process(false)

static func apply_effect(target: Unit, effect: StatusEffect, template: HitboxComponent, spread: bool = true) -> void:
	if not is_instance_valid(target) or target.is_queued_for_deletion() or target.health_component.current_health <= 0.0: return
	if target is Enemy and not target.targetable: return
	if effect.kind == StatusEffect.Kind.FIRE:
		var source_id := template.source.get_instance_id() if is_instance_valid(template.source) else 0
		var effect_id := effect.resource_path if not effect.resource_path.is_empty() else str(effect.get_instance_id())
		load("res://effects/fire_status.gd").apply(target, "Fire_%s_%s" % [source_id, effect_id.hash()], template, effect)
		return
	# Snapshot the primary's neighbors once; secondary applications never propagate.
	var neighbors: Array[Unit] = []
	var source_stats: UnitStats = template.source.stats if is_instance_valid(template.source) and template.source is Unit else null
	var strength := source_stats.get_effect_multiplier() if source_stats else 1.0
	var radius := effect.chain_radius * Global.GAME_ENTITY_SCALE
	if spread and radius > 0.0 and effect.maximum_chain_targets > 0:
		var group := "combat_players" if target is Player else "combat_enemies"
		var candidates: Array = EnemyCrowd.nearby(target.global_position,radius,target.get_instance_id(),effect.maximum_chain_targets) if group=="combat_enemies" and EnemyCrowd.members.size()>32 else target.get_tree().get_nodes_in_group(group)
		for candidate in candidates:
			if candidate == target or not is_instance_valid(candidate) or candidate.is_queued_for_deletion() or candidate.health_component.current_health <= 0.0: continue
			if candidate is Enemy and candidate.is_retiring: continue
			var offset: Vector2 = candidate.global_position - target.global_position
			offset.y /= 0.6
			if offset.length_squared() <= radius * radius: neighbors.append(candidate)
		neighbors.sort_custom(func(a, b): return a.global_position.distance_squared_to(target.global_position) < b.global_position.distance_squared_to(target.global_position))
		if neighbors.size() > effect.maximum_chain_targets: neighbors.resize(effect.maximum_chain_targets)
	var controller = target.status_controller
	var status_duration := effect.duration * strength * (source_stats.effect_duration_multiplier() if source_stats else 1.0)
	controller.add_slow(source_stats.effective_slow(effect.slow_factor) if source_stats else effect.slow_factor, status_duration)
	controller.lightning_left = maxf(controller.lightning_left, status_duration)
	controller.electric_duration = maxf(0.01, controller.lightning_left)
	controller.electric_elapsed = 0.0
	controller.electric_ray_count = effect.electric_ray_count
	controller.electric_glow = effect.electric_glow_strength
	controller.electric_visual_scale = effect.electric_visual_scale
	controller.lightning_color = effect.color
	controller.arcs.clear()
	for neighbor in neighbors: controller.arcs.append(neighbor.global_position)
	# The burst is independent from the target so a lethal impact remains visible.
	if controller.impact_cooldown<=0.0:
		var burst = load("res://effects/electric_impact.gd").new()
		target.get_tree().current_scene.add_child(burst)
		var center: Vector2 = target.sprite.to_global(target.sprite.get_rect().get_center())
		var chain_points: Array[Vector2] = []
		for neighbor in neighbors: chain_points.append(neighbor.sprite.to_global(neighbor.sprite.get_rect().get_center()))
		burst.configure(effect, center, chain_points)
		controller.impact_cooldown = 0.06
	controller.set_process(true)
	if not is_instance_valid(controller.electric_hit):
		controller.electric_hit = HitboxComponent.new()
		controller.electric_hit.collision_layer = 0
		controller.electric_hit.collision_mask = 0
		controller.electric_hit.monitoring = false
		controller.add_child(controller.electric_hit)
	var hit: HitboxComponent = controller.electric_hit
	hit.setup(effect.damage * strength * (source_stats.final_multiplier("damage_percent") if source_stats else 1.0), false, 0.0, template.source)
	hit.status_effects.clear()
	hit.is_status_damage = true
	hit.can_be_blocked = false
	hit.weapon_damage_record = template.weapon_damage_record
	hit.life_steal_chance = template.life_steal_chance
	target.receive_hit(hit)
	controller.queue_redraw()
	for neighbor in neighbors: apply_effect(neighbor, effect, template, false)

func add_slow(factor: float, duration: float) -> void:
	if duration > 0.0:
		for slow in slows:
			if is_equal_approx(slow.factor,clampf(factor,0.0,1.0)):
				slow.left = maxf(slow.left,duration)
				set_process(true)
				return
		slows.append({"factor":clampf(factor, 0.0, 1.0), "left":duration})
		get_parent().status_movement_multiplier = movement_multiplier()
		set_process(true)

func movement_multiplier() -> float:
	var result := 1.0
	for slow in slows: result = minf(result, slow.factor)
	return result

func clear() -> void:
	set_process(false)
	slows.clear()
	get_parent().status_movement_multiplier = 1.0
	lightning_left = 0.0
	electric_elapsed = 0.0
	impact_cooldown = 0.0
	arcs.clear()
	for child in get_parent().get_children():
		if child.get_script() == load("res://effects/fire_status.gd"):
			child.hide()
			child.queue_free()
	queue_redraw()

func _process(delta: float) -> void:
	if Global.game_paused: return
	impact_cooldown = maxf(0.0,impact_cooldown-delta)
	for index in range(slows.size()-1, -1, -1):
		slows[index].left -= delta
		if slows[index].left <= 0.0: slows.remove_at(index)
	get_parent().status_movement_multiplier = movement_multiplier()
	lightning_left = maxf(0.0, lightning_left - delta)
	if lightning_left > 0.0: electric_elapsed += delta
	if lightning_left > 0.0: _submit_rays()
	queue_redraw()
	if slows.is_empty() and lightning_left<=0.0 and impact_cooldown<=0.0: set_process(false)

func _submit_rays() -> void:
	if lightning_left <= 0.0: return
	var unit := get_parent() as Unit
	if not unit or unit.health_component.current_health <= 0.0: return
	var rect := unit.sprite.get_rect()
	var center := to_local(unit.sprite.to_global(rect.get_center()))
	var size := (to_local(unit.sprite.to_global(rect.end)) - to_local(unit.sprite.to_global(rect.position))).abs()
	var extent := Vector2(clampf(size.x * 0.43, 9.0, 55.0), clampf(size.y * 0.43, 12.0, 65.0)) * electric_visual_scale
	ElectricRays.submit_aura(self,center,extent,electric_elapsed,lightning_left,lightning_color,electric_glow,electric_ray_count)
