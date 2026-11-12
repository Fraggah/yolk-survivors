# Diagnóstico de combate cooperativo — 2026-10-29

Se reprodujeron caídas fuertes con la combinación reportada: P1 con seis Bloody;
P2 con Carolina Reaper, Cayena, Kitchen Torch, dos Electric Knife y B Knife.
El cuello principal identificado es el procesamiento de las estelas y del quemado.
La electricidad, los disparos y sus colisiones agregan carga, pero quitar solamente
Cayena y Carolina Reaper reduce mucho más el costo total en esta reproducción.

## Método y límites

- Godot 4.4.1, Compatibility, RTX 3070 Ti, viewport 1920 × 1080, sin VSync ni límite de FPS.
- Se ejecuta el cooperativo real: equipamiento, enemigos que persiguen, proyectiles,
  fuego, electricidad, textos de daño y yemas. Movimiento automático de los jugadores.
- Dos jugadores con el equipo reportado; cuatro jugadores con seis armas mixtas por
  persona. Recorrido adicional de las 40 familias implementadas, en dos tandas.
  Los dos selectores de mascotas sin escena de combate quedan excluidos.
- Armas tier IV para una carga alta reproducible. No se conocen tiers, pasivos,
  estadísticas, cantidad de enemigos ni configuración gráfica de la sesión original.
- Los primeros cinco segundos se descartan. Cada caso corre en un proceso separado;
  las pruebas de rendimiento no se ejecutan simultáneamente entre sí.
- Modo de presión sostenida: enemigos con mucha vida, sin morir, para separar el
  costo de combatir del costo de instanciar enemigos y recompensas.
- Modo `--mortal`: 250 HP por enemigo y reposición máxima de uno por frame. Permite
  muertes, generación y recogida real de yemas sin una ráfaga masiva de spawns.
- Las yemas se contabilizan con el grupo real `yolks`. Hay 150 iniciales y se suman
  las bajas en modo mortal. No se termina la oleada ni se envían al frasco.
- El muestreo de efectos usa el delta del motor, no el tiempo de pared del frame:
  así conserva el límite de delta de Godot cuando el rendimiento cae mucho.
- Los tiempos incluyen instrumentación, debug y condiciones sintéticas. Sirven para
  localizar cuellos de botella, no para prometer los FPS de una partida exportada.

## Evidencia

En el aislamiento inicial con 250 enemigos resistentes y dos jugadores:

| Variante | Tiempo medio del frame | FPS medios aproximados |
| --- | ---: | ---: |
| Enemigos, sin armas | 13,2 ms | 76 |
| Equipo reportado, quitando ambos chiles | 23,3 ms | 43 |
| Sin Carolina Reaper, conservando Cayena | 81,0 ms | 12 |
| Sin Cayena, conservando Carolina Reaper | 155,6 ms | 6 |
| Equipo completo, exploración inicial | 202,9 ms | 5 |

Estas cifras son exploratorias previas a las optimizaciones. El muestreo de delta se
ajustó después para los casos de FPS extremadamente bajos; no deben usarse como una
comparación estricta antes/después. Los resultados finales están en el JSON adjunto.

Con la versión optimizada, muertes activas y reposición gradual:

| Variante (tier IV) | Frame medio | P95 | FPS medios |
| --- | ---: | ---: | ---: |
| 2 jugadores, 200 enemigos, sin ambos chiles | 19,3 ms | 25,1 ms | 51,8 |
| 2 jugadores, 200 enemigos, equipo reportado | 64,4 ms | 79,8 ms | 15,5 |
| 4 jugadores, 200 enemigos, cada uno con el equipo mixto | 82,1 ms | 104,7 ms | 12,2 |

En esos casos se repusieron respectivamente 105, 372 y 342 enemigos muertos. Las
duraciones fueron 25, 25 y 30 segundos. El caso completo causa más bajas y estados;
no es una comparación de trabajo idéntico, sino una ablación de armas manteniendo
la misma configuración inicial. La diferencia sigue siendo suficientemente grande
para confirmar la prioridad de investigar las estelas.

