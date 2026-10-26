# Salchichón del Infierno — Etapa 1

Implementada la base del encuentro y las tres secciones de la fase 1: líneas estáticas, torretas fijas y zonas calientes con Fueguitos. La fase 2 también está completa: líneas móviles, torretas giratorias y líneas intensificadas. La fase 3 incorpora líneas complejas, torretas con movimiento o giro y una mezcla final de cuatro mecánicas. Las nueve secciones están disponibles para probar. No se conecta al final de una run normal.

## Acceso

Seleccionar personaje, arma y luego «Probar boss — Salchichón del Infierno» en la selección de dificultad. Es una opción de desarrollo, disponible en debug. Usa el personaje elegido con 85 HP, 15 armadura, 20% bloqueo, 0 regeneración y 20% robo de vida sobre una copia de estadísticas. Mantiene daño, arma y dash originales. No registra progreso ni desbloqueos.

## Configuración provisional aprobada

`resources/bosses/salchichon.tres`: 100 HP, ventanas de 8 s, secciones de 30 s, aviso de caída de 1,2 s, daño de contacto y caída de 5. Entrada visual de 0,4 s. La zona de caída mide 1,2 veces el radio de contacto. El sprite tiene una altura provisional de 330 unidades, comparada con el jugador en el juego. Todos estos parámetros se editan en el recurso.

`resources/bosses/salchichon_arena.tres`: arena exclusiva con geometría independiente, inicialmente igual a Kitchen Plate, teñida con tonos cálidos y fondo oscuro. Cámara siguiendo al jugador. No pertenece al catálogo de arenas normales. Patrones futuros deben usar `play_area.movement_bounds`, su centro y coordenadas relativas.

La entrada a la arena espera 3 s antes de comenzar la fase 1 (`initial_wait_seconds`), respetando la pausa. Esta espera ocurre solo al iniciar el encuentro.

## Ciclo y daño

Cada fase baraja sus tres secciones sin repetir. Durante la prueba, `test_static_lines_first` fuerza el orden líneas estáticas → torretas fijas → zonas calientes y Fueguitos en la fase 1; desactivarlo restaura el orden aleatorio. Al terminarlas se anuncia el centro, el boss cae y puede causar daño en el área marcada usando el hurtbox del jugador y respetando sus i-frames. Después queda vulnerable durante 8 segundos y muestra una barra inferior con marcas en 1/3 y 2/3.

La misma instancia conserva HP. El componente de vida rechaza daño fuera de la ventana y limita cualquier daño al umbral de fase: 2/3, 1/3 y 0. Si la ventana vence, repite una única sección de esa fase antes de reaparecer. La muerte final controla la victoria de prueba, sin premios ni progreso de campaña. Al desaparecer queda fuera del targeting.

El boss no se mueve y es inmune a Burning, Shoked, Slow, Rooted, Airbourne, empuje y arrastre de baguette. Los flags de inmunidad son optativos y no cambian a los enemigos existentes. Los estados ya tienen vías directas de ítems y fuego: también se protegen esas entradas.

## Organización

- `scenes/bosses/boss_encounter.gd`: fases, secciones, avisos, caída, ventanas y ciclo de vida.
- `scenes/bosses/boss_health_component.gd`: caps e invulnerabilidad en el componente de daño.
- `scenes/bosses/boss_health_bar.gd`: barra inferior y descripción de la simulación.
- `scenes/bosses/salchichon/salchichon.tscn`: Enemy con sprite y componentes existentes.
- `resources/bosses/boss_encounter_settings.gd`: campos editables del recurso.

La base reutiliza ArenaStage/ArenaEnvironment, cámara, Enemy, hurtboxes/hitboxes, contabilidad de daño, pausas y pantalla de derrota. El spawner normal y las mecánicas de arena quedan detenidos durante la prueba. No depende del límite de 30 s de una wave.

## Arte

