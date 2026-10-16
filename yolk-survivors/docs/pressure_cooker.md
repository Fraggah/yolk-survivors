# Olla a presión

Vuela a una posición objetivo fija con un arco visual, siempre horizontal. No causa daño ni empuja durante el vuelo o al aterrizar. La caída aplica ralentización una vez en un óvalo y una pequeña ráfaga de vapor, con texto Slowed. Luego se infla progresivamente y vibra durante la anticipación; al terminar explota con daño oval. No genera yemas adicionales.

Los cuatro `effects_pressure_cooker_N.tres` permiten ajustar `fuse` (tiempo en el piso), `explosion_radius`, `area_y_ratio`, `landing_slow_radius`, `landing_slow_factor` (0,6 = 40% menos velocidad), `landing_slow_duration`, `landing_visual_duration`, `pot_inflate_amount`, `pot_sprite_scale`, `lob_height` y `pre_explosion_shake_*`. Los stats del jugador afectan área y ralentización. Daño, cooldown y velocidad de vuelo siguen en `stats_pressure_cooker_N.tres`.

Escala del sprite lanzado 0,5: su ancho visible de 81 píxeles pasa a 40,5 antes de escala global, cercano al ancho de la olla del arma sostenida. La orientación se mantiene horizontal también durante la vibración.

Regresiones aprobadas: `verify_pressure_pot`, `verify_corpse_egg`, `verify_bomb_corn`. La prueba específica verifica cuatro tiers, vuelo sin contactos, aterrizaje sin daño, ralentización oval, inflado, pausa y explosión.