En el recorrido de cuatro jugadores, el primer grupo de 24 armas (disparo/melee y
electricidad) dio unos 32 ms/frame. El grupo restante, que incluye las estelas de
fuego, llegó a unos 140 ms/frame. Es una comparación entre grupos de armas, no un
ranking individual de cada arma.

La GPU se mantuvo aproximadamente entre 4 y 13 ms en los casos pesados, mientras el
frame completo tardaba mucho más. El trabajo de CPU/lógica es el problema principal
de esta reproducción; eso no implica que el renderizado sea gratuito.

## Causas concretas

1. Cada parche de Cayena y cada parche que deja un tornado recorren todos los
   enemigos. Las entradas al fuego se comprueban cada frame y el daño en cada tick.
   El costo crece con **parches × enemigos**, además de las columnas y otros ataques.
   En tier IV, un Carolina Reaper mantiene cuatro tornados. Con cuatro jugadores
   usando esa arma se observaron alrededor de 140 estelas de Reaper simultáneas.
2. `_set_trail_hit()` duplicaba recursos de estado, listas y registros de reparto
   para cada enemigo alcanzado, aun con los mismos contribuyentes.
3. Refrescar un quemado invalidaba la distribución de llamas de `FireVisual`,
   obligando a reconstruir su MultiMesh aunque la configuración fuera idéntica.
4. Los quemados con contribuyentes reconstruían pesos y registros cada frame,
   aunque solamente cambiaban sus temporizadores y no los participantes.
5. La presentación sigue teniendo costo: numerosas instancias de fuego, materiales,
   draw calls y textos. No se encontró evidencia suficiente para atribuir el problema
   principal a una fuga de nodos; las mediciones son sesiones cortas, no una prueba
   de ausencia de fugas durante una run completa.

## Cambios aplicados

- Cachear los perfiles de daño/estado de cada subconjunto de contribuyentes de una
  estela; conservar los registros de cada arma.
- Descartar segmentos alejados con una prueba rectangular barata antes de calcular
  la intersección oval. Se conserva el barrido para enemigos que cruzan entre frames.
- Conservar la distribución de llamas y los parámetros visuales cuando la misma
  configuración y color simplemente se refrescan.
- Reconstruir los pesos de un quemado compartido al refrescar/agregar o expirar un
  contribuyente, en lugar de hacerlo en cada frame sin cambios.

No se modificaron daño, duración, cantidad de tornados, cadencias, tiers ni recursos
de balance. Tampoco se cambió el diseño de escenas/UI ni la recogida al frasco.

## Validación funcional

Pasaron `verify_cayenne_stacking`, `verify_cayenne_contact`, `verify_fire_visual`,
`verify_reaper_columns`, `verify_reaper_permanent` y la compilación estricta de
los 195 scripts de producción. Se agregaron comprobaciones para reutilización
del perfil de estado y conservación de la distribución de llamas al refrescar.

La prueba general antigua `verify_status_system` no pasa: en su línea 39 espera
un bloqueo garantizado al asignar 100 a `block_chance`, pero la implementación
actual limita `get_block_chance()` a 70. Puede fallar antes de llegar a cualquier
quemado. No se modificó el balance de bloqueo ni esa prueba ajena al cambio;
no se presenta como una validación aprobada del sistema completo de estados.

Las mejoras reducen trabajo redundante, pero **no resuelven todavía el escalado de
parches × enemigos**. El siguiente cambio de mayor impacto sería un índice espacial
de contacto o un procesamiento conjunto de estelas, que preserve barridos, ticks,
contribuyentes y cadencias por enemigo. Después conviene agrupar la presentación
del fuego. Reducir enemigos o nerfear armas no sustituye esa optimización.

## Repetir la prueba

Desde la raíz del repositorio, con la ruta local de Godot:

