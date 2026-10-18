# Arpón de baguette

Daño base reducido a la mitad en los cuatro tiers: 7,5 / 10,125 / 13,5 / 18. Daña una vez a cada enemigo intersectado y lo engancha, arrastrándolo hasta el alcance del disparo o el primer borde real de la arena (rectangular, redondeada u oval). El barrido de colisiones evita saltarse enemigos por velocidad. No rebota ni se consume por perforaciones: captura a los enemigos de su recorrido completo.

Al terminar queda clavado con una pequeña inclinación visual y mantiene inmovilizados a los enemigos durante 0,5 segundos. Los libera al terminar o al eliminarse el proyectil, también durante limpieza de oleada. La cámara no elimina el arpón. No añade daño de arrastre ni de inmovilización. El sistema existente de pins permite coexistir con otras inmovilizaciones.

Configurar en `effects_baguette_harpoon_N.tres`: `harpoon_pin_duration`, `harpoon_embed_duration`, `harpoon_embed_angle` y `harpoon_capture_radius`. Efectos del jugador modifica la duración de inmovilización. Alcance, daño y velocidad siguen en `stats_baguette_harpoon_N.tres`.

Validación: `verify_baguette_harpoon` cubre barrido de dos enemigos, daño único, arrastre, pausa, fin por alcance/borde, inmovilización y liberación por limpieza. También pasa `verify_projectile_extensions`.

### Inmovilización en la pendiente del wok

La fuerza del wok no desplaza enemigos cuyo multiplicador de movimiento sea cero (pin o inmovilización). Al capturar y al liberar el último pin se limpian la separación del enemigo y su caché espacial. El gestor de multitudes no calcula separación para inmovilizados, limita la separación a un vector unitario y la locomoción combina dirección/separación sin superar la velocidad efectiva del enemigo. Así los cuerpos superpuestos por el arpón no reciben aceleraciones extremas al soltarse. El empuje normal del wok vuelve al terminar la inmovilización; knockback y lanzamientos conservan sus rutas propias. Regresión `verify_wok_harpoon`: ancla estable en pendiente, limpieza al liberar, velocidad normal con enemigos casi coincidentes y retorno de la fuerza del wok.
