# Picantes: first attack pass

All ten peppers are active equipables in selection and shop. Pets remain previews. Copies occupy separate weapon slots and attack independently. There is currently one development balance tier, without tier fusion; minimum-tier restrictions remain deferred.

Final modifiers are configured on each `item_<id>.tres` under `final_stat_modifiers`, with the Reaper's flat health cost under `health_drain_per_second`. Equipped percentages add: two +10% copies give a final ×1.20, two −10% copies give ×0.80. Positive and negative modifiers of the same stat net together. The final layer runs after character conversions, items and level upgrades, and is removed immediately when selling/combining equipment. Recalculation never compounds a previous result. Factors cannot go below zero.

| Pepper | Final buff | Final debuff |
|---|---|---|
| Morrón | Luck +10% | Damage −10% |
| Jalapeño | Armor +5% | Movement speed −10% |
| Habanero | AoE +10% | Critical chance −10% |
| Cayenne | Fire tick frequency +10% | Movement speed −5% |
| Poblano | Block chance +5% | Block effectiveness −5% |
| Carolina Reaper | Damage +5% | 1 HP/s per copy |
| Ghost Pepper | Slow strength +5% | Knockback −5% |
| Ají amarillo | Attack frequency +5% | Critical multiplier −5% |
| Scotch Bonnet | Effect duration +5% | Enemy population rate +5% |
| Rocoto | Knockback +5% | Enemy movement speed +5% |

Bonus-based stats scale their effective total: AoE +10% works with zero ordinary AoE bonus; critical chance includes the weapon's intrinsic chance; damage includes flat damage and general bonuses. Armor/Luck/block chance scale their numeric totals, so a zero base stays zero. A negative numeric stat retains its sign. Slow strength scales the amount removed from movement speed, capped at full immobilization. Duration extends burns, slows, holds and persistent pepper effects, without delaying attacks or anticipation. Enemy population uses faster non-guaranteed spawn scheduling, preserving hard population caps and guaranteed introductions. Enemy speed scales after wave/profile modifiers. Reaper cost bypasses armor/block, pauses with gameplay and resets its fractional timer between waves; it can kill the player.

Tune `resources/items/weapons/spicy/stats_bell_pepper.tres` in the editor: damage, cooldown, max_range (seed travel distance), projectile_speed, knockback, crit_chance, crit_damage, life_steal, piercing, bounces and recoil. The ranged_settings subresource controls projectile_count. Defaults: 3 seeds per 0.8 seconds, 5 base damage, 650 speed, 450 range before entity scale. Each seed chooses an independent angle across 360 degrees, even with no enemies around. Damage uses the player's general damage bonus, not melee/ranged flat damage; attack speed, critical chance and lifesteal use existing systems.

The seed collision/visual are in `scenes/projectiles/projectile_pepper_seed.tscn`. Rotation stays upright for the pepper; shots do not select a target. Pause and wave cleanup use the normal weapon/projectile lifecycle.

## Jalapeño

Tune `resources/items/weapons/spicy/stats_jalapeno.tres`: damage per tick, cooldown between ticks, max_range (horizontal aura radius before entity scale), knockback, critical and lifesteal. Defaults: 3 damage every 0.5 seconds, radius 160, Y ratio 0.6. Attack speed affects the interval. Aura damage and visuals are centered on the player regardless of weapon-slot position. The aura_settings subresource controls Y ratio, color, opacity and breathing speed/strength. Its soft shader stays within the effective oval, without a hard border. Multiple copies tick independently; visuals overlap.

The final Armor and movement modifiers are active while equipped.

## Habanero

Tune `resources/items/weapons/spicy/stats_habanero.tres`: damage (initial explosion), cooldown between volleys, max_range (maximum distance from player), knockback, critical and lifesteal. The spicy_explosion_settings subresource controls explosion_count, minimum_distance, explosion_radius, area_y_ratio, anticipation, visual_duration, color, opacity, burn_duration, burn_interval and burn_damage_multiplier. Distances use the same entity scale as other weapons.

Defaults: 3 random oval explosions every 2.4 seconds, 8 initial damage, 95 radius, 0.25-second heat anticipation; burn for 3 seconds with 35% of initial damage per 0.5-second tick. Position selection never targets enemies and is clamped to the arena surface. Each equipped copy maintains one burn per enemy: subsequent hits refresh its duration while preserving tick timing; different copies stack independently. Initial hit and burn use the existing damage/critical/lifesteal recording path. Effects pause and join projectile cleanup at wave transitions.

The final AoE and critical chance modifiers are active while equipped.

## Remaining seven attacks

Each has `stats_<id>.tres` in the same `resources/items/weapons/spicy/` folder. WeaponStats controls base damage, cooldown, critical, lifesteal, knockback and max_range. The `spicy_pattern` subresource controls the attack pattern, affected radius, oval Y ratio, effect lifetime, damage interval, movement/rotation, color/opacity and active-effect cap. Spicy damage uses general damage and Effects; affected radii use AoE. All effects pause and join wave cleanup. Independent copies have separate timers and limits.

| ID | Attack / initial values |
|---|---|
| cayenne | Fire trail only after moving 24 base units; one patch per 0.22 s at most, radius 40, lifetime 3 s, 2 damage per 0.5 s, up to 14 patches per copy. Fire tick speed affects patch ticks. |
| poblano | Pepper itself orbits the player at distance max_range=105, angular speed 2.4 rad/s, contact radius 25, 7 damage per 0.45 s. One persistent orbiter per copy; sprite_scale controls its visual size. |
| carolina_reaper | Two moving fire tornado columns per 3.2 s; speed 130, radius 48, lifetime 6 s, 9 damage per 0.45 s, cap 4. Fire tick speed affects direct ticks too. Column height is visual; damage uses its oval footprint. |
| ghost_pepper | Random arena cloud every 3.5 s, radius 145, lifetime 5 s, 4 damage per 0.6 s, cap 3. |
| aji_amarillo | One seed per 0.14 s, direction rotates 22.5 degrees per shot, damage 4, projectile speed 650, travel range 430. Each copy maintains its own spiral angle. count and spiral_seed_gap_degrees allow multiple seeds per step. |
| scotch_bonnet | Random arena mine every 2 s, arms after 0.6 s, trigger radius 42, blast radius 110, 18 damage once, expires after 16 s, cap 6. The mine shows the pepper and a pulsing glow; the blast expands visually. |
| rocoto | Expanding oval shockwave every 2.5 s, radius 240, duration 0.65 s, 12 damage, knockback 2. Each enemy is hit once per wavefront. |

Cayenne/Reaper also apply the reusable `resources/statuses/spicy_trail_fire.tres` burn (1 damage per 0.5 s for 2 s); tune or replace each weapon's on_hit_effects as desired. Mines/clouds sample valid arena positions rather than selecting enemies. Persistent effects disappear when their weapon is removed. Radius/color/lifetime changes are captured when an effect spawns.

All catalogue buffs/debuffs above are active independently of each pepper's attack timer.
