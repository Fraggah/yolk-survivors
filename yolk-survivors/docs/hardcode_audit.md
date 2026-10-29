# Revisión de valores y reglas fijados en código

Fecha: 27/10/2026. **Solo auditoría y notas: no se implementaron cambios de juego.**

## Alcance y criterio

Inventario de **1044 archivos**: 195 scripts GDScript, 40 shaders, 165 escenas y 644 recursos. Se excluyeron tests, addons, `.godot`, temporales y outputs. Se inspeccionaron declaraciones, valores, fórmulas, asignaciones visuales, textos y carga de recursos; los sistemas principales se revisaron manualmente junto con su configuración. Es una revisión estática, no una validación visual de todas las combinaciones del juego.

El barrido recogió **4947 candidatos automáticos**, 1075 líneas con anotaciones export (incluyen grupos y no equivalen a campos únicos) y 214 declaraciones uniform. **No son miles de problemas confirmados**: incluyen estado inicial, rutas, índices, matemáticas y límites de seguridad. Abajo se agrupan **109 hallazgos o decisiones de configuración**.

- **Código:** cambiar esa magnitud o regla exige editar un script.
- **Parcial:** ya hay parámetros editables, pero quedan una política, un tope, una precedencia o detalles complementarios fijados.
- **Técnico:** conviene conservar código estable salvo necesidad concreta.
- Los valores guardados en `.tscn`, `.tres`, Theme, Animation o InputMap ya son editables; un número en esos archivos no es por sí mismo un problema.
- Animar desde la base de escena y ubicar un popup junto a un slot son comportamientos válidos. Se distingue eso de sustituir la base editable silenciosamente.
- Los destinos propuestos son opciones para decidir después. No se dan por aprobados ni modifican el balance.

## Mapa de la revisión

| Área | Hallazgos | Referencias |
| --- | ---: | --- |
| Base | 8 | BASE-01 — BASE-08 |
| Economía y rarezas | 11 | ECO-01 — ECO-11 |
| Combate | 11 | COM-01 — COM-11 |
| Ítems y recompensas | 10 | ITEM-01 — ITEM-10 |
| Armas y escenas | 7 | ARM-01 — ARM-07 |
| Unidades | 7 | UNIT-01 — UNIT-07 |
| Oleadas y escenarios | 7 | WORLD-01 — WORLD-07 |
| Boss | 8 | BOSS-01 — BOSS-08 |
| Cooperativo | 9 | COOP-01 — COOP-09 |
| UI y textos | 10 | UI-01 — UI-10 |
| Animaciones/VFX | 10 | FX-01 — FX-10 |
| Audio y controles | 5 | INPUT-01 — AUDIO-03 |
| Pruebas y rendimiento | 6 | DEV-01 — PERF-03 |

## Observaciones que cruzan varios sistemas

1. **Base de escena frente a modificadores:** Unit, Enemy, Weapon y WeaponsContainer ajustan escalas/posiciones al iniciar. Son candidatos importantes por la regla de escenas editables; deben revisarse como conjunto con distancias, colisiones y VFX.
2. **Reglas duplicadas solo/coop:** cantidad de ofertas, máximo de armas, +1 HP por nivel, garantías, tiempos de transición, navegación y textos. Exportar dos copias mantendría el riesgo de diferencias; una fuente compartida sería una opción.
3. **No basta agregar un export:** si otro cálculo posterior reemplaza el dato, el editor sigue sin ser fuente efectiva. Hay que definir precedencia escena/recurso → modificadores del juego → animación.
4. **Hay fixtures de desarrollo activos por defecto en scripts:** Tiny Egg, Hoarder/Glass Egg y pruebas de población/recompensa. Se anotan para decidir qué llega a la demo; no se desactivaron.
5. **Las reglas acordadas no se tocaron:** curación de 0,1, rarezas sin Suerte, reparto de XP/yemas y restricciones del boss. Hacerlas editables no debe alterar sus valores actuales.
6. **No todo debería exportarse:** enums, IDs, rutas internas, epsilons y operaciones geométricas deben seguir siendo código. Los índices mágicos merecen nombres semánticos, no necesariamente controles en el Inspector.
7. **Textos distribuidos:** hay datos de escena, recursos y cadenas generadas. Localización/textos con placeholders podría resolverlo mejor que decenas de exports aislados.
8. **Shaders:** uniforms ya editables, constantes internas de ruido/máscaras y uniforms sobrescritos por scripts son casos distintos. El anexo conserva las tres clases de evidencia.

## Base

