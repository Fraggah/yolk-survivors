# Yolker e Incógnito

## Yolker / Yemero

Enemigo de recompensa que recorre la arena en línea recta, sin seguir al jugador ni desviarse por separación de la multitud. Al tocar el contorno real o detectar una pared física elige una dirección válida hacia dentro. Conserva daño, empuje, slow, rooted, airborne y las mecánicas del escenario.

Balance inicial editable: vida 60, crecimiento 12 por oleada y velocidad 175. El Big parte de 40 y crece 9, además del multiplicador temporal de vida que ya tenía. Cada baja de Yolker genera una explosión de **10 a 25 yemas individuales, de valor 1**. Se dispersan en círculo, describen un arco y aterrizan dentro de la arena. Durante el vuelo no se pueden recoger, ni siquiera con atracción al aparecer. Después usan la recogida habitual: las yemas solo pasan al saldo cuando alcanzan al jugador. Los bonus de cantidad de yemas de ítems se aplican sobre el total antes de repartirlo. Las recogidas normales de otros enemigos se conservan.

- Tamaño inicial: Yolker `visual_scale = 0.75`, Incógnito `0.65` (aproximadamente 35% menores que la primera versión), tanto en sus perfiles como en las escenas. Vida y crecimiento duplicados respecto de la primera versión.
- Escena y rango de recompensa: `scenes/units/enemies/enemy_yolker.tscn` (Minimum Yolks / Maximum Yolks).
- Vida, crecimiento, daño y velocidad: `resources/units/enemies/stats_enemy_yolker.tres`.
- Perfil para grupos/eventos del spawner: `resources/wave/enemies/yolker.tres`.

## Incógnito

Huevo blanco con un signo de interrogación. Usa el mismo movimiento lineal. Su animación alterna contacto con la punta superior, salto y media vuelta, contacto con la parte inferior, salto y media vuelta. La rotación se realiza sobre el sprite, conservando el ancla del suelo y las colisiones; el signo no se refleja horizontalmente. La pausa y la inmovilización detienen el movimiento/animación correspondiente.

Balance inicial: vida 48, crecimiento 10 por oleada, velocidad 262,5. No suelta yemas normales: su baja guarda un pasivo disponible y habilitado del catálogo actual. El sorteo usa la Suerte del jugador en ese momento. La recompensa queda oculta hasta el final de la oleada.

- Escena/animación: `scenes/units/enemies/enemy_incognito.tscn`, Bounce Period / Bounce Height.
- Estadísticas: `resources/units/enemies/stats_enemy_incognito.tres`.
- Perfil del spawner: `resources/wave/enemies/incognito.tres`.
- Movimiento y animación compartidos: `scenes/units/enemies/reward_roamer.gd`.

## Apariciones iniciales

Como configuración inicial de prueba, **oleada 1: Yolker en segundo 10 e Incógnito en segundo 18**, una unidad de cada uno. Se editan en Scheduled Spawns de `resources/wave/data/wave_01.tres`. Los perfiles pueden usarse también en otros eventos o grupos ponderados.

Tienen una población independiente **REWARD**, con **Reward Limit = 2** por oleada. Esto conserva el límite de enemigos comunes y evita que se confundan con Fueguito o un boss. No reciben multiplicadores de cantidad de los tests de multitudes ni el reemplazo temporal de recompensas de enemigos normales. El perfil controla tamaño/resistencia y mantiene las reglas habituales de aparición segura. Las mecánicas de las arenas los incluyen como unidades vivas; al terminar la oleada, morir el jugador o reiniciar, se limpian.

## Recompensa antes de mejoras

Orden al terminar la oleada: recogidas/harvesting y efectos de fin de oleada existentes → recompensas de Incógnito una a una → mejoras de nivel pendientes → tienda. En la última oleada, las recompensas aparecen antes de la victoria.

La tarjeta muestra rareza, icono, nombre y descripción del pasivo. **KEEP** usa la misma adquisición que la tienda, sin cobrar y conservando el comportamiento de pasivos/consumibles. **SELL** entrega su valor de venta habitual, calculado con la oleada de la baja y guardado con la recompensa. Vender no aplica estadísticas ni ocupa inventario.