```powershell
& 'C:/Godot_v4.4.1-stable_win64.exe' --path yolk-survivors --rendering-method gl_compatibility --script res://tests/benchmark_coop_combat.gd -- --case=reported --players=2 --enemies=200 --seconds=30 --tier=3 --mortal
```

`--tier=0..3` significa I..IV. Otros casos: `baseline`, `no_spicy`, `no_reaper`,
`no_cayenne`, `all` y `catalogue`. Para el catálogo usar cuatro jugadores y
`--batch=0` / `--batch=1`. Sin `--mortal` se mantienen enemigos resistentes.
Los resultados se guardan en `tmp/coop-benchmark-*.json`.

Ver `coop_combat_performance_results.json` para las mediciones conservadas.


## Segunda pasada: ticks agrupados y estelas menos densas

Prueba release con Mobile (la configuración del proyecto), 1920 × 1080,
i5-9400F y RTX 3070 Ti. Cuatro jugadores, seis armas tier IV por jugador,
150 enemigos de mucha vida, 20 segundos y cinco de calentamiento excluidos.
No comparar directamente estos resultados con los primeros ensayos debug/Compatibility.

- Antes de este paso: 40,54 FPS, 24,67 ms por frame; p95 30,71 ms.
- Después: 42,39 FPS, 23,59 ms por frame; p95 28,71 ms.
- Máximo de segmentos de estela del Reaper: 142 → 76.
- Todavía no se alcanza el objetivo de más de 60 FPS.

Burning agrupa dos ticks originales en un evento de daño. La duración y los
modificadores de velocidad de fuego se conservan. Al expirar se entrega el tick
original pendiente, si lo hay: cinco ticks de daño D producen 2D, 2D y D.
Los aportes de armas distintas conservan su atribución y vencimiento independiente.
Esto cambia la frecuencia de los impactos y, por tanto, de los procs ligados a ellos.

Configuración editable:

- `effects/fire_contacts.tscn`: `burn_tick_batch = 2` (1 restaura la cadencia anterior).
- `resources/items/weapons/chili/cayenne/stats_cayenne*.tres`: separación 48 y radio +15%.
- `resources/items/weapons/chili/carolina_reaper/stats_carolina_reaper*.tres`: separación de estelas
  36 y multiplicador de radio 1,15. El tornado principal conserva su tamaño.

Las zonas más grandes amplían ligeramente la cobertura; es un ajuste de jugabilidad
además de una optimización. El daño de impacto directo del suelo no se duplica:
la agrupación afecta al estado Burning.

Validación: `tests/verify_batched_burning.gd` compara agrupación 1 y 2 con
varias duraciones, reaplicaciones y contribuciones de duraciones distintas;
comprueba además la entrega final 6/6/3 para cinco ticks originales de daño 3.


## Estados sin reaplicación y tercera pasada visual

Regla autorizada posteriormente: un enemigo con electricidad no recibe otra
aplicación eléctrica hasta que el estado expire. Burning sigue la misma regla:
no se acumulan nuevos quemados de otras fuentes ni se renueva la duración.
Ambos estados pueden coexistir. Los jugadores conservan sus reglas anteriores.
La primera aplicación de un efecto compartido puede contener los aportes combinados
que ya forman parte de ese ataque; las aplicaciones posteriores se rechazan.
La propagación eléctrica evita gastar destinos en enemigos ya electrificados.

Ambas opciones están en `effects/fire_contacts.tscn`:
`prevent_burning_reapplication` y `prevent_electric_reapplication`.
Es un cambio de daño y atribución entre jugadores, no una optimización equivalente:
la fuente que inicia el quemado conserva ese daño hasta que expire.

Ahorros adicionales: limpieza de fuentes visuales por señal al salir del árbol,
buffers de estelas actualizados solo cuando cambia su composición, una instancia
por unidad quemada con varias llamas calculadas en el shader, descarte temprano
de contactos de tornado en cooldown y suspensión de actualizaciones de tienda oculta.
La escena GroundFire contiene los materiales y la configuración editables.

