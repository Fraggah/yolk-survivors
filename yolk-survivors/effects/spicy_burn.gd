extends RefCounted
## Habanero delegates its burn to the shared fire state.
static func apply(enemy: Enemy, weapon_id: int, template: HitboxComponent, settings: SpicyExplosionSettings) -> void:
	var effect := StatusEffect.new()
	effect.damage = template.base_damage * settings.burn_damage_multiplier
	effect.duration = settings.burn_duration
	effect.tick_interval = settings.burn_interval
	effect.color = settings.color
	load("res://effects/fire_status.gd").apply(enemy, "HabaneroBurn_%s" % weapon_id, template, effect, true)