No se duplica una recompensa al procesar dos veces la muerte o un botón. Los únicos pendientes se reservan para no sortear otro que exceda su límite; al conservar se vuelve a comprobar la disponibilidad. Si un efecto externo llenó ese límite antes de reclamarlo, queda disponible venderlo. Si una rareza no tiene candidatos disponibles, se intenta una inferior y, como último recurso, cualquier pasivo disponible. No se generan armas ni pasivos pendientes de implementar.

Morir o abandonar/reiniciar la partida descarta las recompensas no reclamadas. El panel acepta botones de mouse y navegación de mando, y permite abrir/cerrar la pausa sin resolver el premio.

## Rarezas y Suerte

Configuración independiente de tienda y mejoras en **`resources/rewards/incognito_loot.tres`**. Su script contiene la interpolación y el sorteo.

| Suerte | Común | Raro | Épico | Legendario |
|---:|---:|---:|---:|---:|
| 0 o negativa | 65% | 25% | 9% | 1% |
| 500 | 25% | 25% | 25% | 25% |
| 1500 | 0% | 33,33% | 33,33% | 33,33% |
| 3000 | 0% | 0% | 50% | 50% |
| 5000 o más | 0% | 0% | 0% | 100% |

Se interpola linealmente entre hitos. Todos los hitos y las probabilidades base están expuestos en el recurso, para ajustarlos sin modificar el sorteo. Se normalizan las probabilidades para que sumen 100%.

## Arte

Sprites generados con la herramienta integrada **imagegen**, transparencia real, guardados en el proyecto sin modificar los originales generados:

- [Yolker](../assets/sprites/Enemies/Redesign/yolker.png)
- [Incógnito](../assets/sprites/Enemies/Redesign/incognito.png)
- [Prompts completos y rutas de salida](special_enemy_art_prompts.json)

El sprite se normaliza según sus límites de alfa a 176 unidades antes de la escala del enemigo. Así, la resolución de la imagen no altera el tamaño del personaje ni la colisión.

## Verificación

`verify_incognito_loot.gd`: 180.000 sorteos en los hitos, distribución inicial, interpolación y eliminación progresiva de tiers, pasivos disponibles y reservas de únicos.

`verify_reward_enemies.gd`: aparición real, población separada, vida/recompensas protegidas, dirección independiente del jugador, cambios de dirección en las seis arenas, control y pausa, ambos contactos del huevo, bajas sin duplicados, revelado antes de mejoras, conservar/vender, mando, pausa en intermedio, última oleada, reset y muerte. Con `--capture` y renderizado habilitado guarda capturas del juego y de la tarjeta en tmp.

Regresiones: `verify_spawner_configuration.gd` y `verify_wave_run.gd`.

## Explosión física de yemas

`scenes/coins/burst_yolk.tscn` hereda la recogida normal y usa `burst_yolk.gd` para el lanzamiento. La recompensa se reparte en piezas de valor 1: no se acredita dinero al morir Yolker, durante el vuelo ni al aterrizar. Se conserva la recogida normal tras aterrizar, incluido el alcance de recogida y los ítems de atracción.

En la escena de Yolker, los campos **Burst Min Distance** (150), **Burst Max Distance** (320) y **Burst Flight Duration** (0,5 s) controlan la dispersión. La duración/altura de cada pieza varían ligeramente para evitar una figura uniforme. Las posiciones finales se ajustan al contorno de la arena. La pausa congela el lanzamiento.

Las piezas sin recoger conservan el comportamiento normal del final de oleada: van a la reserva, que no es saldo gastable. Su vuelo al frasco tampoco entrega yemas al saldo.

`verify_yolker_burst.gd` comprueba vida/tamaño, piezas individuales, dispersión, pausa, ausencia de pago durante lanzamiento/aterrizaje, pago único al recoger y reserva al terminar la oleada.

Los sprites de Yolker e Incógnito generan mipmaps y usan filtrado lineal con mipmaps para conservar bordes suaves al reducirse. Incógnito tiene un rebote de 26 unidades (la mitad del original).
