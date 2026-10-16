# Objetivo: 500 enemigos y más de 30 FPS

Estado al 16/10/2026: paso terminado y objetivo pausado a pedido del usuario. La mezcla de seis armas y la carga eléctrica superan 30 FPS de promedio y cumplen p95 menor a 33,3 ms. Quedan picos aislados importantes con seis Bloody; el objetivo general sigue abierto.

## Cambio de prioridad

El usuario redefine la meta práctica: funcionar bien con 250 enemigos simultáneos es suficiente para el diseño actual. Se retira el objetivo activo por ahora. Las pruebas de 500/750/1000 quedan como mediciones de margen, no como requisito de jugabilidad. No se ha medido todavía un caso específico de 250 con la implementación final de este paso.

Punto de reanudación: optimizaciones terminadas y nueve regresiones aprobadas; mezcla de seis armas con 500 enemigos alrededor de 40 FPS. Investigar primero los tirones aislados con seis Bloody (p99 119,2 ms, máximo 191,7 ms), luego medir 250 enemigos y validar muertes, yemas y reposición. No hay una migración de colisiones de gotas a medio implementar: esa alternativa sólo está propuesta.

## Medición

Godot 4.4.1, renderer Mobile/Vulkan, Intel i5-9400F a 2,90 GHz, RTX 3070 Ti, viewport 1920×1080, VSync desactivado y sin límite de FPS. Enemigos Mid reales con movimiento, hurtboxes y daño activos; vida elevada a un millón para mantener constante la población. Personaje inmortal con movimiento reproducible, semilla fija, sin oleadas automáticas ni peligros. Se mide carga sostenida, no las tandas de creación, muertes y reposición.

| Carga | Enemigos | FPS promedio | Fotograma p95 |
|---|---:|---:|---:|
| Inicial, seis Hydrant | 500 | 9,1 | 197,5 ms |
| Paso anterior, seis Hydrant | 500 | 40,4 | 28,8 ms |
| Paso anterior, seis Knifer con rebotes | 500 | 44,6 | 28,9 ms |
| Actual, mezcla con electricidad y explosiones | 500 | 39,6 | 30,7 ms |
| Actual, seis minipimer | 500 | 41,6 | 31,9 ms |
| Actual, seis Bloody, última comprobación | 500 | 53,1 | 23,4 ms |
| Paso anterior, mezcla con electricidad y explosiones | 750 | 21,0 | 62,7 ms |

Las mediciones actuales duran 25 segundos tras 5 segundos de calentamiento. La mezcla usa Hydrant, Knifer, Smasher, Bloody, Corpse Launcher y Electric Knife. Las cargas distintas de Hydrant agregan seis rebotes y dos perforaciones; se conservan las restricciones de cada arma.

30 FPS permite 33,3 ms por fotograma. P95 no representa el peor fotograma: seis Bloody registra p99 de 119,2 ms y máximo de 191,7 ms, aunque su promedio sea alto. La mezcla tiene aproximadamente 81,5 llamadas de dibujo y 1,9 ms de GPU. Los picos pendientes apuntan a CPU; la causa concreta de los picos de Bloody requiere confirmar el costo de sus contactos físicos simultáneos.

El resultado de 750 enemigos corresponde al paso anterior y no establece el límite de la implementación actual. No se ha vuelto a medir 750/1000 tras estos cambios.

Resultados locales en `documentacion-local/validacion/`: `combat-gpu-mixed.json`, `combat-gpu-electric.json`, `combat-gpu-bloody.json` y `combat-bloody-spikes.json`. Esa carpeta está ignorada por Git; el benchmark reproducible está dentro del proyecto.

## Cambios implementados