`assets/sprites/Bosses/salchichon.png`: primer sprite generado para el prototipo, con PNG transparente y mipmaps. Prompt: salchicha cocida rojiza, vertical y arqueada, brazos cortos cruzados, patas pequeñas, cejas marcadas y expresión desafiante cómica; contornos oscuros y sombreado cálido de Armados. La torreta usa `assets/sprites/Bosses/sausage_turret.png`, generada con la herramienta integrada de imágenes. Prompt: pequeña salchicha compacta de color rojo anaranjado sobre soporte metálico oscuro, cuatro boquillas de fuego, contornos marrón oscuro, sombreado cálido cartoon coherente con el boss, vista ligeramente desde arriba, sin fuego ni fondo, PNG transparente. Mipmaps activados.

## Verificación

`tests/verify_boss_encounter.gd` verifica entrada por menú, copia de estadísticas, spawner detenido, pausa, orden de secciones, caída, contacto, dash, persistencia, reintento único, inmunidades, caps, victoria sin progreso y salida/restauración de arena. `-- --capture` guarda imágenes de la entrada y ventana vulnerable en tmp.

## Fase 1: líneas estáticas

Diez ataques de 3 s durante los 30 s, alternando tres patrones: tres cuadrículas irregulares en «+», cada una con ocho líneas horizontales y doce verticales (20 por ataque), con grupos de líneas cercanas y huecos más amplios. Una línea de cada patrón se coloca sobre la posición del jugador al comenzar el aviso y luego permanece fija. Cada uno avisa durante 1,2 s, permanece activo 1 s y descansa 0,8 s. Ancho de daño de 72 unidades y 5 de daño por contacto, respetando la invulnerabilidad del jugador y el dash. No aplica Burning. El fuego se anima con un shader que también se detiene al pausar.

En `resources/bosses/salchichon.tres` se editan `section_seconds`, `static_line_patterns`, `line_width`, `line_damage`, `line_target_player`, `line_warning_seconds`, `line_active_seconds` y `line_rest_seconds`. Cada patrón tiene posiciones normalizadas horizontales y verticales; las líneas se extienden por todo el fondo, superando los límites jugables. Si la sección dura más que la secuencia, los patrones se repiten. Si dura menos, se interrumpen al finalizar la sección.

`scenes/bosses/static_fire_lines.gd` gestiona los avisos, las hitboxes y la limpieza al cambiar de sección o salir del encuentro. `tests/verify_boss_static_lines.gd` comprueba daño real, dash, descanso, zonas seguras, patrones, pausa, limpieza y parámetros personalizados. `-- --capture` guarda los avisos y el fuego activo en tmp.

## Fase 1: torretas fijas

Durante 30 s aparecen tandas de tres torretas en t=0,2,4,…,28. Cada torreta permanece 4 s; desde t=2 conviven seis, y en cada reemplazo se retira la tanda antigua antes de crear la nueva. La sección retira todas las torretas y sus líneas al finalizar (incluida la última tanda). Cada tanda mezcla patrones «+» y «×». Una torreta de cada tanda ajusta su posición al aparecer para que una de sus líneas atraviese la posición actual del jugador (`turret_target_player`). Conserva su orientación «+» o «×» y su posición queda fija durante el aviso y todo el disparo. Cada torreta avisa una sola vez durante 1,2 s al aparecer y luego dispara sin interrupciones hasta desaparecer. Las torretas supervivientes siguen disparando mientras avisa la nueva tanda. No gira, no persigue ni aplica Burning.

Las torretas son indestructibles y no participan del targeting de armas. Causan 5 de daño por contacto, con radio provisional editable de 42 unidades. Sus líneas tienen ancho 72 y daño 5, atraviesan el fondo y reutilizan avisos, shader e hitboxes de las líneas estáticas. El dash y los i-frames del jugador protegen de ambos daños. Las posiciones predeterminadas se expresan en coordenadas normalizadas y se ajustan a la arena.

`scenes/bosses/fixed_turrets.gd` gestiona tandas y emisores; `turret_edge_indicators.gd` muestra círculos con «+» o «×» en el borde de la pantalla para torretas fuera de cámara. El color se intensifica durante el disparo. Los indicadores siguen la cámara y desaparecen junto a su torreta. Pausa, salida, derrota y cambio de sección detienen y limpian los peligros.