Resultados (mismo hardware y modo release/Mobile anterior):

| Caso | FPS promedio | p95 ms |
| --- | ---: | ---: |
| Cuatro jugadores, seis armas mixtas tier IV, 150 enemigos resistentes | 66,18 | 18,58 |
| Catálogo, primeras 24 armas, cuatro jugadores | 96,09 | 12,35 |
| Catálogo restante, completando 24 armas, cuatro jugadores | 70,27 | 17,36 |
| Mezcla exigente con muertes y reposición | 57,47 | 22,09 |

El objetivo sigue pendiente: el promedio supera 60 en combate sostenido, pero
hay frames por debajo y la prueba con muertes/reposición aún promedia menos de 60.
La segunda tanda del catálogo se corrigió para completar siempre seis armas por
participante y verifica también su equipamiento en release. La medición corregida
mantuvo exactamente 150 enemigos activos durante toda la muestra.

Evidencia estructurada: `coop_combat_optimization_results.json`.
Pruebas adicionales: `verify_status_reapplication.gd`, `verify_native_fire_contacts.gd`,
`verify_batched_burning.gd`, `verify_player_healing.gd` y revisión estricta de scripts.


## Cuarta pasada: bajas, apariciones y feedback

- Partículas de impactos: animación de caída, giro, fricción y desaparición en GPU.
  Los buffers se cargan cuando aparece una partícula, sin actualizar cada transform
  por frame. El límite visual es 96 y se configura en `effects/enemy_hit_feedback.tscn`.
- Textos de daño: límite simultáneo 96, agrupación 0,12 s y duración 0,75 s,
  editables en `autoload/combat_texts.tscn`. El daño calculado no cambia.
- Nuevas entradas de EnemyCrowd se agregan al índice pendiente sin invalidar
  toda la cuadrícula al aparecer cada enemigo. La reconstrucción periódica continúa.
- Se probó una reserva de escenas nuevas fuera del árbol (sin reciclar enemigos
  muertos), limitada a 24 nodos y con reposición en frames disponibles.
  Se descartó: la repetición dio 57,26 FPS y p95 22,25 ms, sin beneficio consistente.
  Spawner conserva su ruta de instanciación original.

Las pruebas de FPS ahora distinguen explícitamente `profile_enabled`:
por defecto no se habilitan los cronómetros internos de cada efecto (igual que
el juego). `--profile` los habilita para diagnosticar; las mediciones anteriores
los tenían activados. El renderer, resolución, población y armas se conservan.
No atribuir toda la diferencia entre ambos modos a una optimización.

El combate con muertes y reposición llegó a 64,4 FPS promedio con la nueva
animación de impactos; con escenas preparadas dio también 64,4 FPS y p95 19,6 ms.
La comparación sin preparación dio 59,95 FPS y p95 20,99 ms. Hay variación entre
pasadas; consultar las mediciones estructuradas y repetir antes de generalizar.
Se mantienen hasta 150 enemigos activos, cuatro jugadores y 24 armas tier IV.
Las recogidas y recompensas se ejecutan normalmente; no se prueba el frasco final.

El objetivo aún no se considera terminado: quedan frames por debajo de 60 FPS.
Las opciones descartadas fueron el render separado (sin mejora y con error del
motor al cerrar), el shader de respiración de yemas y el cambio de formas de spawn.
Sus cambios experimentales se retiraron. Las yemas conservan su animación y lógica.

Validación del código retenido: altas incrementales del índice, geometría real de partículas enviada al renderer,
reutilización y pausa de textos, imanes cooperativos, contactos rápidos de fuego,
y revisión estricta de 198 scripts. La captura renderizada conserva los efectos.

La mejor pasada no representa una garantía: la reserva experimental se retiró
tras la repetición desfavorable. Los resultados de esa variante quedan como
experimento descartado en el JSON. No están habilitados ni incluidos en el código
actual el cache de enemigos, el render separado ni el shader de respiración de yemas.
