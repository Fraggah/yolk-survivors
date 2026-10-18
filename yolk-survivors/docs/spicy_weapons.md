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
| poblano | Pepper itself orbits the player at distance max_range=105, angular speed 2.4 rad/s before attack speed, contact radius 50, 7 damage per 0.45 s. One persistent orbiter per copy; sprite_scale controls its visual size. |
| carolina_reaper | Two moving fire tornado columns per 3.2 s; speed 130, radius 48, lifetime 6 s, 9 damage per 0.45 s, cap 4. Fire tick speed affects direct ticks too. Column height is visual; damage uses its oval footprint. |
| ghost_pepper | Random arena cloud every 3.5 s, radius 145, lifetime 5 s, 4 damage per 0.6 s, cap 3. |
| aji_amarillo | One seed per 0.14 s, direction rotates 22.5 degrees per shot, damage 4, projectile speed 650, travel range 430. Each copy maintains its own spiral angle. count and spiral_seed_gap_degrees allow multiple seeds per step. |
| scotch_bonnet | Random arena mine every 2 s, arms after 0.6 s, trigger radius 42, blast radius 110, 18 damage once, expires after 16 s, cap 6. The mine shows the pepper and a pulsing glow; the blast expands visually. |
| rocoto | Expanding oval shockwave every 2.5 s, radius 240, duration 0.65 s, 12 damage, knockback 2. Each enemy is hit once per wavefront. |

Cayenne/Reaper also apply the reusable `resources/statuses/spicy_trail_fire.tres` burn (1 damage per 0.5 s for 2 s); tune or replace each weapon's on_hit_effects as desired. Mines/clouds sample valid arena positions rather than selecting enemies. Persistent effects disappear when their weapon is removed. Radius/color/lifetime changes are captured when an effect spawns.

All catalogue buffs/debuffs above are active independently of each pepper's attack timer.

## Jalapeño: aura visual v2

El shader reemplaza las bandas ondulantes por halo y anillos ovales difuminados. Brasas con núcleo claro, brillo y pequeñas estelas orbitan en distintas pistas con velocidades ligeramente diferentes. Toda la animación usa elapsed y se congela en pausa. No agrega nodos por partícula ni cambia el daño, radio o ticks.

En stats_jalapeno.tres > Aura Settings > Orbiting Embers: orbit_particle_count, orbit_speed, orbit_particle_size, orbit_opacity, ring_opacity y ember_color. Conserva color, opacity y breathing existentes. Prueba verify_jalapeno aprobada; shader compilado y captura revisada con Mobile/Vulkan.

Ajuste v3: brasas orbitales con opacidad 0,4, brillo menor y naranja cercano al aura. Se agregan 24 brasitas centrales pequeñas, de vida breve y recorrido radial corto. Configurables en Central Embers: central_particle_count, central_particle_size, central_travel (fracción del radio), central_lifetime y central_opacity. Captura Mobile/Vulkan revisada y regresión de Jalapeño aprobada.

## Cuatro tiers de los diez picantes

Se conserva cada item_<id>.tres y stats_<id>.tres como tier I para compatibilidad con referencias existentes. Se agregan item_<id>_2/3/4.tres y stats_<id>_2/3/4.tres, unidos mediante upgrade_to. Selección inicial conserva diez picantes; tienda registra los 40 recursos. Compra, venta y combinación usan el flujo de armas existente, con rarezas I-IV. Cada tier es editable de forma independiente.

Balance inicial: daño base por tier ×1 / ×1,35 / ×1,8 / ×2,4; radio de patrones y aura ×1 / ×1,1 / ×1,2 / ×1,3 donde corresponde. Precios base ×1/2/4/8. Buffs, debuffs y drenaje se conservan por copia en todos los tiers; no se multiplican nuevamente por rareza. Se conserva la cantidad de copias equipadas como base de acumulación de modificadores finales.

### Habanero secuencial

| Tier | Explosiones por tanda | Daño base | Radio base |
|---|---:|---:|---:|
| I | 3 | 8 | 95 |
| II | 4 | 10,8 | 104,5 |
| III | 5 | 14,4 | 114 |
| IV | 6 | 19,2 | 123,5 |

Primera explosión comienza inmediatamente; luego una cada 0,32 s. Anticipación 0,12 s y visual de explosión 0,18 s. Cooldown base de tanda 1,4 s, antes 2,4 s. La siguiente tanda espera también a que termine la anterior: no se superponen tandas de una misma copia. El intervalo efectivo no baja de anticipation + visual_duration, para conservar explosiones individuales incluso si se editan esos tiempos. Distintas copias del arma mantienen sus secuencias independientes.

La secuencia se congela en pausa y se cancela en reset_attack/fin de oleada. Un frame largo no emite todas las explosiones atrasadas juntas. Cada punto se toma alrededor de la posición actual del jugador y respeta los límites de arena. Se conserva quemadura, daño oval, críticos y registro de daño. Ajustar explosion_count, explosion_interval, explosion_radius y anticipation en spicy_explosion_settings de cada stats_habanero*.tres; daño y cooldown están en el mismo recurso de stats.

Regresiones: verify_habanero, verify_spicy_tiers, verify_spicy_tier_purchase, verify_spicy_selection, verify_jalapeno, verify_remaining_spicy y verify_spicy_modifiers aprobadas.

### Habanero: presentación de explosión v2

Shader propio con anticipación de calor concentrándose, destello central cálido y contorno de llamas irregular que se expande y disipa. Respeta la proyección oval. Cada explosión varía su fase visual para evitar un patrón idéntico. Brasas radiales de tamaño/velocidad variados se elevan ligeramente y duran 0,4 s, independientemente de la explosión de 0,18 s; no tienen colisión ni daño. Pertenecen a projectiles para limpiarse al finalizar oleada y respetan pausa.

