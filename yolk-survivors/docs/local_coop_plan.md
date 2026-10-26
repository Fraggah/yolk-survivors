# Cooperativo local — análisis y propuesta

Fecha: 23/10/2026. Estado: el usuario autorizó comenzar por la base, dejando detalles y balance para después.

## Primera base implementada

### Acceso y selección actualizados — 25/10/2026

El acceso separado del Main Menu fue retirado. Se entra por **Play Game**, se activa **Coop Game** arriba a la derecha (también Y/Tab) y el dispositivo que activa el switch ocupa P1 automáticamente. El panel central conserva su ubicación y pasa a cuatro tarjetas; cada otro dispositivo mantiene A/X (Enter para el teclado) durante 0,65 s, configurable en el nodo CoopSelection de arena.tscn. Soltar antes cancela el ingreso. No se admite que el mismo dispositivo ocupe dos puestos ni más de cuatro participantes.

Cada jugador mueve su selector y confirma con su propio dispositivo; las marcas P1–P4 en la grilla indican sus personajes. Al confirmar todos, se reutiliza la animación normal de salida de grillas y desplazamiento hacia la izquierda. La selección de armas conserva cuatro filas de personajes y cuatro filas de armas emparejadas, con la grilla compartida a la derecha. Después se muestra una única selección de dificultad existente para todo el grupo. Back permite volver sin perder personajes ni dispositivos; desactivar Coop devuelve el panel individual.

Las tarjetas, sus filas, los marcadores y el activador tienen escenas guardadas y editables. `tests/verify_coop_selection.gd` comprueba ingreso mantenido, liberación, límite, dueño del activador, selecciones independientes, transición real, filas de armas, dificultad común y retorno a solo, con capturas de ambos menús. La tienda y el balance no se modificaron en esta iteración; su adaptación final para cuatro sigue pendiente.

### Base de combate anterior — 23/10/2026

La primera base se validó con dos participantes: teclado + mando o dos mandos. El acceso antiguo desde «Cooperativo local · prueba» quedó reemplazado por el flujo anterior. WASD/stick/D-pad cambia la selección; Enter/A confirma. Cada jugador confirma personaje y arma antes de empezar.

En combate: WASD + Espacio o stick + A. Cámara completa provisional. Esc/Start pausa; Select/Q desde pausa vuelve al menú. Al caer uno, permanece su sesión/build y el compañero continúa; ambos caídos termina la run. El caído regresa al empezar la siguiente wave. En el boss se espera hasta ganar o perder el encuentro.

Yemas repartidas con resto rotativo y reservas personales; XP base para ambos con modificadores propios. Cada uno tiene mejoras, cuatro ofertas, refresh, bloqueo (X/L sobre oferta seleccionada), combinación del primer par y venta de la última arma. El teclado/ratón solo compra en su panel; cada mando mueve un cursor personal. Todos confirman Listo antes de iniciar la siguiente wave.

Escenas editables: scenes/coop/local_coop.tscn, coop_player_panel.tscn, lobby_slot.tscn y lobby_player.tscn. Reparto, entrada y estado personal: resources/coop_player_session.gd.

Limitaciones de la base de combate anterior (validada con 2; los menús actuales admiten 4): sin escalado multijugador calibrado; menú de tienda provisional (inventarios en texto y acciones simplificadas); consumibles y cambios globales, Printer y Liquidation no entran en el pool cooperativo todavía. Incógnito conserva elección individual; un consumible especial puede venderse pero no conservarse en esta versión. Las victorias cooperativas todavía no se registran como victorias de personajes del modo solo. Reconexión automática solo del mismo índice de dispositivo; la reasignación a otro índice queda pendiente. El ingreso anterior con pulsación simple fue reemplazado por la pulsación mantenida descrita arriba.

Pruebas: tests/verify_local_coop.gd ejercita aislamiento, dispositivos, dinero/XP, spawn/objetivos, compras/mejoras, barrera Listo, caída/retorno, boss, reconexión y derrota del equipo. La sensación con mandos reales y el balance requieren prueba manual.

