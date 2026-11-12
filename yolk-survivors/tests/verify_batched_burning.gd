extends SceneTree
var failures := 0
var arena
var fire
func _initialize(): call_deferred("verify")
func check(value: bool, message: String):
	if not value:
		failures += 1
		push_error(message)
func make_enemy():
	var enemy = load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	enemy.stats = enemy.stats.duplicate()
	enemy.stats.block_chance = 0
	enemy.stats.armor = 0
	arena.add_child(enemy)
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.health_component.max_health = 10000
	enemy.health_component.current_health = 10000
	return enemy
func simulate(batch: int, duration: float, contributed: bool, refresh: bool = false) -> Dictionary:
	root.get_node("FireContacts").burn_tick_batch = batch
	var target = make_enemy()
	var packet = load("res://scenes/components/hitbox_component.gd").new()
	packet.setup(0.0, false, 0.0, null)
	var effect = load("res://resources/status_effect.gd").new()
	effect.kind = 0
	effect.damage = 3.0
	effect.duration = duration
	if contributed:
		effect.set_meta("fire_contributions", [
			{"id": 1, "record": {"wave_damage": 0.0, "total_damage": 0.0}, "damage": 3.0, "duration": duration},
			{"id": 2, "record": {"wave_damage": 0.0, "total_damage": 0.0}, "damage": 7.0, "duration": duration + 0.5}])
	fire.apply(target, "TestBurn", packet, effect, true)
	var burn = target.get_node("TestBurn")
	burn.scheduled = false
	burn.set_process(false)
	var events: Array[float] = []
	var before: float = target.health_component.current_health
	for i in 100:
		if burn.is_queued_for_deletion(): break
		if refresh and i == 7: fire.apply(target, "TestBurn", packet, effect, true)
		burn.scheduled = false
		burn.set_process(false)
		burn._advance_fire(0.1)
		var now: float = target.health_component.current_health
		if now < before: events.append(before - now)
		before = now
	var result := {"damage": 10000.0 - before, "events": events}
	target.free()
	packet.free()
	return result
func verify():
	root.get_node("FireContacts").prevent_burning_reapplication = false
	fire = load("res://effects/fire_status.gd")
	load("res://tests/progression_fixture.gd").prepare(root)
	arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	root.get_node("Global").game_paused = false
	for duration in [0.25, 0.5, 1.0, 2.5, 3.7]:
		for contributed in [false, true]:
			for refresh in [false, true]:
				var reference := simulate(1, duration, contributed, refresh)
				var batched := simulate(2, duration, contributed, refresh)
				check(is_equal_approx(reference.damage, batched.damage), "Damage must match for duration=%s contributions=%s refresh=%s: %s vs %s" % [duration, contributed, refresh, reference, batched])
	var odd := simulate(2, 2.5, false)
	check(odd.events == [6.0, 6.0, 3.0], "Five ticks become two double hits and a final single hit: %s" % [odd.events])
	for tier in ["", "_2", "_3", "_4"]:
		var cayenne = load("res://resources/items/weapons/chili/cayenne/stats_cayenne%s.tres" % tier).spicy_pattern
		check(cayenne.trail_spacing == 48.0 and cayenne.radius * 2.0 > cayenne.trail_spacing, "Cayenne has fewer, continuously overlapping patches")
		var reaper = load("res://resources/items/weapons/chili/carolina_reaper/stats_carolina_reaper%s.tres" % tier).spicy_pattern
		check(reaper.column_trail_spacing == 36.0 and reaper.column_trail_radius_multiplier == 1.15, "Reaper trail configuration")
	root.get_node("FireContacts").burn_tick_batch = 2
	root.get_node("FireContacts").prevent_burning_reapplication = true
	print("BATCHED BURNING: ", "PASS" if failures == 0 else "FAIL (%s)" % failures)
	quit(0 if failures == 0 else 1)
