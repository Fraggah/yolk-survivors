extends Node
class_name HealthComponent

signal on_unit_hit
signal on_unit_died
signal on_health_changed(current: float, max: float)

var debug_invulnerable := false

var max_health := 1.0
var current_health := 1.0

func setup(stats: UnitStats) -> void:
	max_health = maxf(1.0, stats.health)
	current_health = max_health
	on_health_changed.emit(current_health, max_health)

func take_damage(value: float) -> void:
	if current_health <= 0 or Global.game_paused or debug_invulnerable: return
	
	if owner is Player and is_instance_valid(owner.passive_items) and owner.passive_items.shell_invulnerability > 0.0: return
	if owner is Player and is_instance_valid(owner.passive_items) and value >= current_health and owner.passive_items.prevent_lethal():
		current_health = minf(1.0, max_health)
		on_health_changed.emit(current_health, max_health)
		return
	current_health -= value
	current_health = max(current_health, 0) #Selecciona el valor mas alto, para no tener valores negativos
	
	on_unit_hit.emit()
	on_health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		current_health = 0
		on_unit_died.emit()
		die()

func heal(amount: float) -> void:
	if current_health <= 0: return
	
	current_health += amount
	current_health = min(current_health, max_health)
	on_health_changed.emit(current_health, max_health)

func die() -> void:
	owner.queue_free()