En `resources/bosses/salchichon.tres` se editan los campos `turret_*`: intervalo de tandas, duración, aviso inicial, posiciones, sprite, altura visual, radio y daño de contacto, ancho y daño de líneas. `tests/verify_boss_fixed_turrets.gd` verifica tandas superpuestas, expiración, orientaciones, daño físico de líneas/contacto, dash, pausa, recorte al fondo, indicadores y limpieza. `-- --capture` guarda capturas de fuego e indicadores en tmp.

## Fase 1: zonas calientes y Fueguitos

`scenes/bosses/hot_zones_fueguitos.gd` reutiliza PanMechanic para las señales de aparición, posiciones seguras, separación y limpieza; instancia el Fueguito existente, con sus estadísticas base, persecución, daño de contacto y Burning. No puede destruirse ni ser seleccionado por armas, y no da yemas ni experiencia. Aparece uno al inicio (tras su flare habitual de 0,45 s) y se inicia otra aparición cada 3 s, hasta diez durante la sección de 30 s. Se acumulan sin retiradas intermedias. Una aparición se cancela si el jugador invade su posición durante la señal, como en la sartén normal.

Las zonas utilizan GriddleMechanic y HotZoneEffect existentes: hasta 12 por tanda, nuevas posiciones aleatorias en t=0,5,10,15,20,25, radio 350, daño 2 cada 0,75 s, 1 s de aviso, 2,8 s activas y 1,2 s de enfriamiento. Se respeta la separación de sus núcleos y los límites de la arena; puede haber menos si no caben todas. La duración activa se calcula como intervalo menos aviso y enfriamiento. Se conservan el shader y la distorsión de calor del escenario original.

Los parámetros `fueguito_*` y `hot_zone_*` están en `resources/bosses/salchichon.tres`. A los 30 s se anulan los daños, se retiran zonas, Fueguitos y señales pendientes, y recién entonces comienza el aviso de caída del boss. También se limpian al morir o salir del encuentro. Las arenas normales no cambian.

`tests/verify_boss_hot_zones.gd` verifica reutilización de los efectos, persecución, daño de zonas/contacto y Burning, pausa, renovación cada 5 s, acumulación de diez Fueguitos, ausencia de recompensas y limpieza antes de la caída. `-- --capture` guarda una captura en tmp.

## Fase 2: líneas móviles

Diez ataques en t=0,3,6,…,27, dentro de una sección de 30 s. Secuencia inicial: abajo→arriba; arriba→abajo; oblicua abajo-izquierda→arriba-derecha; derecha→izquierda; doble desde izquierda y abajo; oblicua abajo-derecha→arriba-izquierda; izquierda→derecha; oblicua arriba-izquierda→abajo-derecha; oblicua arriba-derecha→abajo-izquierda; doble desde abajo y derecha. En los ataques 5 y 10 se entra simultáneamente desde lados perpendiculares, formando una cruz. Desde el ataque 6, cada dirección emite tres barreras paralelas simultáneas, separadas 108 unidades entre centros (ancho 72), manteniendo una sola flecha por dirección. El ataque 10 combina dos grupos triples perpendiculares, seis barreras en total. Todas nacen fuera del fondo y completan el recorrido en el mismo tiempo. `moving_line_triple_from` y `moving_line_triple_spacing` permiten ajustar inicio y separación.

Cada ataque avisa 0,6 s mediante flechas en los bordes de la pantalla, señalando hacia dónde avanzará el fuego. Luego cruza todo el fondo en 2,4 s, con ancho 72 y daño 5, sin Burning. Las barreras son perpendiculares a su dirección de movimiento. Nacen completamente fuera del fondo (también sus márgenes de fuego), nunca desde el centro; atraviesan el fondo hasta salir por el lado opuesto. La geometría oblicua usa la proyección de las cuatro esquinas, adaptándose al tamaño y desplazamiento del fondo. Las flechas permanecen en el borde del viewport aunque se mueva la cámara, evitando los contadores superiores.

`scenes/bosses/moving_fire_lines.gd` reutiliza las visuales, shader e hitboxes de las líneas estáticas. `moving_line_arrows.gd` dibuja la señal en el HUD. El dash existente protege del daño; no se modifica su cooldown ni sus i-frames. Un Fueguito persistente acompaña ahora toda la fase 2. A los 30 s se retiran todas las barreras y flechas; también al salir o morir. `test_moving_lines_first` fija el orden líneas móviles → torretas giratorias → líneas intensificadas al llegar a la fase 2 en el encuentro de prueba.