## Alcance y decisiones

- Propuesta: cooperativo local de 1–4 jugadores en una pantalla. Empezar a validar con 2, pero diseñar la base para 4. Un jugador usa el mismo sistema sin compañeros.
- Confirmado por el usuario: repartir las yemas recogidas entre billeteras personales; cada jugador recibe la XP base de las bajas, con su propio modificador de experiencia.
- Confirmado: selección de personajes simétrica, fichas centradas y slots a ambos costados. No desplazar las fichas al lateral durante esa pantalla.
- Dirección visual existente: selección de armas con personaje/arma a la izquierda y arsenal a la derecha; tienda y mejoras personales; inventarios de armas y pasivos visibles.
- A definir: cámara y retorno de jugadores caídos (consultas abiertas).
- Todo el resto de este documento es propuesta pendiente de revisión, incluidos balance, duración de pulsación para unirse y reglas de ítems globales.

## Referencia Brotato: alcance de lo verificado

Fuentes oficiales consultadas:

- Ficha del desarrollador en Steam: https://store.steampowered.com/app/1942280/Brotato/ — cooperativo local hasta 4 y Remote Play Together.
- Publicación Update 1.1: https://steamcommunity.com/games/1942280/announcements/detail/4529024857187287125 — referencia al lanzamiento del cooperativo. El cuerpo no se obtuvo completo con el lector web; no se usa para deducir fórmulas internas.
- Respuesta del desarrollador a un fallo de foco del teclado en cooperativo: https://steamcommunity.com/app/1942280/discussions/1/4634860082274863807/ — indica corrección en 1.1.5.1.
- Documentación de Godot para entrada y foco: https://docs.godotengine.org/en/stable/tutorials/inputs/controllers_gamepads_joysticks.html y https://docs.godotengine.org/en/stable/classes/class_viewport.html . La implementación debe cotejarse con la versión 4.4 del proyecto; no presupone mejoras de 4.5+.

Fuentes comunitarias encontradas describen unirse manteniendo confirmar en el mando, pero no son una especificación oficial y varían según plataforma. La pulsación y el flujo concretos siguientes son una propuesta para Armados. Tampoco se adopta como hecho un reparto económico o multiplicadores de Brotato: las guías consultadas contienen contradicciones. No se inspeccionó su código privado ni se hizo una prueba directa del juego.

Remote Play Together es una posible distribución futura del cooperativo local; no sustituye implementar entrada por dispositivo y no implica multijugador de red propio.

## Flujo para agregar jugadores

1. En selección, el primer dispositivo que confirma ocupa P1: teclado/ratón o mando.
2. Los puestos libres muestran «Mantené A / X para unirte». Propuesta inicial: 0,5 s, editable.
3. Un dispositivo no asignado crea exactamente un puesto; el evento de ingreso no selecciona ni confirma un personaje al mismo tiempo.
4. Cada dispositivo controla solo el cursor de su puesto, con número y color persistentes. Todos pueden elegir simultáneamente; se permiten personajes repetidos.
5. Confirmar fija personaje; cancelar desconfirma antes de permitir abandonar el puesto. P1 permanece mientras se configura la partida.
6. Cuando todos confirman, pasan a armas; se validan restricciones por personaje y sus armas iniciales individualmente. La dificultad/arena de inicio se elige una vez para el grupo.
7. La plantilla se cierra al iniciar la run. Primera versión: sin sumar ni retirar participantes a mitad de oleada o desde la tienda.

Combinaciones: teclado/ratón + hasta 3 mandos, o hasta 4 mandos. Un único puesto de teclado/ratón; no dividir el mismo teclado entre dos jugadores inicialmente. El ratón solo opera el panel de su dueño, sin robar el foco de los mandos.