En spicy_explosion_settings > Explosion Visuals: core_color, flame_color, anticipation_opacity, flame_strength, ember_count, ember_duration, ember_travel (fracción de radio) y ember_size. Color/opacity y anticipation/visual_duration siguen siendo configurables. No se modifican daño, cadencia o tiempos existentes durante este cambio visual.

Regresiones de Habanero y tiers aprobadas. Shader compilado en Mobile/Vulkan y captura de anticipación, impacto y disipación revisada.

## Cayena: estela visual v2

La estela TRAIL usa el mismo sprite de fuego aprobado para quemado, con tamaños y posiciones variadas dentro del óvalo del parche. Cada llama tiene fase, pulso e inversión horizontal propios y distorsión sutil de frecuencia alta. Se suma una llama central amplia y transparente, brasas ascendentes y calor difuminado en el suelo. Aparición en 0,12 s y desvanecimiento en los últimos 0,4 s. Las zonas mantienen daño, radio, ticks, duración y límite de cantidad; la presentación no crea daño adicional.

La presentación corre sólo en modo TRAIL, conservando el shader anterior para los otros patrones. Flames quedan en z=1, por debajo de personajes z=2; el calor está en z=0. Se utilizan dos MultiMesh por parche, sin nodos individuales por llama. Se congela con el tiempo del efecto durante pausa y se elimina junto con la zona.

En spicy_pattern de cada stats_cayenne*.tres > Trail Fire Visuals: trail_fire_visuals (opcional; vacío reutiliza fire_visual_default.tres), trail_flame_height (0,65 del radio), trail_fade_in y trail_fade_out. Los detalles de llama/brasas/distorsión provienen de FireVisualSettings, por lo que se puede asignar un recurso independiente para balance visual del Cayena. Opacity del patrón multiplica la transparencia de las llamas; los colores de calor siguen color del patrón.

Regresiones de otros picantes, tiers y fuego aprobadas. Captura de varios parches revisada en Mobile/Vulkan y shader sin errores.

### Cayena: contacto independiente del tick

La ignición ya no depende del chequeo de daño del suelo cada 0,5 s. TRAIL comprueba contacto en cada actualización y aplica sus estados FIRE al entrar, sin añadir un golpe directo. Los ticks de daño del parche mantienen su reloj y el fuego conserva su propio temporizador. Se comprueba el segmento entre la posición anterior y actual del enemigo en coordenadas del óvalo, para detectar cruces completos entre frames. Se descartan enemigos muertos/retirados y se renuevan los registros de posiciones/contactos; no se aplica durante pausa. El parche conserva el daño periódico y su renovación de quemadura existente.

verify_cayenne_contact prueba entrada entre ticks, cruce rápido, ausencia de daño extra de contacto, límites ovales, pausa y conservación del reloj del quemado. También pasan verify_remaining_spicy, verify_status_system y verify_fire_visual.

### Cayena: estela compartida entre copias

La primera copia equipada controla la creación de parches, geometría, duración, cadencia y partículas; las otras copias de la misma escena no crean un trazo adicional. Cada parche toma una instantánea de los daños efectivos de las copias equipadas y los suma en un único Hitbox. Los buffs/debuffs finales siguen acumulándose como antes. Otras armas de patrón no se agrupan.

Las quemaduras propias de Cayena también suman el daño configurado de sus copias y comparten una clave de estado por jugador/tipo de fuego. Parches posteriores refrescan esa misma quemadura sin reiniciar su reloj, evitando duplicados de fuego/partículas en el enemigo. Los efectos añadidos por ítems se conservan una vez en el golpe compartido. Los parámetros que no son daño proceden de la copia principal.

El registro de daño compartido reparte cada golpe entre las copias según su aporte: daño directo proporcional al daño efectivo de cada arma y ticks de quemadura proporcional al daño de fuego aportado. El número de combate recibe un único golpe con el total. Los nuevos parches se recalculan con el equipo actual; las compras/combinaciones/ventas entre oleadas no dejan aportes fantasma. Si desaparece la copia principal, la siguiente equipada pasa a crear la estela; los parches ligados a la anterior se limpian por el mecanismo de referencia existente.

Validación: verify_cayenne_stacking cubre mezcla de tiers, una sola estela, suma de daño, una quemadura compartida entre parches, reparto del registro de daño y sustitución de la copia principal. También pasan contacto de Cayena, otros picantes, Habanero, estados, visual de quemado y compra/combinación de tiers.

## Jalapeño: aura compartida entre copias

Se aplica la misma regla que Cayena: la primera copia equipada de la misma escena controla cadencia y estilo visual. Las otras auras permanecen ocultas y no ejecutan ataques independientes. En cada tick la copia principal suma el daño efectivo actual de todas las copias, incluyendo tiers distintos, y aplica un único golpe por enemigo dentro del óvalo. Críticos, empuje, robo de vida y efectos del golpe usan la configuración de la copia principal; las demás sólo aportan daño. Los modificadores finales del equipo se siguen sumando normalmente.

El golpe usa un registro compartido que reparte el daño real entre los registros de cada arma proporcionalmente a su aporte, igual que Cayena. No se duplican partículas ni números por copia. Si la principal se elimina, la siguiente equipada toma su lugar y se recalcula el daño con el equipo restante. Todas las auras conservan pausa y reset de oleada.

verify_jalapeno_stacking verifica I + III + II, un aura visible, un evento de golpe con daño total, registros individuales, límites ovales y sustitución de la principal. También pasan Jalapeño, Cayena compartida, selección de picantes y tiers.

