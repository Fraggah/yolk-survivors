extends Projectile

var effects: RangedSettings
var fuse_left := 0.0
var exploded := false
var explosion_base_damage := 0.0

func configure_effects(settings: RangedSettings) -> void:
	effects = settings
	if effects:
		fuse_left = effects.fuse
		hitbox.launch_on_hit = effects.applies_airbourne
		if effects.applies_airbourne:
			hitbox.launch_direction = velocity.normalized()
			hitbox.launch_speed = effects.airbourne_speed * (hitbox.source.stats.final_multiplier("knockback") if hitbox.source is Unit else 1.0)
			hitbox.launch_duration = effects.airbourne_duration
			hitbox.launch_damage = hitbox.base_damage * effects.airbourne_damage_multiplier
			hitbox.cancel_knockback_on_hit = true
			hitbox.knockback_power = 0.0
		if effects.explodes:
			# Grenades deliver their damage once through the blast, not through contact too.
			explosion_base_damage = hitbox.base_damage
			hitbox.base_damage = 0.0
			hitbox.damage = 0.0

func _process(delta: float) -> void:
	if not effects or not effects.explodes:
		super._process(delta)
		return
	if Global.game_paused or exploded: return
	var movement := (velocity * delta).limit_length(maxf(0.0, max_distance - distance_travelled))
	global_position += movement
	distance_travelled += movement.length()
	fuse_left -= delta
	if fuse_left <= 0.0: detonate()

func _on_hitbox_component_on_hit_hurtbox(hurtbox: HurtboxComponent) -> void:
	if effects and effects.explodes:
		if Global.game_paused or exploded: return
		if effects.explode_on_impact: call_deferred("detonate")
		else: velocity = Vector2.ZERO
		return
	super._on_hitbox_component_on_hit_hurtbox(hurtbox)

func detonate() -> void:
	if exploded or Global.game_paused: return
	exploded = true
	hitbox.base_damage = explosion_base_damage
	var effect = load("res://scenes/projectiles/ranged_area_effect.gd").new()
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position
	effect.setup(hitbox, effects, false)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if not effects or not effects.explodes: queue_free()
