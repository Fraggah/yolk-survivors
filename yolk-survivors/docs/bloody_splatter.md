# Bloody ketchup splatter

All four tiers fire the approved ketchup capsule art. After an enemy actually takes damage, the capsule emits three ketchup droplets in a 50-degree fan continuing the incoming travel direction, behind that target. Each droplet deals 25% of the capsule's effective rolled hit damage, including its critical once; droplets do not roll another critical. Overkill still uses the capsule's full damage rather than the target's remaining HP. A lethal impact still emits the fan.

The initially struck hurtbox is excluded from its own droplets. Each droplet hits once, cannot recursively splatter, and carries the originating weapon's damage record, lifesteal and on-hit statuses. Normal projectile pause, distance and arena cleanup apply. Confirmed damage is reported by HitboxComponent.damage_dealt, rather than assuming every physics overlap deals damage. New collision shapes are created deferred to avoid physics-query flushing errors.

Balance each tier in `resources/items/weapons/range/the_bloody/stats_bloody_<tier>.tres`, under `ranged_settings`: `splatter_count` = 3, `splatter_damage_multiplier` = 0.25, `splatter_spread_degrees` = 50, `splatter_speed` = 700, `splatter_range_multiplier` = 0.1 (10% of the full weapon range, with entity scale applied once). Capsule damage/cooldown/range remain unchanged. Capsule piercing/bounce modifiers can create one fan per confirmed distinct target; secondary droplets have no extra piercing or bounces.

Regression: `tests/verify_bloody_splatter.gd` covers real capsule and secondary collisions, exact quarter damage, original-target exclusion, no recursive emissions, lethal/critical hits, pause, range and all tier resources.