En `resources/bosses/salchichon.tres` se editan `moving_line_interval`, `moving_line_warning_seconds`, `moving_line_travel_seconds`, `moving_line_width`, `moving_line_damage`, `moving_line_directions` y `moving_line_double_attacks` (números de ataque comenzando en 1). La velocidad se deriva del recorrido del fondo y del tiempo de cruce.

`tests/verify_boss_moving_lines.gd` verifica transición real desde fase 1, diez ataques, origen exterior incluso en diagonales, dobles 5/10, flechas, colisión real, dash, pausa, salida a los 30 s y otra geometría configurable. `-- --capture` guarda capturas de aviso y barreras activas en tmp.

## Fase 2: torretas giratorias

Los relevos de disparo ocurren en t=3,6,…,27. La primera torreta avisa en t=0 y dispara desde t=1,2 hasta t=3. Las siguientes aparecen para avisar 1,2 s antes de su relevo, mientras aún dispara la anterior; en el relevo se retira la antigua y la nueva comienza a disparar y girar inmediatamente, sin pausa ni superposición de disparos. Cada relevo dispone de 3 s activos y la última torreta se retira al cumplirse los 30 s de sección. Durante el aviso mantiene fija la orientación y muestra el sentido de giro. Después gira a 30°/s. Alterna sentido horario y antihorario, así como orientación inicial «+» y «×». Conserva la alineación inicial con el jugador, manteniendo fija su posición.

`scenes/bosses/rotating_turrets.gd` extiende el sistema de torretas fijas y reutiliza su sprite, daño/contacto y limpieza. Los haces recalculan extremos y colisiones contra los límites completos del fondo en cada giro. La rotación visual del sprite acompaña el ataque. `turret_rotation_cue.gd` dibuja una flecha circular alrededor del mecanismo; el indicador fuera de cámara también muestra la orientación actual y el sentido. Ancho 72, daño 5, contacto 5, sin Burning; se respetan los i-frames del dash.

En `resources/bosses/salchichon.tres` se editan `rotating_turret_interval`, `rotating_turret_lifetime`, `rotating_turret_warning_seconds` y `rotating_turret_degrees_per_second`. Los demás parámetros visuales y de daño se comparten con `turret_*`. La adaptación de tiempos usa una copia del recurso y no cambia la sección de torretas fijas. A los 30 s se limpia toda la sección. El Fueguito persistente de fase 2 continúa durante esta sección.

`tests/verify_boss_rotating_turrets.gd` verifica transición desde líneas móviles, diez apariciones sin superposición, aviso y sentido de giro, velocidad angular, colisión real de haces rotados, daño por contacto, dash, pausa, señal fuera de cámara y limpieza. `-- --capture` guarda una imagen de los haces activos en tmp.

## Fase 2: líneas intensificadas

Quince ataques en t=0,2,4,…,28 durante 30 s. Se reutilizan las cuadrículas irregulares de la fase 1 al 37,5% de densidad: tres líneas horizontales y cinco verticales por ataque (la mitad de la densidad anterior del 75%, con redondeo a ocho líneas). Se seleccionan posiciones distribuidas a lo largo de cada patrón original, manteniendo separaciones irregulares. Una línea sigue alineándose con la posición del jugador al comenzar cada aviso y luego queda fija. Ancho 72, daño 5, sin Burning, extendidas por todo el fondo.

`scenes/bosses/intensified_fire_lines.gd` reutiliza el controlador de líneas estáticas con una copia de sus patrones y parámetros. `intensified_line_interval` (2 s) y `intensified_line_density` (0,375) se editan en `resources/bosses/salchichon.tres`. El intervalo escala proporcionalmente los tiempos aprobados de la fase 1: aproximadamente 0,8 s de aviso, 0,667 s de fuego y 0,533 s de descanso. El ciclo total es 2 s; la fase 1 conserva sus 3 s y veinte líneas. La limpieza a los 30 s precede el aviso de caída del boss.

`tests/verify_boss_intensified_lines.gd` verifica integración desde las torretas giratorias, quince ataques, densidad por eje, integridad de los recursos de fase 1, apuntado inicial, daño, dash, pausa y limpieza. `-- --capture` guarda una imagen en tmp.

