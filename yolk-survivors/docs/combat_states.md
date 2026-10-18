# Combat states

Unit.State exposes BURNING, SHOKED, SLOW, ROOTED and AIRBOURNE. Query unit.has_status(Unit.State.BURNING), unit.has_status_named("Burning"), or unit.get_active_statuses() for item synergies. Queries read the actual active sources/timers, not visuals, and dead units return no states. Several states can coexist.

Burning remains active while any registered burn source survives. Shoked follows the electric duration, without slowing. Slow represents a nonzero movement reduction; Rooted represents immobilization timers and live pin owners (grater/harpoon). Airbourne uses the existing cooking-glove launch: pushed enemy damages other enemies once each per launch, with weapon damage attribution preserved. Labels for control states follow the sprite and disappear when the state ends; fire/electricity keep their visuals.

Fusilli applies Airbourne in all tiers and has Control, like the glove. Edit effects_fusilli_launcher_<tier>.tres: applies_airbourne, airbourne_speed (520), airbourne_duration (0.45), airbourne_damage_multiplier (0.35). Its collision damage is 35% of its direct projectile damage. The glove retains its existing full collision damage in melee_settings.collision_damage_multiplier.
