extends "res://scenes/projectiles/catalogue_projectile.gd"

var armed := false
var contacted := false

func configure_effects(settings: RangedSettings) -> void:
	super.configure_effects(settings)
	if effects:
		hitbox.base_damage = explosion_base_damage * effects.corn_contact_damage_multiplier
		hitbox.damage = hitbox.base_damage

func _process(delta: float) -> void:
	if Global.game_paused or contacted or exploded or is_queued_for_deletion(): return
	var remaining := maxf(0.0, max_distance - distance_travelled)
	var movement := (velocity * delta).limit_length(remaining)
	global_position += movement
	distance_travelled += movement.length()
	if distance_travelled >= max_distance: finish()

func _on_hitbox_component_on_hit_hurtbox(hurtbox: HurtboxComponent) -> void:
	if Global.game_paused or contacted or is_queued_for_deletion(): return
	contacted = true
	hit_targets[hurtbox.get_instance_id()] = true
	var luck: float = hitbox.source.stats.luck if is_instance_valid(hitbox.source) and hitbox.source is Unit else 0.0
	if effects and randf() < effects.get_corn_explosion_chance(luck):
		armed = true
		velocity = Vector2.ZERO
		hide()
		hitbox.disable()
		# Finish this physics contact before creating new collision shapes.
		call_deferred("detonate")
	else:
		finish()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if not armed: finish()

func detonate() -> void:
	if exploded or Global.game_paused or not effects or not armed: return
	if effects.popcorn_scene:
		var popcorn := effects.popcorn_scene.instantiate() as Projectile
		(get_tree().current_scene if get_tree().current_scene else get_tree().root).add_child(popcorn)
		popcorn.global_position = global_position
		popcorn.setup_projectile(Vector2.from_angle(randf() * TAU) * effects.popcorn_speed, explosion_base_damage * effects.popcorn_damage_multiplier, hitbox.critical, 0.0, hitbox.source, effects.popcorn_range * Global.GAME_ENTITY_SCALE)
		popcorn.hitbox.knockback_power = hitbox.knockback_power
		popcorn.hitbox.roll_critical_per_target = hitbox.roll_critical_per_target
		popcorn.hitbox.critical_chance = hitbox.critical_chance
		popcorn.hitbox.critical_multiplier = hitbox.critical_multiplier
		popcorn.hitbox.life_steal_chance = hitbox.life_steal_chance
		popcorn.hitbox.weapon_damage_record = hitbox.weapon_damage_record
		popcorn.hitbox.status_effects.assign(hitbox.status_effects)
		popcorn.remaining_piercing = remaining_piercing
		popcorn.remaining_bounces = remaining_bounces
	var source_stats: UnitStats = hitbox.source.stats if is_instance_valid(hitbox.source) and hitbox.source is Unit else null
	if source_stats:
		explosion_base_damage = maxf(0.0, explosion_base_damage + effects.get_corn_explosion_bonus(source_stats.luck) * ItemWeapon.status_damage_multiplier(hitbox.weapon_damage_record, source_stats))
	super.detonate()
