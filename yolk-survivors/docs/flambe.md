# Flambeado

Pasivo activo del catálogo. `flambe_damage_per_enemy = 10.0` en `resources/items/passives/catalogue/item_084.tres`.

Aporta temporalmente +10 puntos porcentuales de daño general por cada enemigo vivo en Burning y por copia del ítem, sin límite inicial. Con 10 enemigos y una copia: +100%; con dos copias: +200%. El bono aparece en la estadística de daño general y usa su pipeline normal de cálculos y modificadores finales.

Cada enemigo cuenta una vez aunque tenga varias fuentes, armas o contribuciones de fuego. El jugador quemándose no cuenta. Una fuente que termina no elimina el aporte si otra sigue activa. Muerte, fin de Burning, limpieza de estados, retirada de fin de oleada y salida del árbol actualizan el conteo. El contador global vuelve a cero al desmontar la escena.

Se usa un contador mantenido por eventos del controlador de estados: no hay consultas de todos los enemigos por frame. Los refrescos de un Burning ya activo no incrementan el contador ni recalculan las estadísticas. El bono se administra como fuente temporal independiente (`flambe`), sin acumular ganancias permanentes ni retirar las obtenidas de otros ítems. Comprar el ítem con enemigos ya en llamas aplica el bono inmediatamente.

La Yema de oro aumenta el aporte por enemigo de esa copia y la destrucción elimina únicamente su aporte, mediante el registro de pasivos.

Pruebas: `tests/verify_flambe.gd`; regresiones del Guante térmico, fuegos compartidos de Cayena y catálogo.
