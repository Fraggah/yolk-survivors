# Yema de oro

Consumible de la partida. La compra suma una carga al contador de la tienda, sin ocupar un slot de pasivos. Pulsar el contador abre una confirmación; confirmar habilita la elección de un arma o pasivo propio. Cancelar, cerrar la tienda o señalar algo inválido no consume cargas. La carga se gasta al aplicar a una copia válida.

Resultados configurables en `resources/items/passives/catalogue/item_078.tres`, `golden_outcome_weights`, en este orden:

| Resultado | Peso |
| --- | --- |
| Destrucción | 25 |
| +10% beneficios, −10% penalizaciones | 40 |
| +25% beneficios, −25% penalizaciones | 23 |
| +50% beneficios, −50% penalizaciones | 10 |
| Perfecta: +100% beneficios, −100% penalizaciones | 2 |

Se pueden aplicar más yemas: cada resultado escala los valores actuales. Una copia mejorada se separa del stack; las compras nuevas permanecen normales. Los recursos originales del catálogo no se modifican. El inventario tiene desplazamiento para acceder a todas las copias y armas.

Las armas mejoran daño, escalado, cadencia (reduciendo cooldown), alcance, crítico, empuje, proyectiles y magnitudes de sus efectos de juego. Se preservan identidad, tags, tier y parámetros visuales. Los costes de vida y modificadores negativos se reducen. Combinar armas conserva la mejor mejora de las donantes, sin sumar ambas.

Los pasivos conservan aportes individuales: destruir una copia retira exactamente sus ganancias/penalizaciones vigentes y sus efectos continuos, respetando conversiones y bonus del personaje. Las recompensas permanentes ya obtenidas (p. ej. regeneración ganada en niveles anteriores) no se deshacen; cesan los disparadores futuros. Los únicos destruidos (`max_copies = 1`) vuelven al catálogo de ofertas: se pueden comprar de nuevo, pero no acumular mientras se conserva una copia.

Los beneficios enteros se redondean hacia abajo. Brazo auxiliar tiene una regla explícita: una copia solo concede 2 espacios si obtuvo una mejora perfecta; cualquier otra mejora conserva 1. Se mantienen hasta 3 copias, con hasta 12 armas al perfeccionar las tres. Destruir un Brazo no destruye armas existentes: bloquea compras que superen el nuevo límite hasta liberar espacios.

El brillo animado aumenta según la mejora acumulada. Una mejora perfecta añade destellos orbitales; aparece en el slot y sobre el sprite del arma en partida, conservando el contorno del tier.

Consumibles de efecto inmediato excluidos del inventario: Moneda de chocolate, ítems que fuerzan un escenario, Bolsa de mercadería y Diente libre. La Yema de oro se almacena exclusivamente en su contador.

Verificación: `tests/verify_golden_yolk.gd`, regresiones de catálogo, ofertas bloqueadas, fuego y pasivos condicionales; previsualización con render real de Godot.