## Superposición por zona y duración (2026-10-16)

Cada Jalapeño conserva su max_range y aura_settings.area_y_ratio, con el AoE efectivo del jugador. Un enemigo en la zona común recibe la suma de todas las copias; en las bandas exteriores sólo aportan las que alcanzan esa posición. El orden I/III/II no cambia las áreas. Se utiliza un único evento de daño por enemigo y tick, repartido entre los registros de las copias que realmente contribuyeron.

Cada parche de Cayena captura por copia el radio, proporción Y, daño efectivo, duración y estados al crearse. Los aportes vencen independientemente; el parche se elimina al vencer el último. La duración base por tier es 3/4/5/6 segundos, editable en stats_cayenne*.tres > spicy_pattern > lifetime. El radio es 40/44/48/52, antes de AoE y escala. Los límites maximum_active son 14/19/24/29; el trazo compartido usa el máximo entre las copias equipadas para que el límite de un tier bajo no recorte al alto. La cadencia/espaciado siguen siendo los de la copia principal.

El quemado de Cayena conserva un único nodo y reloj por jugador/tipo de fuego. Cada copia tiene su aporte de daño y vencimiento de quemadura independiente; entrar en una zona sólo renueva los aportes alcanzados. Al abandonar el suelo el quemado continúa por su duración de estado (spicy_trail_fire.tres), independiente de la duración del parche. Expirar un aporte del suelo impide renovarlo, sin borrar prematuramente un quemado ya aplicado. El daño real de cada tick se reparte únicamente entre aportes de quemadura todavía activos. Los estados agregados por ítems se conservan una vez en el golpe compartido.

Visualmente se conserva una sola aura y una estela, con transiciones suaves: mayor intensidad donde coinciden varios aportes; al vencer los cortos, disminuye el brillo local y permanece la región de los largos. Las llamas reutilizan los mismos MultiMesh, sin sistemas duplicados por copia. La presentación sigue siendo oval y se congela en pausa.

Validación: verify_jalapeno_stacking cubre bandas I/II/III y registros por zona; verify_cayenne_stacking cubre radios diferentes, vencimiento independiente, continuidad hasta el último aporte, quemado compartido y registros. También se verifican contacto rápido, otros picantes, tiers, fuego y visual de quemado. Capturas de tiers combinados revisadas en Mobile/Vulkan.

## Poblano: órbita y contacto (2026-10-16)

La órbita se eleva 40 unidades base sobre los pies del jugador mediante spicy_pattern.orbit_center_offset = Vector2(0,-40). El centro de dibujo y contacto es el mismo; se mantiene la proyección oval area_y_ratio=0,6. Se amplía el radio de contacto base por tier a 50/55/60/65 (antes 25/27,5/30/32,5); recibe el multiplicador de AoE.

El contacto se comprueba en cada actualización, barriendo segmentos cortos a lo largo del arco real, incluida la traslación del jugador y el movimiento relativo de cada enemigo. Se consulta el centro del HurtboxComponent/CollisionShape2D del enemigo y se incluye el radio de sus hurtboxes circulares en el margen de contacto. Así no se pierde un impacto por estar entre los antiguos chequeos globales de 0,45 s. Cada enemigo conserva un intervalo independiente tick_interval=0,45 s entre impactos de esa copia del Poblano. Las demás armas de patrón conservan sus ticks anteriores.

Velocidad base orbit_speed por tier: 2,4 / 2,8 / 3,2 / 3,6 rad/s. Se multiplica por stats.cooldown / get_effective_cooldown(player.stats), reutilizando la curva de velocidad de ataque de las armas, con modificadores finales incluidos. +100% duplica el giro; -100% lo reduce a la mitad. Se actualiza sobre el orbitador existente sin recrearlo. max_range sigue controlando la distancia orbital. Cada copia conserva su propio orbitador, daño y registro.

Edición: resources/items/weapons/spicy/stats_poblano.tres y stats_poblano_2/3/4.tres > spicy_pattern: orbit_center_offset (altura), orbit_speed (giro base), radius (zona de golpe), area_y_ratio (aplastamiento), tick_interval (intervalo por enemigo) y sprite_scale (tamaño visual).

Validación: verify_poblano cubre altura, contacto barrido en media vuelta, exclusión de enemigos lejanos, intervalo por enemigo, velocidad de ataque positiva/negativa, progresión por tier, pausa, seguimiento y limpieza. verify_remaining_spicy y verify_spicy_tiers aprobadas.

## Carolina Reaper: columnas de anillos de fuego v1

TORNADO usa ahora FireColumnVisual, independiente del daño. Se repiten anillos ovalados de fuego y coronas de llamas hacia arriba, con fases diferentes, distorsión, ascenso y brasas. Las llamas reutilizan el sprite small_fire.png y su shader de distorsión aprobado para quemado. Se agrupan anillos, llamas superiores, llamas de base y brasas en cuatro MultiMesh; no se crea un nodo por partícula/anillo.

La altura se calcula desde el contacto en el suelo hasta el borde superior visible, más column_top_margin. Se recalcula con movimiento y cámara/zoom; column_height sólo es un mínimo, no un límite superior. La base tiene un óvalo de calor, núcleo cálido, borde brillante pulsante y llamas a su alrededor. El óvalo visual coincide con radius y area_y_ratio del daño. Ningún anillo superior contiene hitboxes: daño periódico y quemadura siguen restringidos al óvalo inferior. Se mantienen daño, cadencia, cantidad, duración, radio y movimiento existentes de cada tier.

