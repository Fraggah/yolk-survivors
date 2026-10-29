# Edición de la tienda en Godot

La disposición base de single player se guarda en las escenas. `_ready` conecta datos y eventos; no construye ni reordena la interfaz base.

## Nodos de shop_panel.tscn

- `MarginContainer/Control/ItemsContainer`: cuatro ofertas; su plantilla es `shop_card.tscn`.
- `MarginContainer/Control/StatsContainer`: estadísticas, pestañas y ayuda, ya existentes en `stats_container.tscn`.
- `MarginContainer/Control/EquipmentArea`: bloque de armas y consumibles.
- `EquipmentArea/WeaponPanel/InventoryScroll/Center/WeaponContainer`: grilla fija de tres columnas, seis espacios iniciales y scroll para slots adicionales.
- `EquipmentArea/GoldenControl` y `BreadingControl`: botones cuadrados, iconos y cantidades externas. Tamaños, offsets e iconos se editan en escena. Su plantilla es `consumable_button.tscn`.
- `MarginContainer/Control/RefreshHeader/Buttons`: refresh y botón del Gambler, centrados mediante contenedores. Gambler solo aparece cuando corresponde.
- `MarginContainer/Control/VBoxContainer`: siguiente oleada y aviso de evento especial.
- `WeaponActions/Content`: combinar, vender y volver. El panel permanece oculto hasta seleccionar un arma; ya no hay botones sobrantes bajo Next Wave.
- `WeaponTooltip`: tarjeta contextual de inventario, con filas guardadas en `weapon_tooltip.tscn`.

Las escenas compartidas se pueden abrir directamente; en una instancia se puede activar «Editable Children» para cambiar sus hijos. Los nombres/rutas usados por el código deben conservarse.

## Cambios que sí dependen del juego

Los nombres, descripciones, valores, rarezas, cantidades, ofertas y equipo se actualizan con los datos de la partida. Los slots vacíos se completan según el límite real. La visibilidad depende de la pantalla, del personaje y de sus consumibles. Los títulos pueden reducir su fuente para caber, partiendo del tamaño guardado en la escena. Los popups se ubican junto al slot seleccionado y se mantienen dentro de pantalla.

Las secuencias animadas de uso de moneda/Yema de oro son paneles separados y no forman parte de la disposición base de la tienda; su futura migración puede trabajarse por separado.

## Verificación

`verify_shop_scene_layout.gd` compara las posiciones/tamaños de la escena sin scripts con la interfaz iniciada. También comprueba que cambios hechos antes de `_ready` en los offsets de consumibles y alturas de filas no se sobrescriban. `verify_tiny_egg_consumables.gd` prueba los consumibles, los slots, el scroll, venta y combinación.