| ID | Estado | Situación actual | Destino configurable posible | Evidencia |
| --- | --- | --- | --- | --- |
| **BASE-01** | Código | 25 yemas iniciales; CoopPlayerSession también declara 25, aunque start_run usa Global. | Reglas de run compartidas. | [autoload/global.gd:20](../autoload/global.gd#L20) |
| **BASE-02** | Código | Capacidad base 6; otras ramas y layouts también presuponen seis armas. | Capacidad base configurable con límites de UI explícitos. | [autoload/global.gd:21](../autoload/global.gd#L21) |
| **BASE-03** | Código | XP requerida = (nivel + 3)²; nivel inicial 1. | Curva o recurso de experiencia. | [resources/run_experience.gd:13](../resources/run_experience.gd#L13) |
| **BASE-04** | Código | +1 HP por nivel y cura del aumento de máximo; repetido en LocalCoop. | Regla única de recompensa por nivel. | [scenes/arena/arena.gd:203](../scenes/arena/arena.gd#L203) |
| **BASE-05** | Parcial | Listas iniciales de personajes/armas y registro de logros en constantes; metas de logros sí son recursos. | Catálogo de desbloqueos iniciales. | [autoload/progression.gd:7](../autoload/progression.gd#L7) |
| **BASE-06** | Código | Mapa nombre visible → escena de personaje; un cambio de nombre puede afectar búsquedas. | Catálogo con ID estable y referencias a escenas. | [autoload/global.gd:51](../autoload/global.gd#L51) |
| **BASE-07** | Parcial | Lista fija de pasivos activos: ready_for_shop es editable, pero no incluye IDs nuevos automáticamente. | Catálogo explícito de recursos. | [resources/items/passives/catalogue.gd:4](../resources/items/passives/catalogue.gd#L4) |
| **BASE-08** | Parcial | Listas de familias ranged/melee/spicy/pet y rutas construidas por tier; stats individuales sí configurables. | Catálogo de familias y recursos por tier. | [resources/items/weapons/ranged_catalogue.gd:4](../resources/items/weapons/ranged_catalogue.gd#L4) |

## Economía y rarezas

| ID | Estado | Situación actual | Destino configurable posible | Evidencia |
| --- | --- | --- | --- | --- |
| **ECO-01** | Código | Inflación 10% por wave, suma directa de wave y mínimo 1. | Recurso de economía con fórmula documentada. | [resources/economy_rules.gd:3](../resources/economy_rules.gd#L3) |
| **ECO-02** | Código | Venta al 25% del precio de tienda, redondeada hacia abajo. | Ratio y política de redondeo. | [resources/economy_rules.gd:4](../resources/economy_rules.gd#L4) |
| **ECO-03** | Código | Reroll usa factores 0,4 y 0,75 de wave, incremento mínimo 1 y contador. | Parámetros compartidos para tienda/mejoras. | [resources/economy_rules.gd:19](../resources/economy_rules.gd#L19) |
| **ECO-04** | Código | Curva tienda: horizonte 20, desbloqueos 2/9/15, caps acumulados 60/20/5%, crecimiento lineal y clamp después de 20. Sin Suerte deliberadamente. | Recurso de progresión; no activar Suerte sin calibración autorizada. | [resources/shop_rarity.gd:4](../resources/shop_rarity.gd#L4) |
| **ECO-05** | Código | Curva mejoras: horizonte 20, desbloqueos 3/10/15, caps 60/20/5%, lineal y sin Suerte. | Recurso separado de progresión de niveles. | [resources/upgrade_rarity.gd:5](../resources/upgrade_rarity.gd#L5) |
| **ECO-06** | Código | 40% familia equipada; peso base 1 y +1 por tag compartida. | Recurso de afinidad de ofertas. | [resources/shop_weapon_bias.gd:3](../resources/shop_weapon_bias.gd#L3) |
| **ECO-07** | Código | Garantía con menos de 3 armas, una por visita; exclusión de familias anteriores y excepción de bloqueados. | Política compartida solo/coop con umbral y flags. | [scenes/ui/shop/shop_panel.gd:242](../scenes/ui/shop/shop_panel.gd#L242) |
| **ECO-08** | Código | Máximo 2 armas por tirada y cuatro ofertas; LocalCoop repite constantes y arrays de cuatro. | Una fuente de reglas; cambiar cantidad requiere adaptar escenas. | [scenes/ui/shop/shop_panel.gd:6](../scenes/ui/shop/shop_panel.gd#L6) |
| **ECO-09** | Código | Garantía asequible de primera tienda, límite 12 y condiciones extra en ShopPanel. | Política configurable de inicio de tienda. | [resources/economy_rules.gd:5](../resources/economy_rules.gd#L5) |
| **ECO-10** | Código | Regla de utilidad por familia al llenar slots; IV y como máximo una copia incompleta, presupone cuatro tiers. | Política de ofertas; conservar enum estructural de tiers. | [resources/shop_weapon_bias.gd:65](../resources/shop_weapon_bias.gd#L65) |
| **ECO-11** | Parcial | Descuento máximo 90%; GoldenEnhancement repite topes. Pesos de Liquidación sí editables. | Límite compartido de ventas. | [scenes/ui/shop/shop_card.gd:25](../scenes/ui/shop/shop_card.gd#L25) |

## Combate

| ID | Estado | Situación actual | Destino configurable posible | Evidencia |
| --- | --- | --- | --- | --- |
| **COM-01** | Código | Armadura: coeficiente 0,06, rendimientos decrecientes y fórmula distinta con armadura negativa. | Coeficiente y política de daño entrante. | [resources/unit_stats.gd:248](../resources/unit_stats.gd#L248) |
| **COM-02** | Parcial | Cap de bloqueo 70%; poder de bloqueo sí es stat editable. | Cap global de bloqueo. | [resources/unit_stats.gd:251](../resources/unit_stats.gd#L251) |
| **COM-03** | Código | Invulnerabilidad tras impacto de 0,5 s. | Reglas de combate del jugador. | [scenes/units/players/player.gd:24](../scenes/units/players/player.gd#L24) |
| **COM-04** | Código | Lifesteal: 0,1 s entre activaciones; recuperación 0,1 HP por activación. | Recurso de curación, conservando la semántica acordada. | [scenes/units/players/player.gd:25](../scenes/units/players/player.gd#L25) |
| **COM-05** | Código | Regeneración: cada punto da 0,1 HP/s en pasos de hasta 0,1 HP. | Recurso de recuperación; no recalibrar incidentalmente. | [scenes/units/players/player.gd:27](../scenes/units/players/player.gd#L27) |
| **COM-06** | Parcial | Burning genérico: mínimo 0,1 y Effects ×0,25; las armas pueden tener daño/coefficient propios configurados. | Separar regla genérica y recursos de Burning específico. | [resources/unit_stats.gd:268](../resources/unit_stats.gd#L268) |
| **COM-07** | Parcial | Tick global de fuego 0,5 y suelos 0,05 en UnitStats; tick_interval exportado no es la única fuente. | Definir precedencia y base/mínimo editables. | [resources/status_effect.gd:6](../resources/status_effect.gd#L6) |
| **COM-08** | Código | Cooldown mínimo 0,05 repetido en mejora dorada; daño mínimo 1 y alcance mínimo 1 en el mismo recurso. | Límites compartidos de diseño, separados de epsilons técnicos. | [resources/items/weapons/item_weapon.gd:103](../resources/items/weapons/item_weapon.gd#L103) |
| **COM-09** | Código | Chili no crita sin Pimienta y Burning no hace crítico: reglas mecánicas en código. | Flags de política solo si se autoriza experimentar. | [resources/items/weapons/item_weapon.gd:106](../resources/items/weapons/item_weapon.gd#L106) |
| **COM-10** | Código | AoE convierte área a radio con raíz; ataque negativo y modificadores finales tienen fórmulas propias. | Documentar modelos; no exponer operaciones matemáticas como sliders. | [resources/unit_stats.gd:257](../resources/unit_stats.gd#L257) |
| **COM-11** | Código | Batido energético convierte exceso de velocidad a ataque con factor 2. | Coeficiente del ítem. | [resources/unit_stats.gd:215](../resources/unit_stats.gd#L215) |

## Ítems y recompensas

| ID | Estado | Situación actual | Destino configurable posible | Evidencia |
| --- | --- | --- | --- | --- |
| **ITEM-01** | Código | Delantal fija armadura→HP en 2; Grocery usa redistribute(50,40). | Campos de conversión/redistribución en sus recursos. | [scenes/units/players/passive_items.gd:119](../scenes/units/players/passive_items.gd#L119) |
| **ITEM-02** | Código | Cáscara resbaladiza: 20% velocidad y 3 s por poder. | Coeficiente y duración en el pasivo. | [scenes/units/players/passive_items.gd:191](../scenes/units/players/passive_items.gd#L191) |
| **ITEM-03** | Parcial | Prevención de letal deja 1 HP; duración/usos de protección se completan en PassiveItems. | Vida residual/protección de Cáscara extra. | [scenes/components/health_component.gd:23](../scenes/components/health_component.gd#L23) |
| **ITEM-04** | Código | Wasabi usa 10% para beneficios y penalizaciones de Chili. | Coeficientes del pasivo. | [scenes/units/players/player.gd:56](../scenes/units/players/player.gd#L56) |
| **ITEM-05** | Parcial | Yema dorada: resultados -1/10/25/50/100%, fallback de pesos 25/40/23/10/2, condición de perfecto y lista de magnitudes escalables. Pesos normales sí vienen del ítem. | Resultados/política de mejora configurables. | [resources/items/golden_enhancement.gd:8](../resources/items/golden_enhancement.gd#L8) |
| **ITEM-06** | Parcial | Ayahuasca fija retroceso 1/2 y reducción a mitad; pesos y niveles ganados sí configurables. | Recurso de outcomes y política de retroceso. | [resources/items/ayahuasca.gd:27](../resources/items/ayahuasca.gd#L27) |
| **ITEM-07** | Parcial | Hongo: nueve outcomes uniformes, fallback 5 s; explosión visual 0,22 y color fijo. Muchas magnitudes sí exportadas. | Pesos/lista de outcomes y perfil visual. | [resources/items/unknown_mushroom.gd:51](../resources/items/unknown_mushroom.gd#L51) |
| **ITEM-08** | Parcial | Rebozado: efecto asignado por tag y herencia al combinar en código; potencias/probabilidades en item_081.tres. | Tabla de efectos por tag solo si se necesita cambiar composición. | [resources/items/breading.gd:33](../resources/items/breading.gd#L33) |
| **ITEM-09** | Parcial | Incógnito exporta base e hitos; distribuciones objetivo 25% cada una → 0/⅓/⅓/⅓ → 0/0/½/½ → legendario, interpolación y fallback descendente son fijos. | Hitos con probabilidades objetivo y política de fallback. | [resources/rewards/incognito_loot_settings.gd:24](../resources/rewards/incognito_loot_settings.gd#L24) |
| **ITEM-10** | Parcial | Moneda/Gambler: fórmula de apuesta, duplicación/pérdida y elegibilidad de uso definidas por código. | Reglas de apuesta/resultados separadas de la descripción visual. | [scenes/ui/shop/shop_panel.gd:727](../scenes/ui/shop/shop_panel.gd#L727) |

## Armas y escenas

| ID | Estado | Situación actual | Destino configurable posible | Evidencia |
| --- | --- | --- | --- | --- |
| **ARM-01** | Código | Armas aplican escala visual global 0,75 por código. | Escala final en escena o multiplicador explícito con base preservada. | [scenes/weapons/weapon.gd:4](../scenes/weapons/weapon.gd#L4) |
| **ARM-02** | Código | Marcadores de armas se multiplican ×0,75 en _ready: posiciones editadas no son las finales. | Guardar las posiciones finales en la escena. | [scenes/units/players/weapons_container.gd:4](../scenes/units/players/weapons_container.gd#L4) |
| **ARM-03** | Código | Más de 6 armas usa elipse dinámica con radio base 60 y compresión Y=0,65. | Perfil de disposición dinámica de armas extra. | [scenes/units/players/weapons_container.gd:21](../scenes/units/players/weapons_container.gd#L21) |
| **ARM-04** | Código | Labels de tags, categorías y plantillas de descripción están en script. | Metadatos de tags/textos; mantener IDs estables. | [resources/items/weapons/item_weapon.gd:11](../resources/items/weapons/item_weapon.gd#L11) |
| **ARM-05** | Código | Capacidad visual de aura combinada limita contribuyentes a 6. | Capacidad técnica coordinada con shader. | [scenes/weapons/spicy/aura_behaviour.gd:37](../scenes/weapons/spicy/aura_behaviour.gd#L37) |
| **ARM-06** | Código | Colocación de patrones con umbrales 12 unidades y 10% del alcance. | Settings de colocación si se quiere afinar sensación de uso. | [scenes/weapons/spicy/pattern_behaviour.gd:122](../scenes/weapons/spicy/pattern_behaviour.gd#L122) |
| **ARM-07** | Parcial | Secuencias/modalidades melee elegidas por ramas; muchas duraciones/offsets/animation_speed ya son MeleeSettings. | Conservar lógica de comportamientos; extraer magnitudes/curvas residuales. | [scenes/weapons/melee/catalogue_melee_behaviour.gd:31](../scenes/weapons/melee/catalogue_melee_behaviour.gd#L31) |

## Unidades

| ID | Estado | Situación actual | Destino configurable posible | Evidencia |
| --- | --- | --- | --- | --- |
| **UNIT-01** | Código | Escala global 1,5: Unit._ready multiplica raíz; distancias/VFX también la usan. | Convención global explícita o escala final de escenas, migración coordinada. | [autoload/global.gd:19](../autoload/global.gd#L19) |
| **UNIT-02** | Parcial | Enemy impone escala visual 0,5×visual_scale, no parte de la escala base de Visuals. | Base de escena más multiplicador respetado. | [scenes/units/enemies/enemy.gd:198](../scenes/units/enemies/enemy.gd#L198) |
| **UNIT-03** | Parcial | Roamers normalizan altura de arte a 176 y reajustan offset/posición; modifican parte de la base visual. | Altura de referencia/pivote/base editables. | [scenes/units/enemies/reward_roamer.gd:32](../scenes/units/enemies/reward_roamer.gd#L32) |
| **UNIT-04** | Parcial | Fallback de límites (-1000,-500,2000,985), 48 intentos, probe mínimo 60. Recompensa 10–25 y bounce principales ya exportados. | Geometría de entorno + perfil de movimiento. | [scenes/units/enemies/reward_roamer.gd:54](../scenes/units/enemies/reward_roamer.gd#L54) |
| **UNIT-05** | Parcial | Incógnito: squash 0,12, potencia 14 y sombra 0,3. Yolker: pulso 6, tilt 0,025, squash 0,035. | Perfil de animación/curvas. | [scenes/units/enemies/reward_roamer.gd:93](../scenes/units/enemies/reward_roamer.gd#L93) |
| **UNIT-06** | Código | Z se impone al iniciar: sprite 0/sombra -1; cadáver -3 y pickups -1 en otros scripts. | Política de render o base nativa editable. | [scenes/units/unit.gd:45](../scenes/units/unit.gd#L45) |
| **UNIT-07** | Parcial | Puntos de apuntado/impacto calculados por componente; shapes y anchors sí existen en escena. | Convención documentada y desvíos de diseño exportables. | [scenes/components/hurtbox_component.gd:10](../scenes/components/hurtbox_component.gd#L10) |

## Oleadas y escenarios

| ID | Estado | Situación actual | Destino configurable posible | Evidencia |
| --- | --- | --- | --- | --- |
| **WORLD-01** | Parcial | 128 intentos de spawn, fallback margen 80 y muestreo de 16 direcciones. Perfiles/grupos exportan pesos/zonas/distancias. | Perfil técnico de spawn y fallback explícito. | [scenes/arena/spawner.gd:250](../scenes/arena/spawner.gd#L250) |
| **WORLD-02** | Parcial | Flags temporales de multitud/recompensa activos por defecto; multiplicadores especiales conviven con progresión normal. | Perfil de desarrollo independiente. | [scenes/arena/spawner.gd:22](../scenes/arena/spawner.gd#L22) |
| **WORLD-03** | Parcial | Fondo de mundo creado por código y extendido según cámara; arenas sí son Resources. No es un panel UI. | Nodo base de mundo editable conservando cobertura dinámica. | [scenes/arena/environment_controller.gd:26](../scenes/arena/environment_controller.gd#L26) |
| **WORLD-04** | Parcial | Cámara ligada a clic derecho/R1, excluida en coop; shake frecuencias 80/1,37 y cobertura extra 32. Padding sí exportado. | InputMap + política de cámara y perfil de shake. | [scenes/arena/camera_2d.gd:28](../scenes/arena/camera_2d.gd#L28) |
| **WORLD-05** | Código | Fin de wave espera 1 s, repetido en coop; umbrales de últimos segundos y avisos fijos. | Tiempos/avisos compartidos de transición. | [scenes/arena/arena.gd:367](../scenes/arena/arena.gd#L367) |
| **WORLD-06** | Parcial | Yemas: altura de burst 40–85, duración ×0,85–1,15, ángulo ±0,1; radio/duración principal del roamer editables. | Perfil de dispersión visual. | [scenes/arena/arena.gd:240](../scenes/arena/arena.gd#L240) |
| **WORLD-07** | Parcial | Asignación escenario→tipo de mecánica en código; parámetros de Stage y waves sí exportados. | Referencia de mecánica por Stage para agregar sin editar controlador. | [scenes/arena/mechanics/stage_mechanics_controller.gd:15](../scenes/arena/mechanics/stage_mechanics_controller.gd#L15) |

## Boss

| ID | Estado | Situación actual | Destino configurable posible | Evidencia |
| --- | --- | --- | --- | --- |
| **BOSS-01** | Parcial | 3 fases de 3 secciones; mapa a scripts, orden aleatorio y excepción final en código. | Recurso de fases, secciones y restricciones. | [scenes/bosses/boss_encounter.gd:4](../scenes/bosses/boss_encounter.gd#L4) |
| **BOSS-02** | Parcial | HP por tercios y apertura/cierre de ventanas como regla fija. Vida/tiempos principales editables. | Umbrales de fase en configuración del encuentro. | [scenes/bosses/boss_health_component.gd:7](../scenes/bosses/boss_health_component.gd#L7) |
| **BOSS-03** | Código | Compleja: 50/50 estáticas/móviles, sin desplazamientos consecutivos. | Pesos y restricciones en EncounterSettings. | [scenes/bosses/complex_fire_lines.gd:32](../scenes/bosses/complex_fire_lines.gd#L32) |
| **BOSS-04** | Código | Torretas: 50/50 mover o girar excluyentes. | Pesos/modos configurables. | [scenes/bosses/mobile_rotating_turrets.gd:11](../scenes/bosses/mobile_rotating_turrets.gd#L11) |
| **BOSS-05** | Código | Mezcla final: cuatro mecánicas uniformes, restricciones tras tipos [1,3], labels fijos. | Tabla de mecánicas/pesos/restricciones. | [scenes/bosses/mixed_mechanics.gd:35](../scenes/bosses/mixed_mechanics.gd#L35) |
| **BOSS-06** | Parcial | Escalas/duraciones exportadas pero cortes 0,6/0,84/0,22 y respiración 0,025×sin(age×4) fijos. | Curvas de animación. | [scenes/bosses/sausage_turret.gd:22](../scenes/bosses/sausage_turret.gd#L22) |
| **BOSS-07** | Parcial | Impacto shake 5/0,15 y remanentes de stretch/textos fijos; caída y squash principal exportados. | Perfil visual/timeline de boss. | [scenes/bosses/boss_encounter.gd:269](../scenes/bosses/boss_encounter.gd#L269) |
| **BOSS-08** | Parcial | Flechas, cues de trayectoria/giro e indicadores offscreen tienen medidas/márgenes/dibujo en scripts. | Recursos de avisos visuales; mantener posicionamiento contextual. | [scenes/bosses/moving_line_arrows.gd:6](../scenes/bosses/moving_line_arrows.gd#L6) |

## Cooperativo

| ID | Estado | Situación actual | Destino configurable posible | Evidencia |
| --- | --- | --- | --- | --- |
| **COOP-01** | Código | Paleta de jugadores, máximo 4, arrays/loops de cuatro repetidos en selección/tienda/sesiones. | Recurso de identidad; máximo ligado a escenas de cuatro cuadrantes. | [scenes/coop/local_coop.gd:12](../scenes/coop/local_coop.gd#L12) |
| **COOP-02** | Código | WASD, D-pad/ejes, botones y deadzones se consultan directamente por dispositivo. | Perfiles/InputMap conservando control independiente. | [resources/coop_player_session.gd:34](../resources/coop_player_session.gd#L34) |
| **COOP-03** | Parcial | Mínimo 2 para avanzar, aceptación/cancelación y defaults de personaje/arma. Hold y aviso de solo ya exportados. | Reglas de lobby/selección. | [scenes/coop/coop_selection.gd:165](../scenes/coop/coop_selection.gd#L165) |
| **COOP-04** | Código | Spawn en fila centrada, separación 120. | Marcadores o patrón de spawn de equipo. | [scenes/coop/local_coop.gd:364](../scenes/coop/local_coop.gd#L364) |
| **COOP-05** | Código | Yemas completas a todos incluidos caídos; reserva/pasivas personales; XP base a todos con modificador propio. | Política por modo si se quieren alternativas a la acordada. | [scenes/coop/local_coop.gd:377](../scenes/coop/local_coop.gd#L377) |
| **COOP-06** | Parcial | Imán: uniforme entre activados, destino retenido y reasignación al cercano si muere. Distancias/velocidad exportadas. | Política de destinatario. | [scenes/coins/coins.gd:36](../scenes/coins/coins.gd#L36) |
| **COOP-07** | Código | Incógnito sortea recompensa entre sesiones uniformemente, sin excluir caídos por esa condición. | Política de elegibilidad/pesos del reparto. | [scenes/coop/local_coop.gd:390](../scenes/coop/local_coop.gd#L390) |
| **COOP-08** | Código | Coop no registra victorias solo; todos listos para avanzar, fases de rewards/upgrades y recuperación de caídos fijas. | Política de progreso/flujo de modo previa decisión de diseño. | [scenes/coop/local_coop.gd:330](../scenes/coop/local_coop.gd#L330) |
| **COOP-09** | Código | Índices mágicos 200+ locks, 300/301 páginas y 9+ inventario; repetición/scroll por código. | Acciones/enum semántico para mantenimiento, parámetros aparte. | [scenes/coop/coop_shop_panel.gd:51](../scenes/coop/coop_shop_panel.gd#L51) |

## UI y textos

| ID | Estado | Situación actual | Destino configurable posible | Evidencia |
| --- | --- | --- | --- | --- |
| **UI-01** | Parcial | Fuente Bake Soda, lista de paletas y regeneración de Theme en script; puede sustituir Theme del editor. | Theme nativo y tipografías/paletas con precedencia definida. | [autoload/ui_theme.gd:10](../autoload/ui_theme.gd#L10) |
| **UI-02** | Parcial | Estilos derivados con mezclas/radios/bordes y overlay 0,65; colores principales sí en paletas. | Theme/StyleBox y tokens visuales. | [autoload/ui_theme.gd:152](../autoload/ui_theme.gd#L152) |
| **UI-03** | Código | Orden/grupos de stats, labels, formato % y ayuda genérica en constantes; duplicación en PassiveItems/CharacterPassive. | Definiciones de stats y textos compartidos. | [scenes/ui/stats/stats_container.gd:8](../scenes/ui/stats/stats_container.gd#L8) |
| **UI-04** | Código | Nombres de rareza y números romanos fijos; etiquetas de estados/armas similares. | Metadatos/localización sin alterar IDs de enum. | [scenes/ui/rarity_marker.gd:13](../scenes/ui/rarity_marker.gd#L13) |
| **UI-05** | Parcial | Select Player/Weapon, Player/Locked, descripciones/pasivas generadas sobrescriben textos de escena. | Textos exportados o claves de localización. | [scenes/ui/selection_panel/selection_panel.gd:74](../scenes/ui/selection_panel/selection_panel.gd#L74) |
| **UI-06** | Código | KEEP/SELL/LIMIT REACHED, pendientes y rareza fijados en script. | Textos con placeholders en recurso/localización. | [scenes/ui/incognito_rewards.gd:42](../scenes/ui/incognito_rewards.gd#L42) |
| **UI-07** | Código | Avisos de eventos/compra/Ayahuasca, LOCK/LOCKED y Listo/No conectado repartidos entre scripts. | Textos compartidos con parámetros; escena mantiene Labels. | [scenes/ui/shop/shop_panel.gd:68](../scenes/ui/shop/shop_panel.gd#L68) |
| **UI-08** | Código | Tooltip margen 12 y gap 10; popup de armas/ayuda de stats repiten distancias similares. | Márgenes contextuales exportados; ubicación sigue dinámica. | [scenes/ui/shop/weapon_tooltip.gd:11](../scenes/ui/shop/weapon_tooltip.gd#L11) |
| **UI-09** | Parcial | Composición 2×2 fija; separación y design_size de CanvasFit exportados, adaptación visible en editor. | Ya válido como layout adaptable; columnas solo para otros diseños. | [scenes/coop/shop_quadrants.gd:7](../scenes/coop/shop_quadrants.gd#L7) |
| **UI-10** | Parcial | Título ajusta fuente al contenido partiendo de escena; defaults de respaldo 20/30 y suelo técnico 1. | Mantener ajuste automático; distinguir tamaño base y política de límite. | [scenes/ui/shop/shop_card.gd:8](../scenes/ui/shop/shop_card.gd#L8) |

## Animaciones/VFX

| ID | Estado | Situación actual | Destino configurable posible | Evidencia |
| --- | --- | --- | --- | --- |
| **FX-01** | Parcial | Moneda: orden de frames, timeline, aceleración, respiración, tamaño de resultado, colores y partículas en código; frames/base nativos. | AnimationPlayer/curvas y perfil de reveal. | [scenes/ui/shop/chocolate_coin_reveal.gd:6](../scenes/ui/shop/chocolate_coin_reveal.gd#L6) |
| **FX-02** | Parcial | Yema: choque a 1,12, anticipación, distancias, squash, flash y colores de resultado en script. | Timeline y perfil de efectos. | [scenes/ui/shop/golden_yolk_reveal.gd:54](../scenes/ui/shop/golden_yolk_reveal.gd#L54) |
| **FX-03** | Parcial | Desbloqueo 1,25 s, shake 65/0,045, escala 0,8→1,15, partículas; posiciones inicio/fin sí nativas. | Curvas/timeline y presentación. | [scenes/ui/unlock_notice.gd:103](../scenes/ui/unlock_notice.gd#L103) |
| **FX-04** | Parcial | Viñeta por HP 50/35/20/10%, intensidades 0/0,16/0,28/0,42/0,58; cadáver 90. Duraciones principales exportadas. | Curva HP→intensidad y perfil de derrota. | [scenes/ui/player_damage_feedback.gd:31](../scenes/ui/player_damage_feedback.gd#L31) |
| **FX-05** | Código | Texto: 1,3 s, rotación ±10°, escala 0,8–1,6, recorrido 15 y segmentos 0,4. | Perfil de texto flotante/animación. | [scenes/ui/floating_text/floating_text.gd:9](../scenes/ui/floating_text/floating_text.gd#L9) |
| **FX-06** | Parcial | Confeti: paleta, 72 piezas, velocidad 90–260, impulso -110 y rangos de giro/tamaño; multipliers exportados. | Perfil de partículas. | [effects/incognito_confetti.gd:3](../effects/incognito_confetti.gd#L3) |
| **FX-07** | Código | Feedback: emisión 0,08, paleta/rangos internos. Chispas doradas y electricidad tienen otros literales. | Recursos de feedback de impacto/electricidad/mejora. | [effects/enemy_hit_feedback.gd:5](../effects/enemy_hit_feedback.gd#L5) |
| **FX-08** | Código | Tintes eléctricos, labels Slow/Root/Air, margen 4 y límites geométricos de rayos en código. | Presentación de estados configurable; mantener ubicación contextual. | [effects/status_controller.gd:5](../effects/status_controller.gd#L5) |
| **FX-09** | Parcial | Uniforms sobreescritos con opacidad 0,95 y flame_strength 1,35 además de settings exportados de fuego. | Definir precedencia; magnitudes residuales al perfil visual. | [effects/scotch_mine_visual.gd:47](../effects/scotch_mine_visual.gd#L47) |
| **FX-10** | Parcial | Crecimiento visual 0,8+progreso×0,5 y ruido/curvas residuales; daño/radios/tiempos principales editables. | Curvas visuales separadas del radio de daño. | [scenes/projectiles/ranged_area_effect.gd:80](../scenes/projectiles/ranged_area_effect.gd#L80) |

## Audio y controles

| ID | Estado | Situación actual | Destino configurable posible | Evidencia |
| --- | --- | --- | --- | --- |
| **INPUT-01** | Código | Repetición 0,35/0,12, deadzone 0,2/0,45, umbral mouse 4; bindings de mando agregados al iniciar. | Perfil de navegación e InputMap como fuente. | [autoload/menu_input.gd:3](../autoload/menu_input.gd#L3) |
| **INPUT-02** | Código | Coop/pausa repiten umbral 0,5 y timings propios, separados de MenuInput/CoopSelection. | Perfil compartido con overrides por contexto. | [scenes/coop/local_coop.gd:240](../scenes/coop/local_coop.gd#L240) |
| **AUDIO-01** | Parcial | Cooldown global 40 ms y pitch 0,95–1,05 salvo UI/selection. Clips/ganancias/voces ya exportados. | Cooldown/pitch por evento. | [autoload/sound_manager.gd:159](../autoload/sound_manager.gd#L159) |
| **AUDIO-02** | Parcial | SFX inferido del nombre del botón y fallback de arma por tags; lista de eventos fija. | Acción/SFX semántico por escena/recurso. | [autoload/sound_manager.gd:230](../autoload/sound_manager.gd#L230) |
| **AUDIO-03** | Parcial | Prioridad wave→stage→biblioteca, sorteo uniforme y loop sin transición; tracks exportados. | Política de selección/repetición/fades. | [scenes/arena/music_player.gd:25](../scenes/arena/music_player.gd#L25) |

## Pruebas y rendimiento

| ID | Estado | Situación actual | Destino configurable posible | Evidencia |
| --- | --- | --- | --- | --- |
| **DEV-01** | Parcial | Tiny Egg comienza con 2 Yemas de oro/2 Rebozados en fixture; flag exportado activo por defecto. | Perfil de prueba independiente. | [scenes/arena/arena.gd:10](../scenes/arena/arena.gd#L10) |
| **DEV-02** | Parcial | Fixtures Hoarder moneda y Glass Egg yema: flags activos por defecto, personajes por ID fijo. | Perfil explícito de pruebas de tienda. | [scenes/ui/shop/shop_panel.gd:12](../scenes/ui/shop/shop_panel.gd#L12) |
| **DEV-03** | Parcial | Stress exporta cadencia/población/atracción; perfil chaser_mid, inmortalidad y equipo definidos en código. | Perfil completo de stress. | [scenes/arena/stress_test.gd:16](../scenes/arena/stress_test.gd#L16) |
| **PERF-01** | Código | Grid96, intervalo0,05, vecinos16, candidatos64, actualizaciones/frame32 y límites de búsqueda. | Perfil técnico por plataforma, con límites seguros. | [autoload/enemy_crowd.gd:3](../autoload/enemy_crowd.gd#L3) |
| **PERF-02** | Código | Pools: texto384/prewarm64; proyectiles256/64; rayos8192, batches1024; partículas128/1800/4096. | Perfil técnico, no sliders de balance. | [autoload/combat_texts.gd:3](../autoload/combat_texts.gd#L3) |
| **PERF-03** | Técnico | Muestreo/refinamiento de geometría, epsilons, capacidades e iteraciones de seguridad. | Conservar constantes técnicas; calidad editable solo con necesidad medida. | [resources/arena_environment.gd:56](../resources/arena_environment.gd#L56) |

## Lo que ya se puede configurar

| Sistema | Fuente | Ya editable |
| --- | --- | --- |
| Personajes/stats | UnitStats, CharacterPassive y recursos de personajes | Stats base, conversiones, bonus y restricciones melee/ranged. |
| Armas por tier | WeaponStats, RangedSettings, MeleeSettings, recursos spicy | Daño, escalados, alcance, cooldown, críticos, semillas/proyectiles, ráfagas y buena parte de animaciones. |
| Pasivos | ItemPassive/CataloguePassive y catálogo `.tres` | Valores de stats, muchas probabilidades/potencias, límites de copias y ajustes principales de consumibles. |
| Incógnito | `resources/rewards/incognito_loot.tres` | Probabilidades base e hitos de Suerte; quedan fijas distribuciones objetivo/fallback. |
| Waves/spawner | WaveData, SpawnGroup, ScheduledSpawn, EnemyProfile | Duración base 30 s, pesos, horarios, interior/bordes, arenas especiales/aleatorias, horda, límites, boss y música. |
| Arenas | ArenaStage/ArenaEnvironment | Texturas, límites, forma, cámara y parámetros principales de mecánicas. |
| Boss | BossEncounterSettings y patrones | Vida, ventanas, tiempos, daños, anchuras, densidades, anticipaciones, spawn de torretas y recorridos. |
| Fuego/VFX | FireVisualSettings, settings de armas y uniforms | Muchos colores, intensidades, duraciones y dimensiones; revisar remanentes/overrides. |
| UI | Escenas, variantes, Theme y paletas | Jerarquías, widgets, tamaños, fuentes y márgenes base. Aviso de solo Coop ya exportado. |
| Audio | SoundManager.tscn, nodo de música y recursos wave/stage | Clips, ganancias, voces y tracks de menú/tienda/wave/boss. |
| Pruebas | Flags y perfiles exportados | Stress, tandas/población/atracción, personaje de prueba del boss; falta separar reglas temporales. |

## Notas sobre escenas y recursos

El inventario incluye todas las escenas y recursos del alcance. Sus valores declarativos no se elevaron automáticamente a hallazgos. Los casos a resolver son los que tienen control exclusivo en código, duplicaciones, una elección de política pendiente o reemplazos de la configuración. Las cargas por ruta y referencias de catálogo se registraron como arquitectura/contenido; no se propone convertir toda dependencia técnica en export.

Las 40 fuentes de shaders están listadas en el anexo: sus 214 uniforms son configurables a través de materiales. Sus constantes internas se conservan como candidatos visuales/técnicos, no como cientos de tareas de balance. Los grupos FX-07 a FX-10 cubren ajustes residuales de efectos junto a los perfiles exportados.

## Cómo continuar

Se pueden indicar IDs o grupos de este documento en el siguiente pedido. Antes de migrar conviene decidir si cada ajuste será global, por modo, personaje, arma, ítem o escenario. No se creó un recurso gigante ni se eligió una arquitectura definitiva.

Las líneas son una fotografía: podrán desplazarse con futuros cambios. El inventario JSON incluye hash del archivo leído, exports/uniforms y cada candidato para rastrear su origen.

- [Hallazgos revisados en JSON](hardcode_audit_findings.json)
- [Inventario completo de archivos y candidatos](hardcode_audit_inventory.json)
- [Anexo por script y shader](hardcode_audit_scripts.md)

## Verificación de esta entrega

No se ejecutaron tests de jugabilidad ni se modificaron scripts/escenas/recursos de ejecución para esta tarea. Se comprobaron los archivos y líneas de evidencia y la cobertura del inventario. Los números anteriores representan el estado leído, no una promesa de que cada literal sea un defecto.


## Actualización 28/10/2026 — BASE-07

Resuelto el bloqueo por lista fija de IDs del catálogo de pasivos. Ahora se descubren los `.tres` de la carpeta, se soportan rutas `.remap` de exportación y `ready_for_shop` decide su inclusión. Se mantienen filtros posteriores de rareza, copias, personaje y restricciones específicas del cooperativo. La auditoría y sus hashes anteriores conservan el estado histórico del 27/10.
