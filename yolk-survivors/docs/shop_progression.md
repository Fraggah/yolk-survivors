# Ofertas de tienda: rarezas y sinergias

## Rarezas sin Suerte

Se usa la progresión lineal aprobada en la vista previa: Raro o superior llega a 60%, Épico o superior a 20% y Legendario a 5%. Son probabilidades **acumuladas**, no tres porcentajes exclusivos ni tres probabilidades condicionales independientes.

- Raro o superior: se desbloquea después de la oleada 2. En esa tienda empieza en 60/19 puntos porcentuales y suma ese incremento por oleada hasta la 20.
- Épico o superior: se desbloquea después de la 9. Empieza en 20/12 puntos porcentuales y suma ese incremento hasta la 20.
- Legendario: se desbloquea después de la 15. Empieza en 5/6 puntos porcentuales y suma ese incremento hasta la 20.
- Común es el residual. La tienda posterior a la 20 queda en **40% Común, 40% Raro, 15% Épico y 5% Legendario**.
- Las tiendas posteriores conservan por ahora los valores de la 20, según la aclaración del usuario. No se diseñó una nueva curva para 21-100.
- **Suerte no se aplica todavía a estas tiradas.** Su fórmula e intensidad deben consultarse antes de habilitarlas. Las mejoras por nivel tienen su propia curva base sin Suerte, con desbloqueos en niveles 3/10/15; ver upgrade_progression.md.

La resolución es secuencial, de mayor a menor, convirtiendo los acumulados en probabilidades condicionales. Con acumulados R, E y L: primero `L`; si falla, `(E-L)/(1-L)`; si falla, `(R-E)/(1-E)`; si falla, Común. En el cap: 5%, luego 15/95, luego 40/80. Esto produce la distribución final aprobada sin superar los caps.

Código de curva y caps: `resources/shop_rarity.gd`. Tabla de referencia de 20 filas: `resources/shop_rarity_base.txt`, guardada como texto para evitar que Godot la importe como traducciones. Copia CSV para consultar: `output/shop-rarity-base.csv` en la raíz del workspace.

## Armas por familia y tags

- La familia se identifica con `ItemWeapon.get_offer_key()`, que utiliza la escena compartida entre tiers. El tier siempre pasa por el sorteo de rareza; nunca se copia automáticamente el tier equipado.
- Con **1 o 2 armas equipadas**, contando copias, la tienda ofrece una familia equipada de manera asegurada una vez por visita, si hay un espacio y candidatos elegibles. Mostrarla consume la garantía, aunque no se compre. Una tarjeta bloqueada que ya muestra una familia equipada también la satisface.
- Con **3 o más**, no se fuerza esa oferta. En las tiradas de armas no garantizadas, una búsqueda del 40% intenta elegir entre las familias equipadas disponibles en el tier sorteado. El resto usa la ponderación de tags.
- El 40% es una rama de búsqueda, no un cap del porcentaje final de coincidencias. El sorteo ponderado restante también puede elegir una familia equipada.
- Peso base de un arma: 1. Por cada tag **distinta** compartida con el conjunto de armas equipadas: +1. Una coincidencia pesa 2, dos pesan 3. Cuenta Rebozado. Equipar varias copias no multiplica el peso de una misma tag.
- La proporción arma/pasivo dentro del tier conserva la proporción del catálogo de candidatos. El sesgo selecciona la identidad del arma, no aumenta por sí mismo el número de tarjetas de arma.
- Se mantienen las dos armas de las primeras tiendas y la búsqueda de un arma económica en la primera, cuando haya candidatos y espacio. La garantía de familia ocupa uno de esos espacios.

Parámetros: `resources/shop_weapon_bias.gd`: `OWNED_FAMILY_CHANCE = 0.40`, `SHARED_TAG_WEIGHT = 1.0`.

## Refrescos, compras y bloqueos