En stats_carolina_reaper*.tres > spicy_pattern > Fire Column Visuals se editan column_ring_spacing, column_top_margin, column_ring_opacity, column_distortion, column_flow_speed, column_core_color, column_base_flames, column_ring_flames, column_ember_count, column_ember_size y los tiempos column_fade_in/column_fade_out. Radius/AoE escala el ancho; area_y_ratio conserva la proyección oval. El visual usa elapsed del efecto y respeta pausa y limpieza de oleada.

Validación: verify_reaper_columns comprueba daño/quemadura sólo en la base, exclusión de enemigos bajo la parte superior o fuera del óvalo, adaptación de altura a cámara, pausa, movimiento y eliminación. Captura revisada con Mobile/Vulkan sin errores de shaders. verify_remaining_spicy conserva cobertura del resto de patrones.

### Carolina Reaper: anillo pintado aprobado

La columna utiliza assets/sprites/Effects/reaper_fire_ring.png: variante aprobada con mayor altura de pared de fuego y abertura ovalada amplia, generada mediante image_gen integrado. Se conserva el PNG original con alfa real en el exterior y en la abertura; la importación genera mipmaps para los tamaños pequeños del juego.

Cada stats_carolina_reaper*.tres asigna spicy_pattern.column_ring_texture, editable para reemplazar el arte. Se repite el sprite en un único MultiMesh hasta superar la cámara. fire_column_ring.gdshader ahora sólo muestrea el PNG y anima distorsión, oscilación, inversión alternada y transparencia. Se eliminan el anillo procedural y las llamas individuales superiores: la columna usa tres MultiMesh en total (anillos, llamas de base y brasas), conservando el óvalo intenso de suelo y el daño inferior. column_ring_flames deja de existir porque las llamas ya vienen pintadas dentro del anillo. Altura, espaciado, movimiento y opacidad conservan sus controles anteriores.

Prompt de la variante aprobada: retomar el anillo anterior, duplicar la altura vertical de la pared/llamas manteniendo ancho horizontal, espesor radial y abertura ovalada; estilo cartoon naranja/amarillo/rojo con alfa transparente. El archivo generado original se conserva fuera del proyecto; la copia utilizada por el juego reside en assets/sprites/Effects.

### Carolina Reaper: cuerpo continuo y anillos altos v3

Se incorporan dos sprites generados con image_gen integrado: reaper_fire_ring_v2.png (anillo con pared más alta y grandes áreas de color uniforme, sin las vetas finas de la versión anterior) y reaper_fire_column_fill.png (franja vertical continua de fuego, sin huecos interiores). Se preserva reaper_fire_ring.png como versión previa. Los recursos de los cuatro tiers asignan explícitamente ambas texturas nuevas.

El relleno es un único Sprite2D que cubre la altura completa hasta fuera de cámara, debajo de los anillos y con opacidad 0,96. Su shader mueve y distorsiona suavemente la imagen sin repetirla en vertical; el extremo inferior se redondea sobre la base ovalada. Los anillos se elevan por un factor 1,7, se separan 48 unidades base y tienen variación de altura/posición para evitar bandas regulares. Su opacidad baja a 0,24 y se atenúa al centro (factor 0,28) para que el cuerpo central permanezca uniforme. Se conservan las llamas de contacto y las brasas. No se modifica todavía el orden de renderizado entre personajes/enemigos: ésa es la siguiente etapa acordada.

Controles nuevos en spicy_pattern > Fire column visuals: column_fill_texture, column_fill_opacity, column_fill_width, column_ring_height_scale y column_ring_center_opacity. Las texturas utilizan alfa real y mipmaps para su reducción en pantalla. Prompt del anillo: pared vertical 1,7 veces más alta, forma ovalada y hueco conservados, centro con pocas formas grandes de color y puntas en la silueta. Prompt del relleno: franja vertical de fuego cartoon amarillo/naranja, interior casi opaco y uniforme, bordes transparentes, sin cortes ni bandas horizontales.

verify_reaper_columns incluye relleno casi opaco, cobertura de altura completa y selección de texturas; también siguen cubiertos daño sólo inferior, cámara, pausa y limpieza. Captura Mobile/Vulkan revisada.

### Carolina Reaper: contacto delantero y calor lateral

La base utiliza el semiarco delantero del anillo original reaper_fire_ring.png, según la referencia. FireColumnContact descarta la mitad posterior con una transición suave; no se altera el archivo PNG. Las llamas pequeñas se distribuyen sólo entre 0 y PI (mitad delantera del óvalo), con menos cantidad y menor altura, evitando que la parte posterior se dibuje sobre la columna. El semiarco se dibuja después del cuerpo/anillos para cerrar visualmente el apoyo contra la bandeja.

column_distortion aumenta a 0,06. Un ColorRect con fire_column_heat.gdshader ocupa la altura de la columna y se extiende por ambos costados; refracta la imagen de fondo mediante hint_screen_texture, con ondas ascendentes y máscara suave de calor. No agrega colisiones ni afecta daño, quemadura o alcance. Su tiempo y transparencia usan los mismos elapsed/fade, con pausa y limpieza del efecto. Conserva las prioridades Z existentes; el orden global por Y sigue pendiente.

En spicy_pattern > Fire column contact and heat: column_contact_texture, column_contact_opacity, column_contact_front_start (0,56), column_heat_side_reach (0,85 radios adicionales por lado), column_heat_distortion_pixels (8) y column_heat_opacity (0,85). Textura de contacto asignada explícitamente en los cuatro tiers. verify_reaper_columns incluye sólo llamas delanteras, máscara de semiarco, extensión lateral y pausa del calor. Se conserva la validación de daño exclusivamente inferior y otros patrones.

### Carolina Reaper: salpicaduras de brasas en el contacto