Desconexión: pausar, conservar build y puesto, permitir reasignar un mando libre. No confiar únicamente en su índice temporal ni en GUID como identidad única: pueden variar o coincidir. Una reconexión ambigua pide elegir el puesto desconectado. No otorgar un personaje nuevo ni perder progreso al reconectar.

## Estado compartido y estado personal

Compartido: arena, oleada, dificultad, enemigos, fases del boss, música, pausa y transición entre pantallas.

Personal: personaje, estadísticas, vida, dash, armas, pasivos, monedas, reserva del frasco, experiencia, cola de niveles, recompensas, cuatro ofertas, bloqueos, coste de refresh y estado listo.

Crear un registro estable por puesto (PlayerSession o equivalente) y un coordinador de run/grupo. El nodo Player es su representación durante el combate, no la única ubicación de la build: caer no puede destruir el inventario que se necesitará para volver.

Evitar intercambiar temporalmente Global.player al procesar cada jugador: las señales, temporizadores y proyectiles pueden ejecutarse después y usar otro dueño. Pasar referencias explícitas a sesión/jugador. Una referencia de compatibilidad a P1 solo podría mantenerse durante la migración, nunca como resolución de dueño en combate o compras.

## Economía, experiencia y recompensas

Regla confirmada de yemas: el valor base recogido se reparte equitativamente; conservar el resto con reparto rotativo para que ningún entero se pierda ni favorezca siempre a P1. Da igual quién acerque físicamente la yema. Propuesta: los caídos conservan su parte.

Cada participante inicia con las 25 yemas actuales. Saldo, frasco, harvesting, ventas, costes y moneda de chocolate son personales. El bonus del frasco se calcula sobre la parte adjudicada a ese jugador, no sobre el valor total del pickup. El magnetismo decide quién atrae la yema, sin cambiar a quién se adjudica el dinero; cada pickup se cobra una sola vez.

Cada baja válida entrega la XP base completa a todas las sesiones participantes; luego se aplica el porcentaje de experiencia de cada personaje y se mantiene su resto fraccional. Propuesta: incluir caídos. El último golpe no concentra la XP. Más enemigos puede acelerar niveles: calibrar eso junto con el escalado, sin cambiar silenciosamente la regla aprobada.

Recompensas Incógnito — propuesta: una tirada personal por participante al derrotarlo, con la Suerte de cada uno y la tabla actual; se revelan al final de la oleada antes de las mejoras. Cada persona conserva o vende su recompensa. El extra de recompensas que esto introduce requiere balance y aprobación.

Bonus de drops (por ejemplo Doble Yema): propuesta de agregación a nivel de equipo mediante promedio de su probabilidad efectiva. Evitar aplicar cada bonus al total y volver a multiplicarlo al repartir. Esta agregación no está aprobada; merece simulación antes de fijarla.

## Combate y enemigos

- Cada arma, proyectil, quemado, electricidad, explosión y efecto persistente conserva el dueño original. No cambiar el dueño si cae o si otro jugador golpea después.
- Robo de vida cura al atacante; bonus por baja se atribuyen al dueño del golpe final según una política explícita. Eventos de equipo y eventos personales separados, con guardia contra doble conteo.
- Sin daño ni bloqueo de movimiento entre compañeros en la propuesta inicial.
- Enemigos normales: objetivo vivo más cercano, actualizado a intervalos y retenido hasta que deje de ser válido o convenga cambiar; evitar cambios por diferencias mínimas y búsquedas completas cada frame.
- Distancias mínimas de spawn se comprueban contra todos los jugadores vivos. Esto incluye torretas del boss, avisos, enemigos especiales y retorno de jugadores.
- Fueguitos y ataques dirigidos eligen participantes vivos. Fijar el objetivo al emitir la anticipación; no cambiar el destino tras avisarlo.
- Las mecánicas que siempre apuntaban al único jugador necesitan una política de reparto justa entre vivos, evitando concentrarlas siempre en P1.
- Boss único y fases compartidas. Mantener topes por tercio, estados e inmovilidad; verificar que golpes simultáneos no disparen dos transiciones o victorias.

