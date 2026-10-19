# Críticos de fuego y Chilis

- Ningún tick del estado Burning puede hacer crítico, en enemigos ni en jugadores. FireStatus no hereda críticos del impacto que lo originó y marca su hitbox como no apto para críticos. Esto también afecta a las contribuciones compartidas de Cayena.
- Las armas con tag Chili tienen 0% de crítico efectivo por defecto, aunque su recurso o el jugador tengan probabilidad de crítico. La ficha del arma muestra ese valor efectivo.
- Pimienta (ítem 040, disponible en tienda) habilita los críticos de los Chilis. Usa la probabilidad base del arma más la del jugador, con los modificadores habituales. El ítem no añade una probabilidad numérica por sí mismo.
- La condición depende de conservar alguna copia de Pimienta. Al destruir o retirar la última copia se pierde el permiso.
- Se aplica también a armas que reciban la tag Chili mediante Rebozado y a las auras/efectos con registros compartidos. Las armas sin esa tag conservan sus críticos habituales.
- Pimienta nunca habilita críticos en los ticks de Burning. Los impactos directos de un Chili y su estado de fuego se resuelven por separado.

Pruebas: `verify_chili_criticals.gd`, `verify_catalogue_passives.gd`, `verify_cayenne_stacking.gd`.