## Fueguito persistente de fase 2

Al comenzar la fase 2 se anuncia y aparece un Fueguito reutilizando su flare, posición segura, sprite, persecución, daño de contacto y Burning originales. Una única instancia permanece entre las tres secciones, durante las caídas y ventanas vulnerables del boss y los reintentos de esa fase. No se acumula ni se reinicia al cambiar de sección. Es indestructible, no es objetivo de armas y no otorga yemas ni experiencia.

`scenes/bosses/phase_fueguito.gd` reutiliza la creación y limpieza de Fueguitos de la sección de zonas calientes, pero su ciclo de vida lo controla `boss_encounter.gd` por fase. Se retira al pasar a fase 3, morir, salir o detener el encuentro, cancelando también cualquier aparición pendiente. Si el jugador invade la señal de aparición, se busca otra posición segura y se repite el aviso. `phase_two_fueguito_enabled` permite activarlo/desactivarlo en `resources/bosses/salchichon.tres`; sprite, estadísticas y flare usan `fueguito_profile` y `fueguito_flare_seconds` ya existentes.

`tests/verify_boss_phase_fueguito.gd` verifica aviso seguro, persecución, contacto/Burning, pausa, identidad única entre secciones/ventanas/reintentos, ausencia de recompensas, limpieza al cambiar de fase y cancelación durante la aparición. Las pruebas específicas de ataques aíslan el perseguidor con una copia local del recurso; la prueba integral del encuentro lo mantiene habilitado.

## Fase 3: líneas complejas aleatorias

Doce ataques, uno cada 2,5 s durante una sección de 30 s. El primer ataque y los posteriores a una cuadrícula estática hacen un único sorteo 50/50 entre cuadrícula original de fase 1 (20 líneas: ocho horizontales y doce verticales) y grupo de cinco móviles paralelas. Después de un grupo móvil se fuerza una cuadrícula estática: nunca hay dos ataques de desplazamiento consecutivos. Pueden repetirse cuadrículas estáticas. El reparto global deja de ser 50/50 por esta restricción. No se mezclan ambos tipos en el mismo ataque.

Las cuadrículas sortean uno de los patrones irregulares de fase 1, mantienen su densidad completa y la línea alineada al jugador, con sus tiempos escalados proporcionalmente a 2,5 s. Las móviles sortean una de las direcciones distintas existentes (laterales, verticales y oblicuas), avisan 0,5 s con una sola flecha, y las cinco recorren todo el fondo en 1,5 s, dejando 0,5 s de descanso hasta el siguiente ataque. Separación de 108 entre centros, ancho 72, daño 5 y sin Burning. Todas las móviles nacen fuera del fondo y el grupo se retira antes del siguiente ataque. Se amplía la proyección de recorrido para que también las cinco barreras nazcan y terminen completamente fuera del fondo.

`scenes/bosses/complex_fire_lines.gd` compone los controladores existentes de estáticas y móviles, sin modificar patrones ni tiempos de fases anteriores. Los campos `complex_line_interval`, `complex_moving_warning_seconds`, `complex_moving_travel_seconds`, `complex_moving_parallel_count` y `complex_moving_spacing` son editables en `resources/bosses/salchichon.tres`. `test_complex_lines_first` coloca esta sección primero al llegar a fase 3. La sección siguiente usa torretas giratorias móviles. La última sección sigue simulada y todavía no se incorporan los dos Fueguitos del diseño previsto.

`tests/verify_boss_complex_lines.gd` verifica entrada real a fase 3, doce ataques con sorteo condicionado, muestreo reproducible 50/50, ambos tipos de ataque, cinco líneas paralelas y señal única, orígenes fuera del fondo, tiempos aprobados, recursos anteriores intactos, daño, dash, pausa y limpieza. `-- --capture` guarda una imagen de cada tipo en tmp.

## Fase 3: torretas móviles o giratorias

La segunda sección reutiliza los relevos de las torretas de fase 2 y sortea una sola vez por torreta, con 50% para cada comportamiento excluyente: móvil sin giro, o giratoria quieta. Nunca se mueve y gira al mismo tiempo. Se mantiene el aviso de 1,2 s durante el final del ataque anterior, y los relevos cada 3 s sin pausa ni superposición de ataques activos.

