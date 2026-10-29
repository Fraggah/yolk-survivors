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
