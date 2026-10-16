# Bomb Corn

Dispara un grano por ataque. Cada grano causa daño de contacto reducido y realiza una sola tirada de probabilidad al impactar. Si falla desaparece después de hacer daño; si acierta desaparece y explota inmediatamente con daño en óvalo. La explosión lanza un pochoclo en una dirección aleatoria uniforme de 360°. Sin impacto no hay explosión: el grano se elimina al agotar alcance o salir de pantalla.

Valores iniciales: `corn_contact_damage_multiplier = 0.25` y `corn_explosion_chance = 0.3` (25% de daño base y 30% de probabilidad). Bomb Corn ya no usa `fuse`: no tiene espera entre impacto y explosión. La inserción de las colisiones secundarias se difiere sólo hasta terminar el callback físico. Los modificadores de perforación/rebote se transfieren al pochoclo, no hacen que el grano active múltiples explosiones.

Configuración por tier en `resources/items/weapons/range/bomb_corn/`:

- `stats_bomb_corn_N.tres`: daño base, cadencia (`cooldown`: 0,24 / 0,22 / 0,20 / 0,18 s), alcance y velocidad del maíz.
- `effects_bomb_corn_N.tres`: radio oval de explosión, multiplicador de daño y duración/color visual.
- Mismo recurso: `popcorn_scene`, `popcorn_speed` (700), `popcorn_range` (240 antes de escala global), `popcorn_damage_multiplier` (1,0 del daño base del arma). La explosión y el pochoclo son dos fuentes independientes de daño.

Arte existente reutilizado: grano de maíz y pochoclo más grande. La textura de pochoclo deja de usarse como dibujo de explosión: ahora representa un proyectil real.

Validación: `tests/verify_bomb_corn.gd` verifica cuatro tiers, explosión inmediata, daño reducido por contacto y probabilidades forzadas de 0%/100%, daño oval, un único proyectil secundario y limpieza. También pasan las regresiones de proyectiles y Corpse Launcher.
