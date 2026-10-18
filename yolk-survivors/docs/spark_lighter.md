# Encendedor chispero / Spark Lighter

Arma melee implementada con una estocada corta, un contacto por ataque y ambos estados garantizados al impactar: fuego y electricidad. Reutiliza el comportamiento de estocada existente; no dispara proyectiles. Tiene cuatro tiers, seleccionable desde el inicio y disponible en tienda, venta y combinación con recursos independientes.

Balance inicial ajustable: alcance 90 en todos los tiers; daño directo 4/6/8/11 con 50% de escalado melee; cooldown 1.05/1.0/0.95/0.9 segundos. Fuego: daño por tick 2/3/4/5 cada 0.5 s durante 2.5 s. Electricidad: daño inicial 2/3/4/5, ralentización a 75% durante 1 s, propagación a dos enemigos cercanos en radio base 45. Conserva escalado con Efectos y reglas de atribución de daño de estados.

Recursos editables: `resources/items/weapons/melee/spark_lighter/item_spark_lighter_1.tres` y tiers 2–4 contienen los estados; `stats_spark_lighter_1.tres` y tiers contienen daño, alcance, cooldown y animación. Escena `scenes/weapons/melee/weapon_spark_lighter.tscn`, hitbox localizada en la punta de la boquilla. Catálogo nuevo de adiciones melee `resources/items/weapons/melee_catalogue.gd`, consumido por selección y tienda.

Arte aprobado conservado en Source/spark_lighter.png, sprite horizontal InGame/spark_lighter.png e icono Icons/spark_lighter.png. Icono centrado con padding y rotación de -35 grados, igual a las armas ranged. Paleta: azul eléctrico #62849F y rojo de fuego #D94A35, documentados en visual_conventions.md. Exportación reproducible del arte aprobado: `documentacion-local/conceptos/chispero-v1/build-assets.ps1`.

El panel de armas incorpora temporalmente WeaponRosterScroll, vertical, ocho columnas y follow_focus para mando/teclado. Con más de 40 armas muestra una sexta fila accesible sin alterar los dos paneles de detalle. Se puede quitar desde selection_layout.gd cuando se rediseñe el roster. El selector de personajes conserva su organización sin scroll.

Validación: verify_spark_lighter cubre aplicación de ambos estados, cuatro tiers de tienda/upgrades y scroll; verify_weapon_selection_scroll cubre accesibilidad de todas las tarjetas con mando. Capturas reales en documentacion-local/validacion/chispero-panel.png y chispero-scroll.png.