- Cada refresco reemplaza las tarjetas desbloqueadas y excluye las cuatro familias/pasivos de la tanda anterior. Para un arma, la exclusión abarca todos sus tiers.
- Las tarjetas bloqueadas son la excepción: conservan producto, posición y precio. Con cuatro bloqueadas no se cobra ni se refresca.
- La exclusión afecta solo a la tanda inmediatamente anterior; un producto puede volver en un refresco posterior por probabilidad normal.
- La garantía no se repite al refrescar ni al comprar. Se renueva al volver de otra oleada.
- Comprar sigue reponiendo únicamente la tarjeta comprada, utilizando los mismos sesgos de armas. Conserva las otras tarjetas, límites, desbloqueos, combinaciones y costes.
- Si el catálogo elegible no permite completar todos los espacios nuevos sin repetir lo anterior, se cancela el refresco sin cobrar ni cambiar las tarjetas. No se relajan las exclusiones.
- Si falta un candidato del tier sorteado se conserva el fallback de la arquitectura existente a un tier inferior disponible. Las simulaciones de rareza con catálogo completo aíslan este caso del sorteo base.
- Liquidación y sus reglas de ofertas se conservan.

## Pruebas sin jugar las oleadas

Desde la raíz del workspace, con el ejecutable de Godot disponible:

```powershell
godot --headless --path yolk-survivors --script res://tests/verify_shop_progression.gd
godot --headless --path yolk-survivors --script res://tests/simulate_shop_rarity.gd -- --samples=100000 --seed=12345
godot --headless --path yolk-survivors --script res://tests/simulate_shop_rarity.gd -- --offers --samples=2000 --seed=12345
```

El primer comando comprueba garantías, ausencia de garantía con tres copias, exclusiones, bloqueos/precios, refresco imposible sin cobro, tabla base, límites y ausencia de Suerte. Incluye 60.000 selecciones de armas para comprobar la ponderación 2:3:1 y la rama de búsqueda de familia del 40%.

La segunda simulación genera 2 millones de tiradas secuenciales. La tercera genera 160.000 ofertas mediante el selector real, en tandas de cuatro y con un catálogo controlado que tiene suficientes candidatos de todas las rarezas. Ambas comprueban cada oleada/tier con tolerancia estadística de seis desviaciones estándar más 0,05 puntos porcentuales y prohíben resultados de rarezas aún bloqueadas.

Informes en `output/shop-rarity-simulation.csv` y `output/shop-full-offers-simulation.csv`, con probabilidades esperadas y observadas por oleada. Se puede variar `--samples` y `--seed` sin iniciar partidas.

Regresiones: `verify_offer_locks.gd` y `verify_liquidation.gd`.

## Filtro de tiers útiles con inventario completo

Cuando todos los espacios reales (incluidos los adicionales de ítems) están ocupados por una misma familia y queda como máximo una copia por debajo de IV, la tienda excluye los tiers inferiores al de esa última copia. Si todas las copias son IV, excluye toda esa familia. Con IV y III permite III/IV; con IV y II permite II/III/IV; con IV y I permite todos. Si hay dos o más copias por debajo de IV, se permiten todos los tiers: todavía se pueden combinar armas para liberar espacios. Por ejemplo, una III y cinco II siguen permitiendo ofertas de tier I.

Se aplica al catálogo antes de generar ofertas iniciales, refrescos y reposiciones por compra. Con espacios libres o familias mezcladas se conserva el comportamiento previo. Las otras familias y las ofertas ya bloqueadas no se modifican. Verificado en `verify_shop_progression.gd` junto con las reglas anteriores de tienda.

## Máximo de dos armas ofrecidas

Cada tanda de cuatro tarjetas contiene como máximo dos armas. Las armas bloqueadas consumen ese mismo cupo: con una bloqueada se puede generar como máximo una más; con dos (o más, si provienen de un estado anterior) solo se generan pasivos. Bloquear un pasivo no consume cupo de armas.

El límite se aplica al abrir la tienda, refrescar y reponer una tarjeta comprada. La garantía de familia y las armas de las primeras dos tiendas respetan el cupo; las tarjetas bloqueadas conservan su contenido. El resto de los espacios se completa con pasivos. Si un catálogo reducido no permite generar todas las tarjetas respetando las reglas de refresco, sigue sin cobrarse ni modificarse la tirada.

Verificado en `verify_shop_weapon_limit.gd` (1.500 tandas con 0/1/2 armas retenidas más refrescos y reposiciones reales).