## Cámara, caídas y pausa

Cámara pendiente de elección: propuesta simple de arena completa reutilizando encuadre jugable y márgenes actuales; alternativa de seguimiento de grupo con zoom dinámico, encuadre de todos los vivos y límites de arena. No permitir que un mando cambie la vista común para todos sin una política acordada. Solo mantiene el comportamiento actual de cámara.

Caídas pendientes de elección: propuesta de espectador hasta acabar la wave, regreso con vida completa antes de la siguiente, derrota solo cuando todos están caídos. En la pelea del boss equivaldría a esperar hasta vencer, porque no hay límite de 30 s; si se desea rescate durante esa pelea hay que definirlo antes. No congelar la run por la muerte de una persona, ni disparar su presentación de derrota a pantalla completa.

Pausa propuesta: cualquier participante puede abrirla; el dueño de esa pausa la navega y reanuda. Salir de la run pide confirmación y no permite consumir input de compra ni dash al cerrar. Desconectar un mando pausa la sesión completa.

## Tienda, mejoras y presentaciones

- Cuatro ofertas por persona, con las reglas actuales de rareza, sesgo de familia/tags, utilidad de tiers, máximo 2 armas, bloqueo y refresh exclusivo de su panel.
- Seis armas visibles y scroll para slots adicionales; ítems pasivos separados con cantidades y detalle propio. Estadísticas y popups quedan en su panel.
- Dos participantes: dos paneles. Tres: tres columnas, ofertas 2×2. Cuatro: cuadrantes 2×2.
- Selección de personajes conserva las fichas centradas y grillas laterales simétricas. Los layouts responsivos se guardan en escenas/contenedores editables, respetando AGENTS.md.
- Cada panel mantiene su cursor lógico de navegación. No usar un único foco global para los cuatro mandos; entrada por dispositivo, repetición y activación aisladas. Se puede reutilizar el navegador actual para menús globales.
- Ready bloquea compras y refresh del dueño, puede deshacerse antes de iniciar la transición; avanzar exactamente una vez cuando todos estén listos y no queden elecciones o animaciones pendientes.
- Mejoras: cuatro opciones y cola por persona, rarezas y refresh actuales. Cada uno termina sus propios niveles; luego se abre la tienda para todos.
- Moneda, yema de oro, Rebozado y Ayahuasca presentan resultados en el panel del dueño; no oscurecer la pantalla entera ni bloquear a compañeros. Antes de avanzar, esperar resoluciones pendientes.
- Música y ambiente siguen siendo únicos y compartidos.

## Ítems y cambios globales que requieren reglas

| Caso | Propuesta para revisar |
| --- | --- |
| Ayahuasca: retroceder waves | Afecta al grupo; anunciar cambio, invalidar Ready de todos y actualizar preview una sola vez. No regenerar ofertas ajenas ni recompensas al modificar el índice. |
| Ayahuasca: niveles o pérdida de stat | Solo el dueño; nuevos niveles resueltos antes de volver a Ready. |
| Ítem que fuerza arena o horda | Efecto de equipo; acumular pedidos y resolver conflictos en un único paso al cerrar la tienda, con una política visible. Falta elegir prioridad/cola. |
| Moneda de chocolate / Gambler | Solo billetera personal; coste 0 del Gambler y prohibición con 0 yemas se conservan. |
| Yema de oro / Rebozado | Solo consumibles y objetivos del dueño. |
| Vida, lifesteal, cadencias, inmunidad | Personales, sin curaciones cruzadas por Global.player. |
| Modificadores de enemigos | Agregación de equipo explícita; magnitud y stacking por definir. |
| Logros, victorias y daño | Una run local en el perfil actual; propuesta de registrar cada personaje participante, con reglas por definir para caídos y restricciones. No multiplicar contadores globales por cada receptor de una señal. |

## Auditoría del proyecto

