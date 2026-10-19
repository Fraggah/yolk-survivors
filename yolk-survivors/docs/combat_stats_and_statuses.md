# Combat statistics and reusable states

All five new fields live on UnitStats and can be changed by ItemPassive or character passives. Block chance retains its existing field. AoE, critical multiplier, block protection and Effects have four level-up tiers. Fire tick speed is item-only and is explicitly excluded from level-up offers.

| Inspector field | Meaning |
|---|---|
| area_of_effect | Percentage bonus to actual affected area. Radius multiplier is sqrt(max(0, 1 + value/100)). Applies to Jalapeño, Habanero, ranged explosions/pits, pan slow area and grater capture. Does not change projectile travel distance. |
| critical_multiplier | Percentage bonus to the weapon's critical damage multiplier: a 2x weapon with +50% becomes 3x. Minimum effective multiplier is 1x. |
| block_chance | Probability of blocking, in percentage points. |
| block_effectiveness | Damage PREVENTED on a successful block; defaults to 50%. Higher is better: 0% receives all damage, 100% prevents all damage. Upgrades add effectiveness. Damage received = damage × (1 - clamp(effectiveness/100, 0, 1)). Armor and block multiply. |
| effects | Flat damage scaled by each weapon/status coefficient; see damage_scaling.md. |
| fire_tick_speed | Percentage bonus to fire tick frequency. Interval = base / (1 + value/100), clamped to at least 0.05 seconds. Only items can offer this stat. |

## Configuring fire and electricity

Create a StatusEffect resource using `resources/status_effect.gd`. Set kind to FIRE or ELECTRICITY. On a weapon ItemWeapon, add it to `on_hit_effects`. On a passive ItemPassive, add it to `on_hit_effects` to grant it to the character's attacks. Enemy UnitStats can use `attack_effects`; a specific HitboxComponent can also have `status_effects`. Effects roll their chance only on the primary hit. Normal weapon/spicy attacks use the common damage, critical and lifesteal path.

Fire fields: damage per tick, duration, tick_interval, color and chance. A burn persists on its victim even after leaving the attack area or after the source disappears. Reapplying the same source/effect refreshes duration without restarting the tick countdown; distinct sources/effects can coexist. Fire ticks do not reapply on-hit effects or get suppressed by the player's contact invulnerability. They use armor but do not roll another block. Burns pause and are cleared when a wave ends. The Habanero adapter retains one burn per equipped copy. Fueguito contact applies `resources/statuses/fueguito_fire.tres` (1 damage per second for 3 seconds by default).

Electricity fields: immediate damage, duration of slow, slow_factor (0.7 = 30% slower), chain_radius and maximum_chain_targets. A primary hit snapshots the nearest same-side units inside an oval with Y ratio 0.6 and spreads once, at application time; secondaries never propagate. New enemies entering later are unaffected. Source Effects scales electric damage only. Electricity does not slow. `resources/statuses/electricity_default.tres` is a ready-to-use sample; no existing weapon is automatically converted to electricity yet. Player and enemies use the same controller. For future multiplayer the chain stays among players when a player is the primary target.

Runtime implementation: `effects/status_controller.gd` handles electricity and timed movement modifiers; `effects/fire_status.gd` handles fire. `Unit.immobilize_for(duration, source_stats)` exposes timed immobilization. Grater hold, harpoon pin and pan slow durations use Crowd control; Airbourne speed and duration also use Crowd control. Different slows retain their own timers and use the strongest current value; they expire without changing base speed. Enemy legacy pan slow and status movement multipliers multiply.

Balance points: UnitStats defaults and character resources, the new upgrades under `resources/items/upgrades/data`, StatusEffect `.tres` resources, and the existing pepper stats `.tres`. Final pepper-specific buff/debuff multipliers remain a separate pending step.

## Statistics panel

