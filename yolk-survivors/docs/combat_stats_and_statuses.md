# Combat statistics and reusable states

All five new fields live on UnitStats and can be changed by ItemPassive or character passives. Block chance retains its existing field. AoE, critical multiplier, block protection and Effects have four level-up tiers. Fire tick speed is item-only and is explicitly excluded from level-up offers.

| Inspector field | Meaning |
|---|---|
| area_of_effect | Percentage bonus to actual affected area. Radius multiplier is sqrt(max(0, 1 + value/100)). Applies to Jalapeño, Habanero, ranged explosions/pits, pan slow area and grater capture. Does not change projectile travel distance. |
| critical_multiplier | Percentage bonus to the weapon's critical damage multiplier: a 2x weapon with +50% becomes 3x. Minimum effective multiplier is 1x. |
| block_chance | Probability of blocking, in percentage points. |
| block_effectiveness | Damage PREVENTED on a successful block; defaults to 50%. Higher is better: 0% receives all damage, 100% prevents all damage. Upgrades add effectiveness. Damage received = damage × (1 - clamp(effectiveness/100, 0, 1)). Armor and block multiply. |
| effects | +1% spicy and status damage, +1% slow and immobilization duration per point. Does not multiply fire duration. Habanero fire inherits its already-scaled damage without double scaling. |
| fire_tick_speed | Percentage bonus to fire tick frequency. Interval = base / (1 + value/100), clamped to at least 0.05 seconds. Only items can offer this stat. |

## Configuring fire and electricity

Create a StatusEffect resource using `resources/status_effect.gd`. Set kind to FIRE or ELECTRICITY. On a weapon ItemWeapon, add it to `on_hit_effects`. On a passive ItemPassive, add it to `on_hit_effects` to grant it to the character's attacks. Enemy UnitStats can use `attack_effects`; a specific HitboxComponent can also have `status_effects`. Effects roll their chance only on the primary hit. Normal weapon/spicy attacks use the common damage, critical and lifesteal path.

Fire fields: damage per tick, duration, tick_interval, color and chance. A burn persists on its victim even after leaving the attack area or after the source disappears. Reapplying the same source/effect refreshes duration without restarting the tick countdown; distinct sources/effects can coexist. Fire ticks do not reapply on-hit effects or get suppressed by the player's contact invulnerability. They use armor but do not roll another block. Burns pause and are cleared when a wave ends. The Habanero adapter retains one burn per equipped copy. Fueguito contact applies `resources/statuses/fueguito_fire.tres` (1 damage per second for 3 seconds by default).

Electricity fields: immediate damage, duration of slow, slow_factor (0.7 = 30% slower), chain_radius and maximum_chain_targets. A primary hit snapshots the nearest same-side units inside an oval with Y ratio 0.6 and spreads once, at application time; secondaries never propagate. New enemies entering later are unaffected. Source Effects scales electric damage and slow duration. `resources/statuses/electricity_default.tres` is a ready-to-use sample; no existing weapon is automatically converted to electricity yet. Player and enemies use the same controller. For future multiplayer the chain stays among players when a player is the primary target.

Runtime implementation: `effects/status_controller.gd` handles electricity and timed movement modifiers; `effects/fire_status.gd` handles fire. `Unit.immobilize_for(duration, source_stats)` exposes timed immobilization. Existing grater hold duration and pan slow duration also use Effects. Different slows retain their own timers and use the strongest current value; they expire without changing base speed. Enemy legacy pan slow and status movement multipliers multiply.

Balance points: UnitStats defaults and character resources, the new upgrades under `resources/items/upgrades/data`, StatusEffect `.tres` resources, and the existing pepper stats `.tres`. Final pepper-specific buff/debuff multipliers remain a separate pending step.

## Statistics panel

Primary: health, regeneration, lifesteal, damage %, melee/ranged damage, attack speed, critical chance, armor, block chance, movement speed, luck and harvesting. Secondary: critical multiplier bonus, AoE, Effects, fire tick speed, block effectiveness, pickup range, piercing and bounces. The shared panel in pause/shop switches using buttons, Tab or gamepad Y, resets to Primary when opened, and reserves the larger page's size so the layout does not jump. Shortcut handling is limited to the panel within the active menu.
