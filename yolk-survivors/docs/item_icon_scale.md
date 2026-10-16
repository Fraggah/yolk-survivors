# Tamaño individual de iconos

Abrir el recurso de ítem, por ejemplo `resources/items/weapons/range/pressure_cooker/item_pressure_cooker_1.tres`, y editar **Icon Scale** en el inspector. Está junto a Item Icon, definido en ItemBase. Valor 1,0 conserva el tamaño; 1,2 agranda 20%; 0,8 reduce 20%. Rango 0,25–2. Es una propiedad de cada recurso: si se quiere el mismo tamaño en los cuatro tiers, editar los cuatro item_*.tres. No se encuentra en stats_*.tres ni cambia Sprite2D, proyectiles o colisiones.

Aplicado al roster de selección, detalle del arma seleccionada, ofertas de tienda, inventario de tienda, tooltip, pausa y tarjetas de mejoras. Escala sólo la imagen respecto del centro; conserva el tamaño del slot y los anclajes del tier. El valor por defecto mantiene todos los iconos actuales. No altera la secuencia animada de desbloqueo, que tiene sus propios tweens de escala.

El margen transparente del PNG sigue influyendo en el tamaño visible. Valores grandes pueden sobrepasar el espacio del slot: ajustar con moderación. El PNG continúa definiendo la inclinación.

Regresiones existentes de pausa/tiers y panel de estadísticas aprobadas tras integrar la propiedad.