Se añade un MultiMesh independiente con 72 chispas/brasas en la base. Nacen distribuidas sobre el arco delantero y se alejan con trayectorias parabólicas cortas, tamaños y vidas variados, estelas alargadas, núcleo cálido y halo suave. Su color pasa de amarillo a naranja/rojo y desaparecen sin producir daño ni colisión. No son nodos individuales y no sustituyen las brasas ascendentes existentes. Usan elapsed del efecto para congelarse en pausa y se eliminan con la columna.

En spicy_pattern > Fire column contact sparks: column_contact_spark_count (72), column_contact_spark_lifetime (0,75 s), column_contact_spark_travel (1,2 radios), column_contact_spark_height (0,8 radios), column_contact_spark_size (3,2 unidades base) y column_contact_spark_opacity (0,95). verify_reaper_columns comprueba cantidad, animación y pausa, además de conservar cobertura de daño limitado al suelo.

Corrección de derrota relacionada: begin_defeat ajusta la escala del huevo frito antes de mostrarlo. Previamente se mostraba con escala por defecto o heredada de la derrota anterior hasta el siguiente _process, pudiendo ocupar gran parte de pantalla durante un frame. verify_player_damage_feedback comprueba su ancho inmediatamente después de morir, tanto en primera derrota como al reintentar.

## Ghost Pepper: nube local rojiza v2

Las nubes se generan en un óvalo aleatorio centrado en la posición actual del jugador. stats.max_range controla el radio horizontal de aparición, antes de escala global, y spicy_pattern.area_y_ratio aplasta el eje Y. Se muestrea el interior con sqrt(randf()) para distribución uniforme, se respeta el límite de arena y se conserva el radio local al ajustar esquinas. Las nubes ya creadas permanecen en el punto original; no siguen al jugador. Scotch Bonnet conserva su colocación aleatoria en toda la arena.

El área de nube aumenta de 145/159,5/174/188,5 a 175/192,5/210/227,5 por tier, antes de AoE y escala. Daño, duración (5 s), intervalo (0,6 s), cooldown, límite de activas, buffs y debuffs no se modifican.

El efecto usa ghost_pepper_cloud.png generado con image_gen integrado: cúmulo ovalado rojizo, lóbulos redondeados, sombras borgoña y luces coral, sin llamas ni contorno negro, con alfa transparente. GhostCloudVisual dibuja cuatro capas con un único MultiMesh y shader de distorsión suave, cambios de volumen y desplazamientos cortos. Una neblina ovalada al ras del piso marca suavemente el área. La opacidad inicial pasa a 0,62. No cambia todavía el orden global de renderizado.

En stats_ghost_pepper*.tres > spicy_pattern > Cloud visuals: cloud_texture, cloud_layer_count, cloud_billow_speed, cloud_distortion, cloud_visual_height y tiempos de aparición/disipación. Radius controla daño y tamaño; color el tinte de suelo; opacity la transparencia del cúmulo. El sprite fuente queda en assets/sprites/Effects/ghost_pepper_cloud.png con mipmaps de importación. Prompt: cúmulo de nube de vapor picante rojo/coral, óvalo visto desde arriba, volumen suave, paleta limitada, sin fuego, rostro o fondo.

verify_ghost_pepper cubre distribución dentro del óvalo del jugador, cambio de posición del jugador, límites de arena, radio ampliado, texturas/capas, permanencia en el punto inicial, daño oval, pausa y limpieza. verify_remaining_spicy y verify_spicy_tiers aprobadas.

### Ghost Pepper: niebla irregular de cúmulos pequeños v3

Se elimina el cúmulo grande dominante. Cada zona usa 18 copias pequeñas del mismo sprite en un único MultiMesh, distribuidas por el óvalo con tamaños aleatorios (0,28–0,48 del tamaño anterior), inversión horizontal, leve giro, variaciones de color y transparencia. Cada cúmulo tiene fase, duración, expansión, aparición/desvanecimiento y deriva propios. La composición se sortea al crear cada nube; una neblina de suelo suave mantiene la lectura del área de daño. No cambia el radio ni el daño, sólo la presentación.

Nuevos controles en Cloud visuals: cloud_puff_min_scale, cloud_puff_max_scale, cloud_puff_opacity (0,42), cloud_puff_drift (0,15 radios) y cloud_puff_lifetime (3 s antes de variar por cúmulo). cloud_layer_count pasa a 18 y cloud_visual_height a 0,08. Las animaciones siguen elapsed, respetan pausa y no crean nodos/colisiones por partícula. verify_ghost_pepper incluye composición diferente entre nubes y ausencia de un sprite dominante grande. Regresiones y captura Mobile/Vulkan revisadas.

### Ghost Pepper: separación entre nubes de todas las copias

Las zonas CLOUD se registran en ghost_clouds al entrar al árbol. La colocación consulta las nubes activas del mismo jugador, incluyendo las recién creadas durante ese frame por otras copias/tiers. Descarta zonas eliminándose o vencidas. Se buscan posiciones que respeten cloud_min_separation (0,85 del radio medio de ambas zonas, medido en coordenadas ovales), hasta cloud_spawn_attempts (48) intentos. Se conservan radio local del jugador y límites de arena.

Si el área está saturada se elige el candidato más alejado de las nubes existentes; puede haber solapamiento parcial, pero se rechazan centros coincidentes o casi coincidentes. Si no existe espacio de colocación, se omite esa creación. La separación no desactiva el daño acumulado de zonas que se superponen parcialmente. Ambos controles están en Cloud placement de spicy_pattern y pueden editarse por tier.

