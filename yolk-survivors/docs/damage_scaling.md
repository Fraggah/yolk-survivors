# Daño plano y porcentajes por categoría

## Estadísticas del jugador

- `effects`: daño plano de Efectos. Se muestra sin `%` en el panel y en las mejoras.
- `chili_power`: porcentaje de daño para armas con tag Chili, base 0%.
- `explosive_damage`: porcentaje de daño para armas con tag Explosive y para explosiones derivadas, base 0%.

Las dos estadísticas nuevas están en secundarias y en los desplegables de los siete espacios de ItemPassive, y admiten ganancias, penalizaciones, conversiones de personaje y Yema de oro. No se agregaron como mejoras por nivel.

## Fórmula

`daño = (base + stat principal × coeficiente + Efectos × coeficiente de Efectos + escalados extra) × (1 + (daño general % + Chili Power si corresponde + daño explosivo si corresponde) / 100)`

Se conservan el mínimo de daño del arma y sus modificadores finales, además de los bonos locales de Rebozado. Las categorías porcentuales se suman antes del multiplicador; no se multiplican entre sí. Un arma Chili y Explosive recibe ambos porcentajes.

Ejemplo: base 10, Efectos 10, coeficiente 50%, daño general 30%, Chili Power 20% y daño explosivo 15%: `(10 + 10 × 0,5) × 1,65 = 24,75` para un arma de ambas tags.

## Edición de armas y estados

- `stats.damage_scaling`: coeficiente de la estadística principal, como antes. `Damage Scaling Stat` ahora también admite `EFFECTS`.
- `scales_with_effects` habilita un escalado adicional plano desde Efectos; `effects_damage_scaling` define su coeficiente. 1,0 = 100%; 0,5 = 50%. No se duplica si Efectos ya es la estadística principal.
- Los chilis existentes que tenían `scales_with_effects` conservan ese indicador y usan el coeficiente inicial 100%, editable por arma. Ají amarillo conserva además su escalado de daño a distancia.
- Electricidad: `(StatusEffect.damage + Efectos × StatusEffect.damage_scaling)`, seguido de los porcentajes correspondientes. Coeficiente inicial 100%, editable en el estado.
- Burning genérico del jugador, como Alcohol: base `max(0,1; Efectos × 0,25)`, seguido de los porcentajes correspondientes. El fuego propio de Hongo usa su porcentaje de vida máxima sin escalar con Efectos.
- El fuego nativo de Cayena usa el daño calculado de cada arma: conserva daño base, coeficientes, tier, porcentajes y atribución individual incluso en una estela compartida.

## Explosiones y daños derivados

Las armas Explosive reciben el bonus también en el impacto directo. Las explosiones conservan el mismo bonus una sola vez. Si un arma sin esa tag genera una explosión secundaria (por ejemplo, mediante un ítem), se recalcula el porcentaje aplicable a esa explosión, sin multiplicar otra vez el daño general ni acumular el bonus en cadenas de explosiones.

La explosión de Hongo desconocido aplica daño general y daño explosivo sobre su base de Efectos + 10% de vida máxima.

Leche entera conserva sus 10 de vida configurados por el usuario y tiene preparado `add_stats_id_2 = "chili_power"` para introducir la penalización negativa pendiente. No se inventó ese valor ni se habilitó el ítem pendiente en tienda. Nuez moscada y Semillas de chili tienen preparados sus selectores cuando no tenían configuración numérica previa.

## Referencia Brotato

[Dynamite](https://brotato.wiki.spellsandguns.com/Dynamite): aumenta daño de armas Explosive, incluido su impacto no explosivo, y las explosiones.

[Damage](https://brotato.wiki.spellsandguns.com/Damage): el porcentaje explosivo se suma al general; +30% de daño y +15% explosivo dan +45%.

Verificaciones: `verify_damage_categories.gd`, `verify_cayenne_stacking.gd`, `verify_breading.gd`, `verify_alcohol_burning.gd`, `verify_crowd_control.gd`, `verify_catalogue_passives.gd`, `verify_passive_stat_slots.gd` y `verify_unknown_mushroom.gd`. Panel secundario revisado visualmente con las 15 filas sin desbordes.

## Soplete: impacto y quemado separados

El soplete tiene solamente la tag Pyro. Su impacto usa `Damage Scaling Stat = EFFECTS` y `stats.damage_scaling` (25% en los cuatro tiers actuales), sin daño a distancia.

Su subrecurso `on_hit_effects` activa `configured_fire_damage`: cada tick usa `max(0,1; damage + Efectos × damage_scaling)`, seguido de los porcentajes de daño correspondientes. Conserva las bases actuales por tier (2/3/4/5), coeficiente 100%, duración configurada y cadencia base de 0,5 s modificable con ítems. Los ticks no hacen crítico. Este modo no cambia el fuego genérico de Alcohol ni las estelas nativas de los chilis.

Las tarjetas de armas muestran por separado Electricidad y el quemado configurado por tick, incluyendo su daño calculado y la fórmula base + porcentaje de Efectos. En quemado muestran también intervalo y duración. Los valores de ejemplo de la conversación no reemplazan el balance de los recursos.
