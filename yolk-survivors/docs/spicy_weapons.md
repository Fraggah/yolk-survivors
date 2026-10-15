# Picantes: first attack pass

Morrón and Jalapeño are active equipables in selection and shop. Other peppers remain art-only previews; pets remain previews. Copies occupy separate weapon slots and attack independently. There is currently one balance tier, without tier fusion.

Following the design document's implementation order, final stat multipliers (+10% total Luck / -10% total Damage %) are pending the shared modifier layer. They are not applied as additive stat points.

Tune `resources/items/weapons/spicy/stats_bell_pepper.tres` in the editor: damage, cooldown, max_range (seed travel distance), projectile_speed, knockback, crit_chance, crit_damage, life_steal, piercing, bounces and recoil. The ranged_settings subresource controls projectile_count. Defaults: 3 seeds per 0.8 seconds, 5 base damage, 650 speed, 450 range before entity scale. Each seed chooses an independent angle across 360 degrees, even with no enemies around. Damage uses the player's general damage bonus, not melee/ranged flat damage; attack speed, critical chance and lifesteal use existing systems.

The seed collision/visual are in `scenes/projectiles/projectile_pepper_seed.tscn`. Rotation stays upright for the pepper; shots do not select a target. Pause and wave cleanup use the normal weapon/projectile lifecycle.

## Jalapeño

Tune `resources/items/weapons/spicy/stats_jalapeno.tres`: damage per tick, cooldown between ticks, max_range (horizontal aura radius before entity scale), knockback, critical and lifesteal. Defaults: 3 damage every 0.5 seconds, radius 160, Y ratio 0.6. Attack speed affects the interval. Aura damage and visuals are centered on the player regardless of weapon-slot position. The aura_settings subresource controls Y ratio, color, opacity and breathing speed/strength. Its soft shader stays within the effective oval, without a hard border. Multiple copies tick independently; visuals overlap.

The +5% total Armor / -10% total movement speed are pending the shared final stat multiplier stage, like Morrón's modifiers.
