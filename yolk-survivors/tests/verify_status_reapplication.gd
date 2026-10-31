extends SceneTree
var failures := 0
func _initialize(): call_deferred("verify")
func check(value: bool, message: String):
	if not value:
		failures += 1
		push_error(message)
func verify():
	load("res://tests/progression_fixture.gd").prepare(root)
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	root.get_node("Global").game_paused = false
	var scheduler = root.get_node("FireContacts")
	check(scheduler.prevent_burning_reapplication and scheduler.prevent_electric_reapplication, "Native defaults enable both guards")
	var enemy = load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
	enemy.stats = enemy.stats.duplicate()
	enemy.stats.armor = 0
	enemy.stats.block_chance = 0
	arena.add_child(enemy)
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.health_component.max_health = 10000
	enemy.health_component.current_health = 10000
	var packet = load("res://scenes/components/hitbox_component.gd").new()
	packet.setup(1.0, false, 0.0, null)
	var other = load("res://scenes/components/hitbox_component.gd").new()
	other.setup(1.0, false, 0.0, null)
	var effect = load("res://resources/status_effect.gd").new()
	effect.kind = 0
	effect.damage = 3
	effect.duration = 2.5
	var controller = load("res://effects/status_controller.gd")
	var fire = load("res://effects/fire_status.gd")
	controller.apply_effect(enemy, effect, packet)
	var burns = enemy.get_children().filter(func(child): return child.get_script() == fire)
	check(burns.size() == 1, "One initial burn")
	var burn = burns[0]
	burn.scheduled = false
	burn.set_process(false)
	burn._advance_fire(1.0)
	check(enemy.health_component.current_health == 9994, "First double fire tick")
	var strong = effect.duplicate()
	strong.damage = 100
	strong.duration = 10
	for i in 20:
		controller.apply_effect(enemy, strong, other)
		fire.apply(enemy, "AlternativeDirectBurn", other, strong, true)
	check(is_equal_approx(burn.remaining, 1.5) and burn.hit.damage == 3.0, "Neither refresh nor stronger source replaces active burn")
	check(enemy.get_children().filter(func(child): return child.get_script() == fire).size() == 1, "No stacked burn nodes")
	var electric = effect.duplicate()
	electric.kind = 1
	electric.damage = 5
	electric.duration = 1.5
	electric.maximum_chain_targets = 0
	controller.apply_effect(enemy, electric, packet)
	check(enemy.health_component.current_health == 9989, "Electricity and fire can coexist")
	enemy.status_controller._process(0.5)
	var left: float = enemy.status_controller.lightning_left
	for i in 20: controller.apply_effect(enemy, electric, other)
	check(enemy.health_component.current_health == 9989, "No repeated electrical damage while electrified")
	check(enemy.status_controller.lightning_left == left, "Electricity duration is not refreshed")
	burn._advance_fire(1.5)
	check(enemy.health_component.current_health == 9980, "Original fire completes including final single tick")
	controller.apply_effect(enemy, strong, other)
	check(enemy.get_node_or_null("AlternativeDirectBurn") == null, "Guard also covers direct FireState calls")
	check(enemy.get_children().filter(func(child): return child.get_script() == fire and not child.is_queued_for_deletion()).size() == 1, "A fresh burn is allowed after expiration")
	enemy.status_controller._process(2.0)
	other.enable()
	controller.apply_effect(enemy, electric, other)
	check(enemy.health_component.current_health == 9975, "Fresh electrical attack allowed after expiration")
	packet.free()
	other.free()
	print("STATUS REAPPLICATION: ", "PASS" if failures == 0 else "FAIL (%s)" % failures)
	quit(0 if failures == 0 else 1)
