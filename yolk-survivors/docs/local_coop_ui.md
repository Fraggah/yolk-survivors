# Interfaz cooperativa local: propuesta aprobada

El usuario aprobó las cuatro pantallas de la vista previa `four-player-menus.html` y pidió conservarlas como referencia. Esta aprobación define la dirección visual; no implica implementar el multijugador todavía.

## Selección de personajes

- Dos grillas laterales, 30 espacios visibles en total, sin scroll.
- Columna central adaptable a 1, 2, 3 o 4 fichas de jugadores.
- Identificación por número P1–P4 y un acento de color consistente.
- Al completar la selección, las grillas laterales se desvanecen y las fichas elegidas se desplazan a la izquierda para entrar en la selección de armas.

## Selección de armas

- Grilla compartida de 40 espacios, 8 columnas por 5 filas, sin scroll.
- A la izquierda, columnas de personaje y arma de igual ancho.
- En cooperativo, cuatro filas emparejan cada personaje con su arma elegida.
- Ambas columnas coinciden arriba y abajo con la altura de la grilla de armas.
- Back arriba a la izquierda y título centrado en ambas selecciones.

## Tienda

- Cuatro cuadrantes independientes para cuatro jugadores.
- Cada jugador tiene saldo, cuatro ofertas, compra, bloqueo, refresh e inventario propios.
- Estadísticas e ítems se consultan dentro del cuadrante de su jugador, sin tapar los demás.
- Cada jugador confirma READY; se avanza cuando todos están listos.
- Mantener la distinción entre identidad del jugador, rareza de las ofertas y estado LOCKED. El bloqueo invierte texto y fondo.

## Mejoras por nivel

- Cuatro cuadrantes independientes.
- Cada jugador tiene cuatro opciones, refresh y su propia cola de niveles pendientes.
- Al terminar sus elecciones, el cuadrante indica que espera a los demás.
- Se pasa a la tienda cuando todos terminaron.

## Referencia visual aprobada

Vista previa interactiva original:

`C:/Users/Fraggah/.codex/visualizations/2026/10/08/01a11c47-50f3-7473-89d8-9935d6a88b85/four-player-menus.html`

Los valores, precios y equipos de esa vista son ilustrativos, no decisiones de balance. La interfaz muestra una propuesta de funcionamiento; no prueba que exista soporte multijugador en el juego.

La investigación de Brotato sirvió como referencia para la separación por jugador y la confirmación conjunta. La distribución visual aprobada es la de Armados.