- autoload/global.gd: player, coins, yolk_reserve, selección y armas equipadas únicos; muerte sin identidad.
- player.gd: lectura global de movimiento/dash y muerte que termina la run. Su PassiveItems ya está vinculado a una instancia, base útil para el aislamiento.
- menu_input.gd: mandos combinados, un menú y un foco; además alterna globalmente ratón/mando.
- arena.gd: un HUD, una XP, una tienda, recompensas y progreso de un personaje. Aquí se coordinan fin de wave, limpieza y victoria.
- coins.gd: magnetismo y cobro buscan Global.player; revisar disputa y cobro único.
- enemy.gd, spawner y mecánicas: persecución y distancias apuntan a un único jugador.
- weapon.gd: aún consulta Global.player para cooldown y orientación; hay que recorrer ataques y proyectiles especiales también.
- hitbox_component.gd: ya conserva source y aplica robo de vida al source; aprovechar y completar los recorridos que todavía usan globales.
- PassiveItems: enemy_killed escucha una señal global para todos; definir atribución antes de duplicar participantes.
- boss_encounter, cámara y feedback de daño: adaptar objetivo, indicadores, muerte de grupo y encuadre.
- Progression guarda current_character único; separar seguimiento de sesión y contadores de equipo.

No es solo un cambio visual ni conviene implementarlo duplicando la escena Player y ShopPanel sin aislar esos estados.

## Orden de implementación propuesto

1. Cerrar reglas abiertas. Registrar decisiones y casos de ítems globales. Aún sin cambios de gameplay.
2. Crear sesiones y dueño explícito; migrar un jugador al sistema y verificar que mantiene su comportamiento.
3. Dispositivos, ingreso/salida de selección, focos independientes y reconexión. Guardar la disposición correcta en escenas.
4. Combate de 2 participantes: spawn seguro, armas/estados, enemigos, cámara, HUD, yemas/XP y caídas. Incluir normal y boss.
5. Mejoras, recompensas y tienda simultáneas; adaptar presentaciones y confirmar Ready. Mantener reglas actuales por persona.
6. Extender pruebas a 3 y 4; cerrar balance de enemigos y economía con simulaciones, sin asumir coeficientes de Brotato.

## Verificación y criterios para darlo por listo

- Teclado + mando, 2 mandos, 3 y 4 participantes; ningún dispositivo ocupa dos puestos ni mueve otro jugador.
- Desconexión/reconexión conserva dueño, build y foco. Pulsar unirse no dispara selecciones o acciones.
- Estadísticas, dash, curación, estados y compras aislados; daño persistente retiene dueño.
- N yemas cobradas = N yemas base repartidas, sin pérdidas ni duplicaciones; restos equilibrados; bonus del frasco una vez. XP idéntica de base y modificadores distintos por persona.
- Recoger la misma yema en el mismo frame adjudica una sola vez. Caer no duplica ni elimina premios pendientes.
- Spawn y torretas nunca encima de ninguno de los vivos; anticipaciones no cambian de destinatario después del aviso.
- Cuatro mandos compran/refrescan simultáneamente sin mover otro foco; gastos y bloqueos correctos. Sin doble inicio al confirmar Ready simultáneamente.
- Ayahuasca, cambio de arena/horda, moneda, yema de oro, Rebozado e Incógnito mantienen reglas de propiedad y transición.
- 20 waves y boss: cae uno y el resto continúa; caen todos y termina una sola vez; boss recibe golpes simultáneos sin saltar topes de fase.
- Todas las arenas, cámaras, resoluciones objetivo y cambios de 1/2/3/4 en selección; revisar escena guardada y resultado en ejecución.
- Regresión de solo y prueba de estrés con cuatro builds distintas y ataques costosos, no solo cuatro instancias del mismo personaje.

El balance multijugador tendrá recursos editables para población, vida/daño enemigo, drops y boss. Los valores concretos quedan pendientes; primero validar aislamiento y corrección con un perfil de prueba identificado.