verify_ghost_spacing prueba seis copias de tiers diferentes creadas en el mismo frame, con semillas aleatorias idénticas, separación de las primeras dos, posiciones distintas en esquinas saturadas, descarte de zonas en limpieza y el caso sin radio disponible. También pasan verify_ghost_pepper y verify_remaining_spicy.

## Ají amarillo: direcciones repartidas y escalado a distancia

Cada copia de la misma escena ocupa un sector angular de 360/N grados según el orden de equipo: dos a 180 grados, tres a 120, cuatro a 90, etc. El desfase se suma al ángulo de su espiral; se conserva el avance original por disparo y los relojes propios de cada copia. Se recalcula el reparto con el equipo actual, excluyendo armas eliminándose. Tiers mezclados pertenecen al mismo reparto; reset_attack reinicia los ángulos entre oleadas.

Los cuatro item_aji_amarillo*.tres mantienen type=SPICY y asignan damage_scaling_stat=RANGED. Sus stats tienen damage_scaling=1,0: el daño a distancia aporta el 100% de su valor como bono plano antes de daño general, modificadores finales y Efectos. No escala con daño melee. La descripción muestra el porcentaje y el icono de daño a distancia. El nuevo override DamageScalingStat de ItemWeapon permite elegir escalado sin alterar categoría, buffs/debuffs o combinación; AUTO conserva el comportamiento previo de las demás armas.

verify_aji_amarillo cubre 1–6 copias, sectores iguales con tiers mezclados, avance de espiral, eliminación/reset, aporte de daño a distancia, exclusión de melee, categoría y descripción. También pasan patrones restantes, tiers y modificadores de picantes.

## Scotch Bonnet: minas locales y explosión rápida v2

Las minas aparecen en un óvalo aleatorio alrededor del jugador. max_range pasa a 550 unidades base en todos los tiers, con 20% de radio adicional por cada copia equipada extra de la misma escena, incluyendo tiers diferentes. La cantidad se consulta al lanzar: una/tres copias dan multiplicadores 1/1,4; se recalcula al vender o combinar. El óvalo usa area_y_ratio y se limita a la arena; las minas ya colocadas permanecen fijas. Mine spawn growth per copy controla la expansión.

ScotchMineVisual muestra sólo la mitad superior del área útil del PNG original (sin transparencia sobrante), con el borde de corte anclado al piso. El ancho visible es 40 unidades base, mayor que antes, y se aplica squash/stretch suave. No hay halo ni resplandor mientras espera. mine_visible_fraction, mine_visual_width, mine_squash_strength y mine_squash_speed se editan en Mine placement and visuals.

Al dispararse, la mina desaparece y el daño se aplica una sola vez en el óvalo completo. La presentación usa el impacto de Habanero, núcleo cálido, contorno de fuego y 16 lenguas de fuego en MultiMesh, más 32 brasas/fragmentos radiales que duran 0,4 s. La explosión principal dura wave_duration=0,18 s, con expansión rápida desde el impacto; no tiene una onda lenta de daño. Los fragmentos son visuales y conservan pausa y limpieza de oleada. Mine core/flame color y parámetros mine_blast_flame_count/mine_ember_* permiten ajustar el efecto.

Progresión I/II/III/IV: daño 18/24,3/32,4/43,2; radio 110/121/132/143; cooldown de aparición 2/1,75/1,5/1,25 segundos, antes de velocidad de ataque. Se mantienen armado 0,6 s, detección 42, vida de mina 16 s y límite de seis minas por copia. El daño y el área conservan Efectos/AoE y el registro individual de la copia.

verify_scotch_bonnet cubre radio amplio local, crecimiento y reducción por copias, recorte de mitad superior, ausencia de halo, squash/stretch, armado, daño oval único, explosión breve, pausa y progresión de los tres parámetros por tier. También pasan Ghost Pepper, separación de nubes, otros patrones y tiers. Captura revisada en Mobile/Vulkan.

### Scotch Bonnet: sprite de mina dedicado

Se reemplaza el recorte horizontal del picante por un sprite nuevo diseñado como cúpula semienterrada, visto de frente y ligeramente desde arriba. Conserva colores naranja/amarillo, tallo verde, carita y contorno oscuro; su borde inferior curvo representa el apoyo en el piso. No se corta la mitad del cuerpo nuevo. El PNG de selección/arma no cambia.

Arte generado con image_gen integrado y guardado en assets/sprites/Spicy/Mines/scotch_bonnet.png. Prompt: cúpula baja y ancha de la parte superior de un Scotch Bonnet, base elíptica curva terminada, perspectiva 2.5D, paleta y contorno del original, carita, sin piso, cráter ni halo, alfa transparente. Se conserva el original generado. mine_texture y mine_texture_rect están asignados en los cuatro tiers; el rectángulo sólo ajusta el encuadre al dibujo, sin borrar píxeles ni recortar su silueta. mine_visible_fraction queda como compatibilidad si se quita la textura dedicada.

La cúpula conserva el ancho de dibujo configurable, squash/stretch anclado al piso y la explosión rápida existente. verify_scotch_bonnet comprueba que se muestra íntegro el recurso nuevo.

## Rocoto: onda de presión rápida v2

wave_duration pasa de 0,65 a 0,18 segundos en los cuatro tiers. Conserva daño, radio, cooldown y empuje. El frente de daño sigue su recorrido oval completo y registra cada enemigo una sola vez; incluso un frame largo que cruce toda la expansión alcanza los objetivos atravesados. Al terminar la expansión cesan los golpes, aunque queden ecos visuales.

RocotoWaveVisual reemplaza el shader genérico por un impacto de presión propio: destello central breve, contorno rojo con filo claro, brillo suave, trazos radiales, ecos interiores difuminados y 36 fragmentos/chispas en MultiMesh. El frente visual coincide con el radio activo y después se disipa en 0,18 segundos adicionales, sin daño. Todas las áreas se proyectan como óvalos y las animaciones respetan pausa y limpieza.

