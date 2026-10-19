# Giro de tortilla

Pasivo activo en el catálogo: `resources/items/passives/catalogue/item_082.tres`.

Al terminar un lanzamiento Airbourne causado por el jugador, se sortea un relanzamiento con `proc_chance` (10% por copia, acumulado aditivamente hasta 100%). No afecta al empuje normal ni a lanzamientos de enemigos. Cada aterrizaje elegible vuelve a sortear la probabilidad. Si falla, termina el movimiento.

- Primer relanzamiento: 75% de la velocidad real anterior y 50% de su duración.
- Segundo relanzamiento: vuelve a aplicar ambos factores; queda en 56,25% de la velocidad y 25% de la duración del original.
- Máximo dos relanzamientos adicionales por lanzamiento inicial, independientemente del número de copias. Un nuevo lanzamiento de un arma reinicia el contador.

Conserva dirección, daño de colisión, robo de vida, registro de daño del arma y el callback de Salteado feroz. Se limpia el historial de contactos para permitir una colisión por enemigo en cada nuevo tramo. No se vuelven a aplicar resistencia, Control de masas ni Pancake. La duración y la velocidad parten de los valores reales que ya traía el lanzamiento.

Los campos `relaunch_speed_multiplier`, `relaunch_duration_multiplier` y `relaunch_maximum` son editables en el recurso. Entre copias se suman las probabilidades; se usa el mejor multiplicador de retención y el mayor límite configurado, sin sumar los límites. La Yema de oro mejora la probabilidad y reduce las pérdidas de fuerza/duración, respetando el límite de cadena. Destruir una copia actualiza inmediatamente sus aportes mediante el registro de propiedad.

Pruebas: `tests/verify_tortilla_flip.gd`, regresión `tests/verify_pancake.gd` y catálogo `tests/verify_catalogue_passives.gd`.
