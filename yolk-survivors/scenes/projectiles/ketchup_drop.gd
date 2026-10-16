extends Projectile
var pool: Node
var leased := true

func activate() -> void:
	leased = true
	distance_travelled = 0.0
	max_distance = INF
	remaining_piercing = 0
	remaining_bounces = 0
	unlimited_piercing = false
	hit_targets.clear()
	hitbox.status_effects.clear()
	hitbox.weapon_damage_record = {}
	hitbox.life_steal_chance = 0.0
	hitbox.source = null
	hitbox.enable()
	add_to_group("projectiles")
	show()
	set_process(true)

func deactivate() -> void:
	leased = false
	set_process(false)
	hide()
	remove_from_group("projectiles")
	hitbox.disable()

func finish() -> void:
	if not pool:
		super.finish()
		return
	if not leased: return
	deactivate()
	pool.release.call_deferred(self)

func _on_hitbox_component_on_hit_hurtbox(hurtbox: HurtboxComponent) -> void:
	if leased: super._on_hitbox_component_on_hit_hurtbox(hurtbox)

func _draw() -> void:
	var points := PackedVector2Array([Vector2(-10,0),Vector2(-2,-4),Vector2(4,-4),Vector2(7,-2),Vector2(8,0),Vector2(7,2),Vector2(4,4),Vector2(-2,4),Vector2(-10,0)])
	draw_colored_polygon(points,Color("d82e22"))
	draw_polyline(points,Color("58201a"),1.5,true)
	draw_line(Vector2(0,-2),Vector2(4,-2),Color("ff8b57"),1.5,true)
