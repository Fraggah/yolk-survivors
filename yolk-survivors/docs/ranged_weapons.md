# Armas a distancia

Integración inicial de las 15 armas y sus proyectiles aprobados. Las diez familias nuevas se añaden mediante `RangedCatalogue` a selección y tienda, con cuatro tiers, combinación y venta. No tienen requisito de desbloqueo hasta que se definan sus logros.

El catálogo maestro v01 define comportamientos, pero deja vacíos daño, cooldown, alcance y empuje. Los números de las armas nuevas son valores iniciales para probar, no un balance definitivo.

## Balance en el editor

En `resources/items/weapons/range/<arma>/`:

- `item_<arma>_<tier>.tres`: nombre, precio base, icono, descripción y siguiente tier.
- `stats_<arma>_<tier>.tres`: daño, escalado, cooldown, alcance, velocidad de proyectil, crítico, robo de vida, empuje, perforación y rebotes.
- `effects_<arma>_<tier>.tres`, enlazado desde **Ranged settings** de las estadísticas: cantidad de proyectiles, dispersión, ráfaga y separación entre disparos; explosión, detonación por contacto, mecha, radio, proporción vertical del área, multiplicador de daño, textura/color/duración visual; carozo, duración, radio, multiplicador de daño e intervalo de impactos.

Las áreas de daño y sus efectos se dibujan como óvalos. El daño de explosiones y carozos conserva crítico, robo de vida y registro de daño del arma que los creó. Se congelan durante la pausa y se eliminan al terminar la oleada. Reiniciar el ataque cancela los disparos de ráfaga pendientes.

## Comportamientos iniciales

| Arma | Ataque |
|---|---|
| Bomb-corn | Maíz que se detiene al chocar y explota tras una mecha corta; aparece el pochoclo más grande. |
| Escopeta de escarbadientes | Cinco escarbadientes en abanico con una perforación. |
| Olla a presión | Proyectil más lento, mecha más larga y explosión más amplia. |
| Ametralladora de albóndigas | Ráfaga de tres disparos. |
| Bazooka de pimientero | Explota al impactar o al cumplirse la mecha. |
| Doble caño de anchoas | Dos anchoas simultáneas con pequeña dispersión. |
| Arpón de baguette | Proyectil que perfora cuatro enemigos adicionales. |
| Lanzaplatos | Dos rebotes entre enemigos diferentes. |
| Lanzaceitunas | Dispara una aceituna y deja un carozo cerca del jugador que daña por contacto. |
| Lanzatirabuzones | Poco daño y mucho empuje. |

Las cinco armas existentes conservan sus estadísticas y desbloqueos; reciben el arte aprobado. Knifer y Corpse Launcher usan los SVG de proyectiles retocados, Bloody la cápsula de kétchup y Smasher el palo de amasar. **Hydrant conserva su disparo actual: su chorro continuo con shader se implementará al final, según lo acordado.**

Las familias y materiales del Excel siguen siendo provisionales; esta integración no añade bonificaciones de familias.

### Profundidad de proyectiles

Los proyectiles viajeros se crean dentro de la escena de arena, en la misma capa Z=0 que las unidades y columnas, y se ordenan por la Y global de su raíz. Esto incluye disparos secundarios (pochoclo, carozo y gotas), disparos enemigos y huevo/olla durante el vuelo y tras aterrizar. La altura animada del huevo/olla sigue en el sprite, sin cambiar su referencia de profundidad. ProjectilePool es Node2D con Y-sort anidado para que las gotas recicladas participen en el mismo orden sin perder su ciclo de reutilización. La regresión GPU de profundidad recorre todas las escenas de proyectiles y comprueba cruces por delante/detrás del jugador y de una columna, además de una gota del pool.
