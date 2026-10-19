# Ayahuasca

Consumible inmediato, sin slot de inventario. Cuatro resultados de 25% cada uno. Pesos y cantidad de niveles configurables en `resources/items/passives/catalogue/item_098.tres`.

- Retroceder una oleada: la próxima oleada baja uno respecto de la que se iba a jugar. Desde la tienda posterior a la 5, la próxima pasa de 6 a 5.
- Retroceder dos oleadas: desde esa misma tienda la próxima pasa de 6 a 4.
- Ganar 10 niveles reales: se conservan XP enteros/fraccionales, se emite cada subida real (vida máxima, Huevo añejo y demás hooks), y se encolan las diez elecciones de mejora. Al continuar desde la tienda se eligen todas antes de arrancar la siguiente oleada; elegirlas no vuelve a incrementar el nivel.
- Reducir a la mitad una primaria positiva, elegida uniformemente entre las elegibles. Se comparte la lista de primarias del sistema existente; negativas y cero quedan fuera. Es una pérdida puntual: las ganancias futuras no se reducen.

El retroceso se limita a la próxima oleada 1. No reinicia jugador, armas, pasivos, mejoras doradas, niveles, XP, yemas, reserva ni progreso de logros. Mantiene las ofertas y sus bloqueos, precios y coste acumulado de reroll durante la visita actual. Actualiza el botón de siguiente oleada y su escenario previsto sin borrar las selecciones de escenarios. Las oleadas repetidas usan enemigos/recompensas nuevos y vuelven a conceder XP y yemas por los mecanismos habituales.

La reducción resuelve el valor visible a través de conversiones y modificadores finales. Por ejemplo, una probabilidad de bloqueo visible de 70% queda en 35%, aunque el valor bruto superara el límite; también contempla la transformación no lineal de velocidad de ataque. Conserva la regeneración, bonus y estadísticas secundarias ajenas al resultado, salvo las consecuencias normales de conversiones entre estadísticas.

Pruebas: `tests/verify_ayahuasca.gd` cubre probabilidades, compra efectiva, retroceso y límite, conservación de visita/progreso, primarias/negativas/secundarias, reducción con topes/modificadores, diez niveles/elecciones/hooks y XP al repetir oleada.
