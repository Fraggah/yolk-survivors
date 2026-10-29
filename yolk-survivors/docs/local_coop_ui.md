# Interfaz cooperativa local: propuesta aprobada

El usuario aprobó las cuatro pantallas de la vista previa `four-player-menus.html` y pidió conservarlas como referencia. Esta aprobación define la dirección visual; no implica implementar el multijugador todavía.

## Selección de personajes

- Acceso actual: Play Game → activador «Coop Game» arriba a la derecha. El dispositivo que lo activa ocupa P1; los otros tres puestos requieren mantener confirmar para unirse, hasta un máximo de cuatro. Se retiró el acceso separado del Main Menu.
- Feedback de selección: relleno de hover como en solo, borde con el color del jugador y marcas P1–P4; el movimiento con mando reproduce Selection Hover. El mouse actualiza únicamente el selector de su propio puesto.
- El activador tiene texto a la izquierda y un interruptor vertical a la derecha, con márgenes en `scenes/coop/coop_game_toggle.tscn`. Sigue recibiendo clics con un mando conectado; la capa de distribución deja pasar el mouse y el cambio de modo de entrada no borra selectores cooperativos.

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

- Implementación actual: cuatro cuadrantes fijos, incluso con dos o tres jugadores. Los puestos inactivos muestran «Jugador no conectado» y no permiten incorporarse desde la tienda.
- Mostrar por separado las armas y los ítems pasivos poseídos, con cantidades y detalle accesible con mando.

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

- En cooperativo, el clic sobre personaje o arma confirma Ready; el hover posterior respeta esa elección. Se requieren al menos dos participantes para avanzar. Con un único personaje confirmado se muestra el aviso para desactivar Coop Game y jugar solo, o esperar a otro jugador.

- El arsenal compartido permite recorrer armas incompatibles sin saltarlas. La etiqueta P1–P4 incorpora una ✕ únicamente para el jugador afectado; su panel muestra «No compatible con este personaje», desactiva Ready y confirmar reproduce el sonido de selección inválida. Los demás jugadores conservan sus propias compatibilidades.

- Cada cuadrante usa `coop_player_panel.tscn`: identidad y saldo, cuatro ofertas con bloqueo individual, inventarios separados y detalle fijo. Mando: stick/cruceta para recorrer ofertas, acciones e inventario; stick derecho para desplazar el detalle. Teclado: WASD, Enter, L y Page Up/Down. Estadísticas se consultan desde su botón. Los inventarios agrupan pasivos y permiten scroll horizontal.

- Base visual actual: cada cuadrante reutiliza `shop_card.tscn`, `item_card.tscn` y `stats_container.tscn` de single player. Su disposición está guardada en `coop_player_panel.tscn` y el lienzo se adapta al cuadrante. Las descripciones y estadísticas reciben explícitamente al propietario; nunca gastan la billetera global. Ready sustituye a Next Wave y el avance exige a todos los participantes.

- Flujo separado al terminar la oleada: recompensas de Incógnito → mejoras de nivel → tienda. Cada fase tiene una barrera común: quien terminó ve «Listo», sin ofertas de tienda. Las mejoras reutilizan `upgrade_card.tscn` sobre `OverlayPanel`, con fondo semitransparente; cada jugador resuelve sus niveles pendientes. La tienda se abre para todos a la vez y usa su propia confirmación Ready para iniciar combate.

- Cabecera compacta: pestaña P1–P4 con relleno del color del marco y texto del fondo. Sin nombre, título de tienda ni texto «Reserva». Combinar/vender se abren al confirmar un arma concreta del inventario; afectan a esa instancia y a su dueño. B/Escape o Volver cierran las opciones. La tipografía de ofertas aumenta un 25% y la de estadísticas un 12%, exclusivamente en los cuadrantes. Las yemas usan mipmaps y filtro lineal con mipmaps.

- Pestaña centrada arriba y saldo a la izquierda; ofertas subidas. Menú de armas con margen, separación, botones y colores del menú contextual de single player, situado sobre el slot seleccionado. Locks accesibles con direcciones + A/Enter y atajos X/L. SFX de compra, falta de yemas, refresh, lock/unlock, combinar, vender, confirmar y volver se disparan desde la acción para mouse y mando, sin añadir un clic genérico al mismo evento.

- Distribución del boceto: cuatro ofertas a todo el ancho, saldo y refresh alineados arriba, armas en una sola fila con espacios vacíos y scroll horizontal para slots extra. Abajo: Items a la izquierda, Stats al centro y Listo a la derecha. Items oculta ofertas y muestra pasivos; Stats oculta ofertas e inventarios y muestra primarias y secundarias juntas. Volver (mismo botón) o B/Escape restablece ofertas sin regenerarlas. Cada vista es independiente por jugador y Listo mantiene la barrera común.

