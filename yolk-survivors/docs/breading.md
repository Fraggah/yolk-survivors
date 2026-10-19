# Rebozado

Consumible almacenable con contador en la tienda. Pulsar, confirmar y elegir un arma propia. La carga se gasta después de validar el objetivo; cancelar, elegir un pasivo o señalar un arma sin tags disponibles no consume cargas. La tag se elige uniformemente entre las que no tiene y son compatibles con las restricciones del personaje.

Valores editables en `resources/items/passives/catalogue/item_081.tres`:

| Tag añadida | Comportamiento |
| --- | --- |
| Melee | Suma un escalado extra del 25% de daño melee. Conserva el escalado original. |
| Ranged | Suma un escalado extra del 25% de daño ranged. Conserva el escalado original. |
| Chili | Esa arma gana +10% de daño por cada arma equipada con Chili, incluyéndose. |
| Pet | Esa arma gana +10% de daño por cada arma equipada con Pet, incluyéndose. |
| Pyro | Cada impacto tiene 10% de aplicar Burning, con las reglas globales del fuego. |
| Electric | Cada impacto tiene 10% de aplicar Shoked, con electricidad y propagación existentes, sin Slow. |
| Explosive | Impactar crea una explosión de radio 40, con 25% del daño efectivo del impacto. Se beneficia del área de efecto. |
| Control | El impacto ralentiza 20% durante 1s. Control de masas y potencia de Slow ajustan el efecto. |

Chili y Pet suman sus bonificaciones locales cuando coinciden. Los conteos se actualizan al equipar, quitar o cambiar tags. No se implementa todavía una bonificación general por tener armas que compartan tag. Las tags adicionales no convierten una animación melee en un disparo ni cambian la escena del arma.

Los impactos de efectos compartidos consultan cada contribución y atribuyen el daño adicional a su arma. Las explosiones y estados producidos por Rebozado no vuelven a disparar Rebozado, evitando cadenas recursivas. Cayena también aplica sus tags sobre sus ticks nativos y conserva el reparto de daño por arma; estados secundarios de otras armas no generan nuevos impactos de Rebozado.

Se preservan las tags añadidas al combinar o subir de tier. Las mejoras doradas se conservan al agregar tags; mejorar con Yema de oro también potencia el escalado adicional, bonificaciones locales, radio, Slow y probabilidades de los estados añadidos. No se alteran los recursos originales del catálogo.

Pruebas: `tests/verify_breading.gd`, `tests/verify_golden_yolk.gd`, catálogo y regresiones de fuego/auras compartidas.