- EnemyCrowd comparte una cuadrícula espacial. Se desactivan los sensores grandes de separación y detección de objetivos que generaban decenas de miles de pares físicos. Las hurtboxes reales siguen activas y conservan sus formas.
- Separación con muestreo acotado y trabajo repartido: 32 enemigos por fotograma, hasta 16 vecinos/64 comprobaciones por muestra; cuadrícula actualizada cada 0,05 s. El desplazamiento de cada enemigo sigue actualizándose cada fotograma. Es una aproximación de separación, no una simulación exacta de todos los vecinos.
- Adquisición de objetivos con caché de 0,06 s y consultas espaciales. Rangos largos tienen una búsqueda completa de respaldo.
- Los rebotes eligen un objetivo aleatorio válido mediante muestreo por rechazo. Cuando quedan pocos objetivos sin golpear se usa una búsqueda de respaldo. Se mantiene la elección uniforme y no se introduce un alcance máximo nuevo.
- La cuadrícula usa registros tipados en sus consultas frecuentes, evitando búsquedas repetidas de campos en diccionarios. No cambia la frecuencia ni el presupuesto de vecinos.
- Movimiento enemigo con una sola escritura de transformación y una sola evaluación de ralentización por actualización. No se vuelve a escribir la orientación si no cambia.
- Partículas normales de impacto en dos MultiMesh; mayonesa reutilizable e instanciada; rayos eléctricos agrupados en MultiMesh. El shader calcula la geometría de las auras y ráfagas a partir de una instancia por efecto; las cadenas conservan segmentos individuales. El tiempo explícito permite congelarlos durante la pausa.
- Pool de textos de daño. Los golpes del mismo fotograma contra un mismo objetivo suman su valor en un número. El daño real, críticos, robo de vida y estados se procesan por golpe.
- Las ralentizaciones de igual intensidad comparten duración máxima; las de distinta intensidad mantienen sus duraciones. Se reutiliza el Hitbox del daño eléctrico. Los fogonazos eléctricos simultáneos del mismo enemigo tienen un intervalo cosmético de 0,06 s, sin limitar aplicaciones de daño.
- Se desactiva el procesamiento de componentes inactivos. Las barras ocultas no reformatean su número de vida; se actualiza cuando pasan a ser visibles.
- Las gotas de Bloody usan un pool de proyectiles precalentado. Se reinician daño, críticos, recorrido, efectos y registro de objetivos; al terminar la oleada se devuelven al pool. Si se llena, se instancia el disparo normalmente: no se pierde daño para sostener FPS.
- Hydrant selecciona sólo los objetivos que permite su perforación, con las distancias calculadas una vez. No ordena toda la lista volviendo a buscar hurtboxes en cada comparación.
- El multiplicador de movimiento por estados se actualiza al aplicar/expirar estados. No se recorren los estados de cada enemigo en cada consulta de movimiento.
- El selector de dificultad no reconstruye estilos cuando está oculto, y el color del reloj se cambia sólo cuando corresponde. No se elimina la actualización de progreso ni los desbloqueos.

- Los contactos de proyectiles reservan de forma atómica sus perforaciones y rebotes, independientemente del orden de señales de las áreas. Esto evita impactos y gotas adicionales cuando muchos enemigos se superponen. Bloody conserva la dirección entrante de cada impacto para orientar sus gotas.

## Presupuestos actuales

Estos son límites de memoria/trabajo visual, no cantidades de enemigos garantizadas:

| Sistema | Capacidad |
|---|---:|
| Gotas de mayonesa compartidas | 1800 partículas / 5400 instancias |
| Impactos normales compartidos | 128 partículas |
| Cadenas eléctricas | 8192 segmentos |
| Auras y ráfagas eléctricas | 1024 instancias por lote de tipo/cantidad de rayos |
| Textos de combate reutilizables | 384 activos, 64 precalentados |
| Gotas de Bloody reutilizables | 256 en caché, 64 precalentadas; sin límite de disparos activos |

Al llenarse el pool de textos se recicla el más antiguo. Los límites visuales no eliminan daño ni proyectiles. Las gotas de Bloody se reutilizan; los demás proyectiles y los enemigos todavía usan nodos/colisiones normales. No se afirma que todo esté en pooling ni en MultiMesh. Migrar sus simulaciones requiere medir y preservar colisiones, orden, estados y reinicio.

## Reproducción

Desde la carpeta del proyecto Godot, ejecutar una instancia gráfica del motor con:

```
Godot_v4.4.1-stable_win64.exe --path . --script res://tests/benchmark_combat.gd --disable-vsync --max-fps 0 -- --enemies=500 --loadout=mixed --seconds=20 --warmup=5 --output=combat-500.json
```

`--loadout=hydrant --quick` compara sin armas, seis armas completas y seis chorros sin daño/partículas. `--loadout=ricochet` prueba seis Knifer; `electric`, seis minipimer; `bloody`, seis Bloody; `corpse`, seis Corpse Launcher. `--combat-only` omite el caso sin armas. `--capture` guarda una captura tras cada caso activo, fuera del intervalo medido. El archivo relativo se guarda en `user://`; también admite una ruta absoluta. El perfil de progreso de las pruebas es independiente del guardado real. Cerrar otras pruebas antes de medir. Comparar varias ejecuciones; no comparar FPS de headless con la ejecución gráfica.

Para probar jugando, usar los botones de 500/1000 enemigos de selección de niveles. Ese modo conserva muertes, yemas y reposición; el benchmark automatizado usa mucha vida para comparar una población constante. Son pruebas complementarias.

## Pendiente al retomar

Investigar los picos aislados de seis Bloody, midiendo contactos físicos simultáneos. Una alternativa a evaluar es consultar el recorrido de las gotas con una consulta física reutilizada en lugar de múltiples señales de solapamiento; todavía no está implementada. Después validar creación por tandas, muertes, yemas, reposición, fuego y otras combinaciones, y repetir los límites de 750/1000 enemigos. No fijar un límite universal sólo por cantidad: proyectiles, impactos por segundo, rebotes y estados activos determinan el costo.

El cierre de este paso incluye regresiones de contactos densos, reutilización de gotas, Bloody, electricidad, estados, Hydrant, Smasher y modo de estrés. El objetivo queda pausado, no completado.