Las móviles anuncian la trayectoria punteada A→B, mantienen fija la orientación de sus haces durante todo el recorrido y no muestran flecha de giro. Las giratorias anuncian su sentido horario/antihorario, giran a 30°/s en A y no muestran ruta ni se trasladan al retirarse. Ambos modos conservan la orientación inicial apuntada al jugador, ancho 72, daño 5 y contacto 5, sin Burning. La primera empieza a disparar en t=1,2 y termina en t=3; las siguientes completan turnos de 3 s. A los 30 s se retira todo.

`scenes/bosses/mobile_rotating_turrets.gd` extiende las giratorias mediante un hook de movimiento y un sorteo 50/50; `turret_path_cue.gd` dibuja la ruta solamente para móviles. En `resources/bosses/salchichon.tres`, `mobile_turret_start_positions` y `mobile_turret_end_positions` son pares normalizados A/B. Los recorridos son rectos, con velocidad derivada del tiempo activo del turno para llegar a B al finalizar. Las giratorias usan solo A. Intervalo, duración, aviso, giro y daño reutilizan los parámetros existentes de giratorias/torretas. Los modos se sortean independientemente y pueden repetirse.

`tests/verify_boss_mobile_turrets.gd` verifica el muestreo 50/50, exclusión de giro y movimiento, aviso correcto por modo, puntos normalizados, contacto/haces, dash, pausa, relevos y limpieza. `-- --capture` guarda una captura en tmp.

## Fase 3 — Mezcla final

Durante 30 segundos se sortean 12 ataques, uno cada 2,5 segundos: cuadrícula estática de 20 líneas, cinco líneas móviles paralelas, torreta giratoria fija o torreta móvil sin giro. Cada opción tiene 25% cuando el ataque anterior no se desplaza. Después de líneas móviles o torreta móvil, solamente pueden salir estáticas o torreta giratoria, con 50% cada una.

Las torretas siguientes se anuncian 1,2 segundos antes de su turno y comienzan a disparar exactamente en el relevo. Si el primer ataque es una torreta, conserva su aviso inicial. Se reutilizan los controladores y parámetros de las secciones anteriores. El intervalo se configura con `mixed_mechanic_interval` en `resources/bosses/salchichon.tres`. Al llegar a 30 segundos se retiran todos los ataques y avisos antes de la caída del boss.

`tests/verify_boss_final_mix.gd` verifica integración, los doce turnos, distribución, prohibición de desplazamientos consecutivos, avisos anticipados, relevo, exclusión de giro/movimiento, pausa y limpieza. Los dos Fueguitos de fase 3 del diseño original siguen pendientes; esta mezcla no los agrega.

Regresiones verificadas: spawner, baguette, estados de combate, armas eléctricas y Airbourne. La prueba histórica `verify_status_system.gd` se detiene en la línea 56 porque espera valores anteriores del daño/tick del fuego; no se modificaron esas fórmulas en esta tarea.


### Prompt original de la torreta (herramienta integrada de imágenes)

Use case: stylized-concept. Asset type: one transparent PNG game sprite, fixed sausage fire turret for Armados: Yolk Survivors. Reference image is STYLE AND PALETTE ONLY: the red-orange sausage boss just shown. Create a NEW shorter squat compact sausage turret, no arms, no legs, no boss face. A small upright plump grilled red-orange sausage on a low charcoal metal circular stand, with a simple top cap and four short dark metal fire nozzles pointing outward around the upper body, clearly a cute threatening sausage mechanism. Slight top-down game view with front visible, centred, isolated, full silhouette with generous transparent padding. Thick near-black brown outlines, warm orange highlight, deep red cel shading and a couple diagonal grill marks, readable simple cartoon illustration matching the reference boss. No flames, no beams, no floor or ground shadow, no background, no text, no UI, no extra objects. Single sprite, not sprite sheet.

## Ajustes de combate y orden

