# Tareas pendientes

Lista acordada el 18/10/2026. El orden no implica prioridad de implementación.

- [ ] Rework de cómo la tienda ofrece ítems. Implementados: curva base de rarezas, garantía inicial de familia, sesgo por familias/tags y refrescos sin repetir ofertas. Pendiente: acordar y calibrar Suerte. Ver shop_progression.md.
- [x] Rework del spawner: pesos por grupo, zonas de aparición, eventos exactos por segundo/cantidad, arena base/fija/especial aleatoria por oleada y duración base de 30 s. Ajuste de balance pendiente de pruebas de juego. Ver spawner_configuration.md.
- [ ] Completar el primer boss: mecánicas e integración a la oleada 20 implementadas; falta pulido final, animación de derrota y balance.
- [ ] Crear los personajes.
- [ ] Completar el menú de opciones.
- [ ] Agregar idiomas.
- [ ] Implementar multijugador local para hasta 4 jugadores. Primera base de prueba para 2: selección por dispositivo, combate, economía/XP personales, caídas, mejoras y tienda simultánea. Pendientes: consumibles/presentaciones especiales, progresión cooperativa, reconexión con reasignación, ampliación a 3–4, pulido y balance. Ver local_coop_plan.md.

## Animaciones y mejora de UI — 22/10/2026

Pendientes solicitados. Los detalles visuales se definirán antes de implementarlos.

- [ ] Ayahuasca: reemplazar el diálogo de resultado por una presentación propia, con animación y feedback claro del efecto obtenido y del cambio de oleada.
- [ ] Rebozado: mejorar la selección/aplicación sobre el arma y animar la revelación de la nueva tag y sus efectos. Actualmente comunica el resultado mediante un diálogo.
- [ ] Derrota del boss: crear una animación de muerte y una transición de victoria. Actualmente el boss se oculta y se completa la prueba sin una secuencia visual de derrota.
- [ ] Pulir los menús: principal, pausa, opciones y selección de personajes/armas; revisar composición, márgenes, jerarquía visual, estados de botones y navegación con mouse/mando.

### Candidatos para una siguiente pasada de pulido

Sugerencias de revisión, todavía sin diseño o alcance acordados:

- Transiciones entre combate, recompensas, mejoras de nivel y tienda.
- Presentación y revelación de recompensas de Incógnito.
- Feedback visual de compra, venta, combinación, bloqueo y refresco de ofertas.
- Consistencia de foco/hover, tooltips, confirmaciones y tamaños de texto en los distintos paneles.

La moneda de chocolate y la Yema de oro ya tienen secuencias propias; quedarían para retoques posteriores. La derrota del jugador ya tiene una presentación y no se considera una animación totalmente ausente.