En spicy_pattern > Shockwave visuals: shockwave_visual_tail, shockwave_core_color, shockwave_rim_width, shockwave_spark_count y shockwave_spark_size. Wave duration sigue siendo el tiempo de expansión; wave_band controla la banda de detección. Radius, color y opacity afectan al efecto. El visual es procedural, sin un PNG nuevo ni nodos por partícula.

verify_rocoto cubre velocidad, recorrido completo en frames largos, daño único, exclusión fuera del óvalo, ausencia de daño durante la disipación, partículas, pausa y eliminación. También pasan patrones restantes y tiers. Captura Mobile/Vulkan revisada sin errores de shader.

### Rocoto: rojo oscuro, cadencia por tier y onda compartida

Se reduce el brillo y se reemplaza el núcleo crema/blanco por rojo cálido del picante: color (0,63;0,055;0,035), núcleo (0,82;0,18;0,09), opacidad 0,6. El filo, halo, ecos y estelas pierden intensidad. Los fragmentos usan un shader propio sin núcleo blanco, con trazos más cortos y oscuros, evitando el aspecto tecnológico.

Progresión I/II/III/IV: radios 240/264/288/312; daños 12/16,2/21,6/28,8; cooldown 2,5/2,35/2,2/2,05 segundos antes de velocidad de ataque. La expansión conserva 0,18 s y la cola visual otros 0,18 s.

Las copias del mismo Rocoto y tier comparten una sola onda. La primera equipada de cada tier controla su disparo; las demás aportan su daño efectivo a un único hitbox. Los tiers diferentes conservan ondas, radios y ritmos propios. Los registros individuales reciben el daño real proporcional al aporte, sin duplicar efectos/números por copia. Buffs/debuffs siguen contando todas las copias. La agrupación se recalcula con el equipo actual y descarta armas eliminándose; si se retira la primera, la siguiente de ese tier toma su lugar.

verify_rocoto_stacking cubre dos tier I, dos tier II y un tier III: tres efectos en total, suma de daños, registros por copia, ausencia de ataques de los seguidores, sustitución de la primera y progresión de radio/daño/cadencia. También pasan Rocoto, otros patrones y tiers. Captura con la nueva paleta revisada en Mobile/Vulkan.

### Carolina Reaper: corrección de refracción entre columnas superpuestas

El calor refractado usa hint_screen_texture, cuya captura compartida podía no contener el fuego ya dibujado por otra columna. Al intercalar calor/cuerpo de cada columna en Z=1, una zona de calor posterior reponía el fondo sobre la columna anterior. heat_surface se dibuja ahora con z_as_relative=false y z_index=-1, antes de las bases (Z=0) y de todos los cuerpos/anillos/partículas (Z=1). Se conserva el calor lateral sin que ninguna refracción borre fuego de otra columna. Esto no cambia todavía el orden global por Y entre personajes.

verify_reaper_columns comprueba la prioridad absoluta del calor respecto de todas las capas de fuego. La prueba nativa documentacion-local/validacion/verify_reaper_overlap_gpu.gd reproduce el orden anterior, compara el orden corregido y una referencia sin calor usando las mismas dos columnas congeladas. En 549 muestras del cuerpo, el error RGB medio baja de 0,7475 a 0,00327; comparación Mobile/Vulkan aprobada y captura revisada.

### Orden de dibujo por posición en el piso

La arena usa `y_sort_enabled`: jugadores, enemigos y columnas del Carolina Reaper comparten Z=0 y se ordenan por la Y global de su raíz (punto de apoyo). Un elemento más abajo tapa a los que están detrás. Los saltos del sprite y la altura de las columnas no cambian esa referencia. Las armas equipadas, las llamas de quemado y la electricidad persistente conservan el grupo visual del personaje con Z relativo 0; su orden interno depende del árbol. Las sombras/contacto permanecen en Z=-1 y la refracción de las columnas en Z=-2, antes de todos los cuerpos, para evitar que una columna borre a otra. La interfaz conserva su CanvasLayer independiente. Al agregar nuevos actores, mantener su raíz directa bajo la arena y su cuerpo en Z relativo 0; evitar capas Z positivas en sus accesorios, porque saldrían del orden Y.

### Carolina Reaper: contacto continuo de la base

La detección se comprueba cada frame con un barrido relativo entre el movimiento del enemigo y el de la columna. Usa el centro y radio mundial del hurtbox circular y un cooldown de daño por enemigo basado en `tick_interval` (respetando `fire_ticks`), para no perder cruces entre ticks ni aumentar el daño según los FPS. Solo pega la base oval, nunca la altura visual. `column_hit_radius_multiplier` en SpicyPatternSettings permite ajustar el área sin cambiar el dibujo: valor inicial 1.5 sobre el radio base, un poco más ancho que el cuerpo pintado (1.4 radios de semiancho).

### Carolina Reaper: estela breve

Las columnas en movimiento dejan fuego de cayena en el piso, con duración base 1.1 s, ancho igual al cuerpo pintado de la columna, separación de 18 unidades base y daño/quemado del 25%. Estos valores se editan en `column_trail_lifetime`, `column_trail_radius_multiplier`, `column_trail_spacing` y `column_trail_damage_multiplier` del patrón. Escala con AoE y duración de efectos; atribuye daño al Reaper que lo creó. Las zonas del mismo arma refrescan una sola contribución de quemado. No se emiten parches estando quieto. Los parches viven fuera de la columna, por lo que se apagan naturalmente después de pasar o terminar esta; respetan pausa y limpieza de oleada. El multiplicador de radio 1.0 toma como referencia el ancho pintado (`column_fill_width`), no el radio de impacto ampliado. La zona completa del rastro hace daño y aplica quemado, incluidos sus bordes. El dibujo reutiliza cayena con diez llamas por parche y queda en la capa del piso, detrás de los cuerpos.