Todos los impactos del boss, sus láseres, contacto de torretas y zonas calientes aplican Burning. Se usa `resources/bosses/boss_burning.tres` (2 de daño por tick de 0,5 s durante 3 s, editable), además del Burning existente de Fueguito. Los láseres estáticos, móviles y de torretas ahora causan 10 de daño, el doble del valor anterior; contacto corporal y caída conservan su daño directo.

El Fueguito de fase 2 permanece durante las secciones y el aviso de caída, pero desaparece al impactar el boss. No persiste en la ventana vulnerable ni en reintentos posteriores de esa fase. Las secciones se barajan por fase; en fase 3 solo se barajan las primeras dos, reservando la mezcla final para el tercer lugar. Las opciones de orden fijo quedan desactivadas en el recurso y solo se activan localmente en pruebas específicas.

El boss tiene ahora 1000 HP. El personaje de prueba tiene 15 de daño a distancia y +40% de daño general. Tras retirarse el boss hay 2 segundos sin ataques antes de una nueva fase o sección de reintento (`departure_wait_seconds`); la espera respeta la pausa. No se aplica tras la victoria final.

El boss ahora admite Burning, Shoked, Slow, Rooted y Airbourne para daño y sinergias. Slow/Root/Air conservan duración y consulta de estado, pero no lo desplazan ni inclinan. Sigue inmune al empuje; Air no genera colisiones de lanzamiento.

## Revisión visual del boss

Sprite simplificado con la paleta del perro salchicha y contorno grueso, menos detalles y una silueta más compacta. Altura visual 660 (antes 330). Squash/stretch suave en reposo, estiramiento al caer y rebote amortiguado al impactar, manteniendo los pies en el ancla. Fuerza, período y duración configurables en el recurso del boss; la animación respeta la pausa y no modifica las colisiones.

La escena del boss es ahora la fuente de su geometría: sprite recortado mediante región y pivote en los pies, sombra al origen y tres colisiones con radio local 36. No se reconstruyen al iniciar ni se aplican los ajustes de tamaño/orientación de enemigos normales. El radio de caída se deriva de la colisión real. Tamaño, posición, región y colisiones se editan en `salchichon.tscn`; el recurso del encuentro conserva los parámetros de animación y combate.

Corrección de caída: solo se desplaza el sprite respecto de su posición de escena. `Visuals`, la sombra y las colisiones conservan sus transformaciones durante aviso, caída y aterrizaje, incluyendo ajustes manuales posteriores. La prueba de encuentro compara contra la escena guardada, sin exigir posiciones o escalas fijas.

La biblioteca de animaciones heredada se elimina de la instancia del boss (`libraries = {}`, mixer inactivo): RESET/idle/move/die del enemigo base no deben escribir transformaciones del sprite o de la sombra, tampoco al editar/guardar. La sombra tiene posición y escala explícitas en la escena, bajo los pies.

## Arena de parrilla oscura

`salchichon_arena.tres` usa un material de hierro casi negro con surcos paralelos de grill, inclinados 15 grados, ancho 18 y separación 105. Colores, rectángulo, radio y líneas se editan en su material `GrillSurface`. El fondo reutiliza el shader fluido con casi negro y naranja rojizo, configurable en `FireBackground`. Se mantienen geometría y mecánicas; el aspecto se limita al escenario del boss. `preview_boss_art.gd -- --arena` permite revisar el conjunto.

## Cambio de cámara

Durante la prueba del boss, clic derecho o R1/RB alterna seguimiento y vista completa. La vista completa centra los límites del escenario y calcula el zoom para ajustarlos al viewport con margen para HUD. Al volver restaura el zoom de seguimiento. Cada nueva arena reinicia el modo; fuera de la prueba del boss no se habilita. El margen se edita en `Camera2D.overview_padding`.

## Torretas con franja de fuego

Sprite naranja con la paleta y el contorno del boss, sin cañones. La franja amarilla se usa como máscara de color para `turret_fire_band.gdshader`, que anima rojo, naranja y amarillo del láser. Material local por instancia; el reloj respeta pausa y aviso/disparo. El cuerpo no rota: solo cambian los rayos y la señal de giro. La geometría se edita en `scenes/bosses/sausage_turret.tscn`, instanciada desde `turret_scene`; no se reconstruye en código. Conserva contacto y patrones de ataque.

