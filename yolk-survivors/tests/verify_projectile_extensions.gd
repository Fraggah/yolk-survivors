extends SceneTree
func _initialize(): call_deferred("verify")
func shot(piercing: int, bounces: int):
 var projectile = load("res://scenes/projectiles/projectile_pistol.tscn").instantiate()
 root.add_child(projectile)
 projectile.set_process(false)
 projectile.setup_projectile(Vector2(100,0),1,false,0,null,500)
 projectile.remaining_piercing = piercing
 projectile.remaining_bounces = bounces
 return projectile
func verify():
 load("res://tests/progression_fixture.gd").prepare(root)
 var global = root.get_node("Global")
 global.game_paused = false
 var enemies: Array = []
 for i in 3:
  var enemy = load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
  root.add_child(enemy)
  enemy.position = Vector2(100 + i*100, 0)
  enemy.set_process(false)
  enemy.set_physics_process(false)
  enemies.append(enemy)
 var hurtboxes = enemies.map(func(enemy): return enemy.get_node("HurtboxComponent"))
 var normal = shot(0,0)
 normal._on_hitbox_component_on_hit_hurtbox(hurtboxes[0])
 assert(normal.is_queued_for_deletion())
 var pierce = shot(1,0)
 assert(pierce.hitbox.claim_hit(hurtboxes[0]))
 assert(not pierce.hitbox.claim_hit(hurtboxes[0]))
 pierce._on_hitbox_component_on_hit_hurtbox(hurtboxes[0])
 assert(not pierce.is_queued_for_deletion() and pierce.remaining_piercing == 0)
 pierce._on_hitbox_component_on_hit_hurtbox(hurtboxes[0])
 assert(not pierce.is_queued_for_deletion())
 pierce._on_hitbox_component_on_hit_hurtbox(hurtboxes[1])
 assert(pierce.is_queued_for_deletion())
 var bounce = shot(0,1)
 bounce._on_hitbox_component_on_hit_hurtbox(hurtboxes[0])
 assert(not bounce.is_queued_for_deletion() and bounce.remaining_bounces == 0)
 assert(is_equal_approx(bounce.velocity.length(),100))
 bounce._on_hitbox_component_on_hit_hurtbox(hurtboxes[1])
 assert(bounce.is_queued_for_deletion())
 var chain = shot(0,2)
 chain._on_hitbox_component_on_hit_hurtbox(hurtboxes[0])
 chain._on_hitbox_component_on_hit_hurtbox(hurtboxes[1])
 assert(not chain.is_queued_for_deletion() and chain.remaining_bounces == 0)
 chain._on_hitbox_component_on_hit_hurtbox(hurtboxes[2])
 assert(chain.is_queued_for_deletion())
 var limited = shot(0,1)
 limited.max_distance = 50
 limited._on_hitbox_component_on_hit_hurtbox(hurtboxes[0])
 assert(not limited.is_queued_for_deletion() and is_inf(limited.max_distance), "Bounce removes the initial range cap")
 limited._on_hitbox_component_on_hit_hurtbox(hurtboxes[1])
 assert(limited.is_queued_for_deletion(), "Bounce still ends on its last impact")
 var stats = load("res://resources/unit_stats.gd").new()
 stats.apply_stat_change("piercing",2)
 stats.apply_stat_change("bounces",3)
 for folder in ["knifer","hydrant","the_bloody","corpse_l","smasher"]:
  for tier in range(1,5):
   var filename = "bloody" if folder == "the_bloody" else folder
   var item = load("res://resources/items/weapons/range/%s/item_%s_%d.tres" % [folder,filename,tier])
   assert(item.stats.piercing >= 0)
   assert(item.stats.bounces >= 0)
   assert(item.get_effective_piercing(stats) == item.stats.piercing + 2)
   assert(item.get_effective_bounces(stats) == item.stats.bounces + 3)
 for enemy in enemies: enemy.queue_free()
 await process_frame
 for mode in ["piercing", "bounce"]:
  var targets: Array = []
  for i in 2:
   var enemy = load("res://scenes/units/enemies/enemy_chaser_mid.tscn").instantiate()
   enemy.stats = enemy.stats.duplicate()
   enemy.stats.health = 100
   root.add_child(enemy)
   enemy.position = Vector2(100 + i*100, 0)
   enemy.set_process(false)
   enemy.set_physics_process(false)
   targets.append(enemy)
  var moving = shot(1 if mode == "piercing" else 0, 1 if mode == "bounce" else 0)
  moving.velocity = Vector2(200,0)
  moving.set_process(true)
  for frame in 100: await physics_frame
  assert(targets[0].health_component.current_health == 99, mode + " first actual hit")
  assert(targets[1].health_component.current_health == 99, mode + " second actual hit")
  for target in targets: target.queue_free()
  await process_frame
 print("PASS normal/pierce/bounce/chains, actual collision damage, duplicate-hit guard, range, 20 weapon tiers and item stat bonuses")
 quit()
