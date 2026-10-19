# Hongo desconocido (99)

Pasivo legendario único. Entra en la tienda y el inventario normal, con un máximo de una copia.

Cada 5 segundos de combate elige uniformemente uno de nueve resultados (1/9 cada uno). En una oleada de 30 segundos se activa en 5, 10, 15, 20 y 25; no al finalizarla. Las pausas y la tienda no consumen tiempo. El contador se reinicia por oleada.

1. Explosión centrada en el jugador, radio base 220 (afectado por Área de efecto). Daño `max(0, Efectos + vida máxima × 0,10)`. No vuelve a multiplicarse por el escalado porcentual antiguo de Efectos ; después se aplica daño general + daño explosivo, una sola vez. Solo afecta enemigos y no aplica estados de las armas.
2. +100 puntos de daño porcentual durante 4 segundos.
3. +50% de velocidad de movimiento durante 4 segundos, calculado sobre la velocidad sin el propio bonus.
4. +100 puntos de velocidad de ataque durante 4 segundos.
5. Pierde el 50% de la vida actual, sin morir por esta pérdida.
6. Burning durante 4 segundos, un tick de 1% de vida máxima cada 0,5 segundos.
7. Shocked con un golpe del 5% de vida máxima y visual de 1 segundo, sin Slow ni propagación.
8. Recupera 10% de vida máxima, limitado por el máximo.
9. Recupera toda la vida.

Burning y Shocked usan el sistema real de estados y sus visuales; activan Recalentado, Sobrecarga y Guante térmico según corresponda. Los valores de daño propio se fijan al activarse y no escalan con Efectos del jugador. Se conservan las protecciones habituales del sistema de vida y la mitigación de estados por armadura.

Los buffs usan fuentes temporales independientes, no alteran ganancias permanentes ni se amplifican por pasivas de ganancia de estadísticas. Al expirar o terminar la oleada se quitan. Repetir un buff lo refresca, sin acumularlo consigo mismo. Destruir el ítem elimina sus buffs y vuelve a habilitarlo en la tienda.

Todos los parámetros `mushroom_*` están en `resources/items/passives/catalogue/item_099.tres`. Yema de oro mejora las magnitudes favorables y reduce las penalizaciones; no cambia las probabilidades ni el intervalo entre activaciones.

Verificación: `tests/verify_unknown_mushroom.gd` cubre los nueve resultados, daño/alcance, duración de buffs, estados, pausa, fin de oleada, unicidad, mejoras doradas y eliminación.