La superficie de la arena ahora usa el sprite propio `assets/environments/stages/salchichon_grill.png`: parrilla oscura con surcos algo irregulares, rayones suaves, pequeñas manchas y desgaste en bordes. Reemplaza el shader geométrico del suelo para evitar su uniformidad; se conserva el material de fondo negro/naranja, los límites y el tamaño del escenario. Textura con mipmaps para ambas vistas de cámara.

## Aviso de calor de los láseres

La franja previa usa refracción de pantalla y turbulencia fuerte con bordes rojo/naranja/amarillo. Reemplaza la línea punteada. Su escena editable es `scenes/bosses/fire_line_warning.tscn`, con material local por instancia: intensidad de distorsión, separación cromática y colores. El reloj del aviso respeta pausa; se oculta al comenzar el fuego o al limpiar la sección. Conserva ancho, tiempos y ausencia de daño durante el aviso. Se comparte entre líneas estáticas, móviles y torretas.

El aviso de calor arranca al 20% de distorsión/refracción y al 25% de brillo. Sube con una curva suave hasta el máximo anterior al 92% del aviso, antes del disparo. Los tres parámetros se editan en el material de `fire_line_warning.tscn`.

Los avisos de líneas móviles usan una insignia circular negra, borde y flecha con el mismo shader animado de la franja de torretas. Escala base 1,7 (70% mayor), con márgenes ajustados para contener el pulso. Diseño editable en `scenes/bosses/moving_line_arrow_badge.tscn`. El reloj sigue el de la sección y respeta pausa.

Los avisos móviles pasan a fondo gris oscuro del metal, borde y flecha de color fuego uniforme con halos aditivos, sin el patrón de torreta. Todas las líneas activas tienen halo; las estáticas arrancan con destello fuerte que cae en 0,22 s a un halo suave, mientras móviles y torretas mantienen intensidad constante. Los ajustes globales están en Laser glow del recurso del boss, y colores/materiales en las escenas de aviso y halo.

El destello estático se fija al máximo antes del primer frame visible. Su halo no tiene oscilación: solo decae, sin crecimiento inicial ni pulsaciones durante la bajada. El halo permanente de móviles/torretas conserva su variación suave.

## Caída, salida y retirada de Fueguitos

Aviso de caída ovalado (proporción Y 0,6), con el mismo material de distorsión/refracción de los láseres y bordes cálidos. El daño de caída consulta el mismo óvalo. `landing_warning.tscn` permite editar la presentación.

Al terminar una ventana o cambiar de fase, el boss comprime Y durante 0,22 s y asciende durante 0,48 s; solo el sprite se anima, respetando el resto de transformaciones de escena. Al salir de pantalla se oculta y recién comienzan los 2 s de espera. Tiempos, compresión y altura se configuran en el recurso del boss.

El impacto reutiliza `scotch_mine_visual.gd`, sin daño adicional, con un destello naranja que decae en 0,1 s. Escena `landing_blast.tscn`. Los Fueguitos retirados por el encuentro generan `flame_transition.gd` en un nodo independiente para que el efecto termine aunque su sección se elimine.

Los extremos de los láseres sobrepasan el fondo 240 unidades para que sus remates y halos no queden cortados en los bordes, especialmente en oblicuas. Ajuste `Laser End Overscan` en el recurso del boss. Afecta extremos de líneas/torretas y longitud de barreras móviles; conserva direcciones y tiempos.


Aparición de torretas: escala pequeña, sobrepaso hasta 1,16 X / 1,45 Y, pequeño rebote y vuelta a la escala de escena en 0,46 s. Se anima solo el sprite desde su escala guardada; las colisiones permanecen iguales. Ajustes en el nodo raíz de `sausage_turret.tscn` (Spawn Seconds / Small / Peak / Recoil Scale). Todas las variantes comparten la animación, sincronizada con el reloj pausable de la sección.

Retirada de torretas: al terminar el láser se apagan rayos, avisos y daño, y el cuerpo hace un sobrepaso 1,12 X / 1,32 Y antes de encogerse a cero en 0,36 s. La retirada sobrevive al cambio de sección y respeta pausa. Ajustes Retire Seconds / Retire Peak Scale en el nodo raíz de `sausage_turret.tscn`.
