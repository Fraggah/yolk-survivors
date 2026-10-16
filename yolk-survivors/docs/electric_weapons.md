# Electric weapon polish

Minipimer is now `ItemWeapon.Type.RANGE` in all four tiers. It uses ranged flat damage, normal ranged aiming/recoil and one spinning saw per shot. The saw expires on its first impact or at maximum range; ordinary piercing/bounce modifiers still work. Its procedural visual rotates independently of travel, with a metal blade, dark outline and cyan electrical glints. Gameplay and spin pause together.

Electric Knife stays melee, with one forward thrust per activation and no damage during recovery. Each successful hit applies electricity through the same on-hit system as the saw.

Each tier's item `.tres` contains an editable electricity subresource under `on_hit_effects`: damage, duration, slow factor, chain radius, maximum secondary targets, chance and color. Initial electricity damage is 3/4/5/6 by tier, duration 1.5 s, movement factor 0.7, propagation radius 65 and at most three secondaries. Propagation happens only from the primary impact and never recursively from secondary enemies. Existing Effects, effect duration and slow strength modifiers apply normally.

Base hit damage, damage scaling, cooldown, accuracy, range, projectile speed and knockback stay in the corresponding tier's `WeaponStats` `.tres`. Minipimer's initial range is 400 and projectile speed 1200. Saw visual radius is 10 with collision radius 8. Existing base damage/cooldown values are preserved. Electric Knife's `melee_settings` subresource controls its normal attack; `hit_count` is 1.

Electric feedback has two independent layers: animated cyan-white sparks with additive glow remain around the sprite for the scaled electricity duration; each application emits a detached oval radial burst plus arcs to secondary targets. A lethal hit keeps its burst visible. Both pause with gameplay, and bursts join wave cleanup. StatusEffect exposes electric_impact_duration (0.38 s), electric_ray_count (7), electric_glow_strength (1) and electric_visual_scale (1), editable in each tier's on_hit_effects subresource. Glow uses layered translucent additive strokes and does not require environment bloom.

Existing resource paths under `resources/items/weapons/melee/immersion_blender/` and its scene are retained to preserve editor/saved-resource references. Runtime category, selection, shop, damage scaling and character restrictions use the item's actual RANGE type.

Regression: `tests/verify_electric_weapons.gd` covers actual saw/knife collisions, electrical propagation/slow, all four tiers, selection/shop availability, pause/spin and projectile range cleanup.
