# Lanzaceitunas

Cada disparo lanza la aceituna normalmente hacia adelante y un carozo desde el arma hacia atrás, con desviación uniforme de hasta ±45 grados respecto de la dirección opuesta. El carozo recorre la mitad del alcance del arma, incluyendo la misma escala que la detección. Reemplaza al carozo estático que antes quedaba en el piso. Se elimina al impactar, salir de pantalla o agotar su distancia; no rebota para alargarla.

En cada `effects_olive_launcher_N.tres`: `pit_projectile_scene`, `pit_projectile_speed` (700), `pit_range_multiplier` (0,5), `pit_deviation_degrees` (45, máximo a cada lado), y `pit_damage_multiplier` (conserva 0,5). Hereda críticos, efectos, robo de vida y registro de daño del arma. La aceituna conserva su comportamiento.

Regresiones aprobadas: `verify_olive_launcher` verifica 32 disparos en cuatro direcciones y confirma un proyectil de cada tipo, cono trasero, alcance y limpieza. También pasan ráfagas de albóndigas y extensiones de proyectiles.

## Rework pendiente

El usuario no está conforme con el comportamiento actual del lanzaceitunas. Antes de seguir puliéndolo hay que definir y realizar un rework; todavía no hay un nuevo diseño acordado. El disparo de aceituna frontal y carozo trasero descrito arriba queda como implementación provisional en este checkpoint.
