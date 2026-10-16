# Lanzaplatos

Sprite nuevo de perfil, con borde y profundidad similares a la pila del arma. El proyectil conserva rotación cero mientras cambia de dirección.

Cada impacto válido hace daño una sola vez y tira `plate_break_chance` (0,8 por defecto). Si se rompe, desaparece y emite fragmentos; si sobrevive busca otro enemigo sin golpear y rebota. La cantidad fija de rebotes/perforaciones no controla esta arma: la supervivencia se decide en cada impacto. Si no existe otro objetivo válido también se rompe. Expirar por alcance o salir de pantalla sólo limpia el proyectil, sin inventar un impacto.

Los cuatro `effects_plate_launcher_N.tres` configuran probabilidad, cantidad de fragmentos, duración y velocidad: `plate_break_chance`, `plate_fragment_count`, `plate_fragment_duration`, `plate_fragment_speed`. El borde de los fragmentos usa el beige claro del plato (#c4bba7) y un ancho de 0,1, ajustables con `plate_fragment_edge_color` y `plate_fragment_edge_width`.

SoundManager expone `plate_break` en el grupo Armas - impactos especiales, sin audio asignado. La rotura llama `play_stream` con evento plate_break y utiliza el bus SFX y los límites existentes. Los fragmentos son un nodo de dibujo sin colisiones, respetan pausa, se limpian solos y pertenecen al grupo de proyectiles para limpieza de oleada.

Validación: `verify_plate_launcher` prueba daño único, dirección horizontal, probabilidades forzadas 0/100%, rebote, fragmentos y limpieza. Pasa también `verify_projectile_extensions`.