Primary: health, regeneration, lifesteal, damage %, melee/ranged damage, attack speed, critical chance, armor, block chance, movement speed, luck and harvesting. Secondary: critical multiplier bonus, AoE, Effects, fire tick speed, block effectiveness, pickup range, piercing and bounces. The shared panel in pause/shop switches using buttons, Tab or gamepad Y, resets to Primary when opened, and reserves the larger page's size so the layout does not jump. Shortcut handling is limited to the panel within the active menu.

## Presentación de quemado v2

FireStatus mantiene sus ticks, duración, robo de vida y fuentes independientes. Los ticks nunca hacen críticos (ver critical_rules.md). El dibujo anterior de tres rombos se reemplaza por FireVisual, un único visual compartido por unidad con un shader: llamas de tamaños/alturas variados, núcleos cálidos, brasas ascendentes y halo de calor oval en la base. El visual sigue el sprite en coordenadas globales, adaptándose a su tamaño y evitando que el cambio de orientación invierta el fuego. Permanece mientras haya alguna quemadura activa y se desvanece al terminar la última; se limpia en muerte/retiro y fin de oleada. Los números de daño siguen por encima.

Configuración común: `resources/statuses/fire_visual_default.tres`. Propiedades: flame_count, flame_opacity, coverage, flicker_speed, core_color, ember_count, ember_size, ember_opacity, heat_opacity, fade_duration. Para una apariencia específica se puede asignar otro FireVisualSettings en `StatusEffect > Fire Visuals`; vacío usa el recurso común. Habanero y los demás fuegos usan el mismo visual por defecto. El recurso común se carga en ejecución para evitar dependencias circulares de precarga de estados.

Una sola superficie de shader por unidad, sin nodos por brasa. No se afirma una mejora de FPS sin medir; el objetivo de optimización sigue pausado. Validación: verify_fire_visual, verify_status_system, verify_habanero y verify_remaining_spicy aprobadas; captura en Mobile/Vulkan revisada sobre jugador y enemigos.

### Quemado v3: llamitas de sprite

Se conserva el shader de aura y brasas; se eliminan sus antiguas llamas procedurales. Ahora cada unidad presenta copias del sprite `assets/sprites/Effects/small_fire.png`, agrupadas en un MultiMesh. Cada instancia tiene posición, tamaño, fase, velocidad de pulso e intervalo de inversión X propios. El shader anima tamaño e inversión sin mover el punto de apoyo; aplica distorsión UV pequeña (0,018), de frecuencia alta (38) y velocidad media (2,2). Elapsed se congela en pausa. La geometría se recalcula al cambiar tamaño del personaje o configuración; las animaciones corren en GPU.

En fire_visual_default.tres > Flame Sprites: flame_texture, flame_sprite_height, size_pulse, flip_interval_min/max, distortion_strength/frequency/speed. Flame Count y Flame Opacity siguen controlando cantidad y transparencia. La imagen fuente generada se conserva como small_fire_source.png. Se recorta el margen transparente y se prepara un PNG de 128×160 para el juego.

Cuatro regresiones aprobadas: fuego compartido y limpieza, estados, Habanero y otros chilis. Validación gráfica en Mobile/Vulkan: shader sin errores, posiciones y parámetros por instancia distintos confirmados y captura revisada.

Arte creado con ImageGen integrado. Prompt final: “Create ONE tiny fire flame sprite for a cute hand-drawn 2D kitchen survivor game. Single compact asymmetrical flame silhouette, rounded droplet-like lower body, one curving pointed main tongue and two shorter side tongues. Flat clean cartoon illustration, only 3-4 solid colors: deep orange-red outer shape with a very thin darker orange edge, orange middle, golden yellow smaller inner flame. No black outline, no white-hot center, no glow, no gradients, no texture. Simple bold shape readable at 20 pixels tall. Flame upright, gently leaning to one side, suitable for periodically horizontally flipping. Centered on transparent background with generous padding, all edges fully visible. No face, no eyes, no logs, no ground, no smoke, no sparks, no text, no frame, just one standalone small fire icon. Width about 65% of its height.”