- Detalles de inventario: reutilizan `weapon_tooltip.tscn`, con estadísticas del propietario, todos los campos de single player y efectos adicionales desplazables. El posicionamiento usa coordenadas locales del lienzo escalado para anclarse sobre el slot y quedar dentro del cuadrante. Comprar repone solo esa tarjeta, conserva otras ofertas y locks, evita preferentemente repetir la compra y mantiene el presupuesto de dos armas. La tipografía del cooperativo aumenta al menos un 50% respecto a la versión anterior; las descripciones largas permiten desplazarse con rueda/stick derecho.

- Identidad reforzada en tienda: fondo exterior y borde usan siempre el color P1–P4, también en puestos vacíos; una superficie crema inset de 8 px conserva la legibilidad. La selección cooperativa copia el estilo hover de single player (relleno y borde) en ofertas, locks y controles, tanto con mouse como mando.

- Compra y refresh compactos: alto igual a Lock; precio seguido de yema, refresh con icono de yema. Saldo superior reducido un 25%. La selección inicial se reaplica tras el primer layout para conservar el hover antes de navegar. Ready conserva el texto «Listo» y activa un oscurecimiento completo del cuadrante, reversible al desconfirmar.

### Gameplay cooperativo: HUD y cierre de oleada
- HUD nativo editable en `local_coop.tscn` y `coop_combat_hud.tscn`: P1/P2 arriba y P3/P4 abajo, vida y XP individuales. Solo aparecen participantes activos.
- El contador y frasco comunes muestran la suma de las billeteras y reservas personales; no cambian el reparto. Quedan bajo P1 y se ocultan al entrar al flujo de recompensas, mejoras o tienda.
- Al caer un jugador se instancia `player_corpse.tscn` en su posición y se reproduce RUN_DEFEAT, el mismo evento de muerte de solo. El huevo permanece hasta terminar la oleada.
- El fin de oleada reutiliza la retirada de enemigos y el vuelo de yemas al frasco, espera un segundo como en solo y luego abre las siguientes pantallas.
- El selector de escenarios de prueba no aparece durante gameplay ni tienda.

- Actualización HUD: P1–P4 dentro del extremo izquierdo de cada barra de vida. Cada billetera se muestra junto a sus barras hacia el centro de pantalla, con números del blanco HUD. El frasco único se ubica junto a P1 y muestra la suma de reservas personales. La geometría queda guardada en las escenas de HUD, incluida la variante derecha.

- Incógnito: la muerte usa el mismo confeti y evento de audio que solo. Cada baja sortea un único destinatario entre los participantes (también los caídos), con igual probabilidad. El pasivo se sortea con la Suerte y disponibilidad del destinatario, contando sus recompensas pendientes para límites de copias. Se revela al finalizar la oleada.

- Con cooperativo habilitado, el mouse queda oculto y sus eventos se descartan en selección, gameplay y menús cooperativos. Al salir del modo se restaura según el dispositivo de navegación. La dificultad es exclusiva de P1, abre enfocando el nivel 0 y permite recorrer niveles y acciones con stick/cruceta o WASD y confirmar con A/Enter/Espacio.

### Pausa cooperativa — 27/10/2026
- Reutiliza PausePanel y sus estadísticas/armas vinculadas al jugador que pausa, sin cambiar Global.player.
- Esc/Start abre durante combate, tienda, mejoras o recompensas; quien pausa controla la navegación, el cambio de estadísticas y Continuar/Salir.
- Congela los temporizadores de oleada/spawn y el gameplay. Al continuar desde una intermisión restaura sus paneles, cursores y ofertas, manteniendo el combate detenido.
- El diseño base de la pausa está guardado en pause_panel.tscn y es editable en Godot.

### Yemas compartidas — 27/10/2026
- Cada yema recogida acredita su valor completo a todas las billeteras personales, también a jugadores caídos. Las compras siguen siendo personales.
- El bonus de reserva y los pasivos de recogida se aplican individualmente, sin multiplicar pagos por repetir el evento de la misma yema.
- Imán: cada jugador vivo tira su probabilidad una vez por yema; se elige al azar entre los que tuvieron éxito, con igual probabilidad. El destino permanece fijo aunque otro jugador se acerque. Si el destinatario cae o desaparece, se elige al vivo más cercano sin nuevas tiradas. Las yemas del Yolker tiran al aterrizar. Todos reciben el valor al recogerse, independientemente del destinatario visual.

- Bloqueo persistente del mouse en Coop: todos los controles existentes y creados posteriormente ignoran el mouse; los callbacks de hover/clic de tienda, mejoras y recompensas también se bloquean. Se restauran los filtros originales únicamente al deshabilitar Coop o regresar al menú principal. Regresión: verify_coop_mouse_lock.gd.

- Selección inicial en Coop: Espátula I cuando el personaje la permite; si tiene restricciones incompatibles, se mantiene un arma válida. Dificultad inicial: nivel 0.
