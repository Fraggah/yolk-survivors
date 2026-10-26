extends HealthComponent
## All damage routes, including direct component calls, share this phase gate.
signal phase_floor_reached
var vulnerable := false
var health_floor := 0.0
var floor_reported := false
func open_window(phase: int) -> void:
	health_floor = max_health * float(2 - phase) / 3.0
	floor_reported = false
	vulnerable = true
func take_damage(value: float) -> void:
	if not vulnerable or value <= 0 or current_health <= health_floor: return
	var before := current_health
	super.take_damage(minf(value, current_health - health_floor))
	owner.set_meta("last_boss_damage", before - current_health)
	if current_health <= health_floor + 0.00001 and not floor_reported:
		current_health = health_floor
		floor_reported = true
		vulnerable = false
		phase_floor_reached.emit()
func heal(_amount: float) -> void:
	pass
func die() -> void:
	# Encounter owns final cleanup and victory, rather than ordinary kill loot.
	pass