Distribución v4: lower_body_fraction = 0,8 concentra aproximadamente 80% de las llamitas en el tercio inferior y reserva el resto para arriba (con 12 instancias: 10 abajo y 2 arriba). Ajustable en Flame Sprites del recurso visual. Se conserva la cantidad total y las animaciones independientes.

Ajuste v5: opacidad del sprite de fuego 0,85 y variación individual de alfa 0,95–1. Las instancias se adjuntan directamente al Sprite animado del Unit y su geometría se calcula en coordenadas locales. Heredan salto, rotación y squash/stretch en el mismo frame, sin recalcular posiciones globales por llama. FireVisual conserva su aura/brasas y elimina el batch hijo al terminar. Validado con movimiento del jugador en Mobile/Vulkan y regresiones de seguimiento inmediato, estados y Habanero.

Ajuste v6: una llama grande adicional detrás del sprite del personaje (z=1; personaje z=2; llamitas z=3), con opacidad 0,35. Usa el mismo arte y distorsión, pulso más suave y transform heredado del sprite animado. Ajustes Background Flame: background_flame_opacity, background_flame_height (1,3 del alto) y background_flame_width (1,4 del ancho), en fire_visual_default.tres. Se limpia junto con las llamitas pequeñas. Pruebas de estados y visual de fuego aprobadas; captura GPU revisada.

Corrección de orden: personaje z=2, llama grande z=3, llamitas pequeñas z=4. La llama grande queda por delante del personaje y detrás de las pequeñas; conserva opacidad 0,35 y seguimiento de animación.


Empuje es una estadística secundaria plana independiente (knockback). Fuerza ordinaria = max(0, empuje base del arma + bonus plano) × modificador final específico de empuje. Control de masas no aumenta ese empuje; conserva el escalado de Slow, Rooted y Airbourne.


## Fuego y Alcohol

Todo Burning usa un intervalo base de 0,5 s, acelerado por fire_tick_speed. Burning causado por el jugador usa max(0,1; effects × 0,25) de daño base por tick; no reutiliza el antiguo multiplicador porcentual de Efectos en los estados genéricos. El fuego nativo de Cayena usa ahora el daño base y escalado de su arma; ambos aplican después los porcentajes de daño correspondientes (ver damage_scaling.md). Las fuentes hostiles conservan su daño configurado. Se mantienen las duraciones y las contribuciones separadas de los chilis. Alcohol concede 2 puntos de probabilidad por copia y resta 3 de vida máxima, con una única tirada acumulada (máximo 100%). Duración inicial: 3 s. El daño se atribuye al registro del arma que lo provoca; cada arma mantiene su fuente sin sobrescribir a otra.

## Salpicadura caliente

5% por copia y −3 puntos de probabilidad de bloqueo; configurables mediante proc_chance, effect_radius y add_value_2 (negativo) del item_045.tres. Al entrar un enemigo en Burning se busca el vecino no quemado más cercano a 80 unidades de mundo. Si existe, se realiza una sola tirada; el acierto aplica el mismo fuego a ese vecino, que puede continuar la cadena. No se repite por tick, por refresco, por otra fuente mientras ya arde ni por vecinos que lleguen después. Una nueva entrada a Burning tras extinguirse permite otra comprobación. La cola iterativa evita recursión y ciclos; se conserva el registro de daño del arma original.


## Baño de aceite

Cada copia resta 0,05 segundos al intervalo base de Burning y 0,1 segundos a su duración. Máximo 5 copias: las ofertas y las compras respetan max_copies del item_056.tres. Los valores fire_interval_reduction y fire_duration_reduction también se editan allí. Fórmula del intervalo: max(0,05; max(0,05; 0,5 − reducción plana) / max(0,05; 1 + fire_tick_speed / 100)). Duración: max(0; duración base × modificador final de duración − reducción plana). Con 5 copias y sin otros modificadores: 0,25 s entre ticks y 2,5 s para un Burning base de 3 s; 10 ticks completos. Las contribuciones de Cayena ajustan la duración por fuente individualmente.