### Silueta de tornado del Carolina Reaper

El cuerpo continuo, anillos, embers y distorsión se ensanchan progresivamente hacia arriba. `column_top_width_multiplier` controla el ancho superior (2.1 de base) y `column_flare_height` la altura para alcanzarlo (500 unidades base). La curva usa altura mundial desde el piso, independiente del encuadre de cámara. La base, área de daño, rastro y punto de orden Y conservan su tamaño y referencia.

### Centrado de anillos del tornado

El ensanchamiento del cuerpo y la refracción se calcula por píxel sobre un rectángulo: deformar las cuatro esquinas a un trapecio sesgaba las UV y desplazaba la textura respecto de los anillos. Los anillos siguen el desplazamiento lateral del cuerpo, usan la misma curva de ensanchamiento y recortan su alfa contra la textura continua deformada, con coordenadas reales de pantalla (incluido el escalado del viewport). Verificación GPU: capturas separadas de cuerpo/anillos y medición de sus bordes a distintas alturas.

### Profundidad de Fueguito

`StageMechanics` es Node2D con Y-sort activado y `PanMechanic` también participa del Y-sort anidado. Así Fueguito conserva la pertenencia y limpieza de su mecánica, pero se ordena junto a jugadores, enemigos y columnas por la Y de su raíz. Las transiciones de aparición/desaparición usan Z=0 para respetar el mismo orden. La regresión GPU de profundidad comprueba los cruces con Fueguito bajo esa jerarquía real.

### Superposición de efectos de combate

Los cuerpos visuales de los patrones de picantes (cayena, poblano, nube, minas, onda de rocoto y explosiones de habanero) usan Z relativo 0 junto a su raíz de apoyo, sin capas absolutas positivas que sobrepasen columnas u otros actores. La estela breve del Reaper mantiene su capa de piso -1. El quemado y los rayos persistentes pertenecen al grupo de su unidad. ElectricRays reutiliza un MultiMesh pequeño por contexto eléctrico (capacidad de una instancia), en vez de dibujar todas las auras y explosiones eléctricas en un lote global frontal; conserva animación GPU, pausa, limpieza y conteo de segmentos. Las conexiones eléctricas entre objetivos se dibujan dentro del impacto con trazos de glow en su misma profundidad. La refracción del Reaper sigue antes de los cuerpos para no borrar efectos superpuestos.

### Altura finita del tornado

Se reemplaza la extensión hasta fuera de cámara por una altura fija de 192 unidades base (288 mundiales), aproximadamente tres veces el cuerpo visible del personaje. Todos los tiers usan esa altura y `column_flare_height=192` para mantener el ensanchamiento hasta la parte superior. Cuerpo y anillos se desvanecen suavemente en el extremo superior. La altura no varía con cámara, zoom, posición ni AoE; el contacto, daño y rastro siguen en el piso. Se ajusta desde `column_height` en cada `stats_carolina_reaper*.tres`.

### Remate superior y distorsión reducida

El borde superior usa una máscara animada irregular compartida por cuerpo y anillos, con puntas y alturas variables dentro de la textura continua, para evitar el corte horizontal. La distorsión del fuego baja de 0.06 a 0.025; la refracción de 8 a 3 píxeles, su opacidad de 0.85 a 0.55 y su alcance lateral de 0.85 a 0.6. Se conserva altura finita, silueta ensanchada y área de contacto.

### Altura +50% y resplandor del contacto

Todos los tiers pasan de 192 a 288 unidades base de altura (+50%, 432 mundiales), con ensanchamiento ajustado a esa misma altura. Se duplica el sprite frontal del contacto detrás del original: escala 1.2 y opacidad 0.3, compartiendo material/animación para mantener alineación y suavizar el borde como resplandor. Se ajusta con `column_contact_glow_scale` y `column_contact_glow_opacity`. Ambos sprites conservan Z relativo 0 en el grupo de la columna.

### Carolina Reaper: tornados permanentes por tier

Cada arma mantiene 1/2/3/4 tornados en tiers 1/2/3/4, respectivamente, con `count` y `maximum_active` iguales al tier y `lifetime=0` (sin vencimiento). Las copias suman cantidades independientemente: tier 1 + tier 3 mantiene cuatro. No se reemplazan ni se acumulan nuevas tandas al completar cooldown; solo se reponen los que falten. El visual usa duración infinita para evitar fade-out. Conservan movimiento, contacto, daño y estela breve. Se limpian al reiniciar el ataque/cerrar oleada, quitar el arma o morir la fuente; la estela sigue su vencimiento corto normal. Regresión `verify_reaper_permanent` cubre todos los tiers, mezcla de copias, permanencia, reposición y limpieza.

### Coste porcentual de vida del Carolina Reaper

El coste fijo de 1 HP/s se reemplaza por 1/2/3/4% de la vida máxima por segundo en tiers 1/2/3/4. `max_health_drain_percent_per_second` es editable en cada recurso de ítem. Los porcentajes de las copias se suman; tier 1 + tier 3 cuesta 4%/s. Cada tick usa la vida máxima actual y conserva fracciones, de modo que los cambios de vida máxima se reflejan inmediatamente. Sigue siendo coste directo (sin mitigación de armadura/bloqueo), se pausa con el juego y puede matar, igual que el coste anterior. La descripción muestra el porcentaje de vida máxima.
