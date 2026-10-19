# Edición de estadísticas de ItemPassive

Cada recurso dispone de siete grupos `Stat 1` a `Stat 7`: los dos espacios originales y cinco adicionales. Cada grupo tiene un `Add Value` y un `Add Stats ID` con desplegable.

- Valor positivo: suma a la estadística.
- Valor negativo: resta a la estadística. Ejemplo: `-3` y `health` resta 3 de vida máxima.
- Valor cero o ID `none`: no aplica cambios.
- Se pueden repetir IDs; cada entrada se procesa en orden por el sistema habitual de ganancias y penalizaciones del personaje.

Las propiedades del primer espacio conservan `add_value` y `add_stats_id`; los demás usan sufijos `_2` hasta `_7`. Se eliminaron `remove_value` y `remove_stats_id` y se migraron los recursos existentes, incluidas las cuatro piezas del catálogo anterior. Sus penalizaciones mantienen la misma magnitud con signo negativo en el segundo espacio.

Yema de oro aumenta los valores positivos y reduce la magnitud de los negativos en los siete espacios. Las compras registran todos sus cambios para separar copias, mejorarlas o retirarlas correctamente.

La descripción automática de ItemPassive muestra el signo y color de cada entrada. Los recursos del catálogo conservan su descripción editorial independiente en `Description`; si se retocan valores, actualizar ese texto también.

Pruebas: `verify_passive_stat_slots.gd`, `verify_catalogue_passives.gd`, `verify_golden_yolk.gd`, `verify_alcohol_burning.gd` y `verify_character_passives.gd`.
