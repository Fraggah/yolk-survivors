# Economía - primera versión para playtests

La partida empieza con 0 yemas. El arma inicial sigue siendo gratuita.

## Ingresos

- Slow, Mid y Fast: 2 yemas por enemigo.
- Shooter: 3; Charger: 4; Fueguito: 0.
- Cosecha paga directamente al saldo al cerrar la oleada.
- Las yemas del suelo van al frasco, sin pagar el saldo de tienda. En la siguiente oleada, cada recogida recibe como máximo un bonus igual a su valor base. Al cerrar esa oleada, el bonus restante vence y se reemplaza por los nuevos drops pendientes.

## Precios base por tier

| Arma | I | II | III | IV |
| --- | ---: | ---: | ---: | ---: |
| Mitten | 8 | 16 | 32 | 56 |
| Butcher Knife | 9 | 18 | 36 | 63 |
| Spatula, Blender, Hidrante, Knifer | 10 | 20 | 40 | 70 |
| Mace, Corpse Launcher | 12 | 24 | 48 | 84 |
| Smasher, The Bloody | 14 | 28 | 56 | 98 |

Los recursos de cada tier guardan el precio base; los multiplicadores son 1 / 2 / 4 / 7. Pasivos: Power Ball 12, Cape 20, Mighty Sword 30, Rage 50.

## Inflación y venta

`precio = max(1, floor(base + oleada + base * 0.10 * oleada))`

Se usa la oleada completada, también para la primera tienda. La venta paga `floor(precio_actual * 0.25)`. ItemBase.get_shop_price y get_sell_price delegan en resources/economy_rules.gd; UI y transacciones comparten el cálculo. Nunca se modifica item_cost para aplicar inflación.

Ejemplo de base 10: cuesta 12 tras la oleada 1, 20 tras la 5 y 28 tras la 9. El frasco no se puede gastar directamente en la tienda.

## Primeras ofertas

Las tiendas 1 y 2 contienen al menos dos armas. La tienda 1 incluye una común de precio final 12 o menor. Se mantienen cuatro ofertas únicas y la progresión de rarezas existente. No se otorgan yemas para completar una compra si el jugador no recogió suficientes.

## Dónde ajustar y qué medir

- Inflación, porcentaje de venta y umbral accesible: resources/economy_rules.gd.
- Precios base: ItemWeapon / ItemPassive .tres.
- Recompensas: resources/units/enemies/stats_enemy_*.tres.
- Garantías de oferta: ShopPanel.select_shop_offers.
- Medir saldo y frasco por oleada, compras posibles, tiempo hasta completar seis slots, frecuencia de combinaciones y dinero sin gastar. Comparar distintas armas y personajes; los precios son una base para feedback, no un balance definitivo.

Verificación: `Godot --headless --path RUTA_PROYECTO --script res://tests/verify_shop_economy.gd --quit-after 2000`.

## Ofertas y refresco de tienda

Cada oferta usa una identidad independiente del tier: la escena del arma, el stat de la mejora o el nombre del pasivo. No se repiten familias dentro de las cuatro opciones. Las armas equipadas siguen pudiendo aparecer, para permitir combinaciones.

Al comprar, se repone solamente esa tarjeta sin cobrar un refresco. Se excluyen las familias de las otras tres tarjetas y se prefiere una familia diferente de la reci�n comprada.

El bot�n Refresh renueva las cuatro ofertas y muestra su costo en yemas. Pueden volver a salir familias anteriores, siempre sin duplicados en la nueva selecci�n. Se conservan las garant�as de armas accesibles de las primeras tiendas.

Costo: `floor(oleada * 0.75) + max(1, floor(oleada * 0.4)) * (refrescos_usados + 1)`. En la primera tienda cuesta 1, 2, 3�; en la quinta, 5, 7, 9� Cada tienda nueva reinicia el contador. Sin saldo suficiente no se cobra ni cambia ninguna oferta. Para retocarlo: `resources/economy_rules.gd`, funci�n `reroll_price`.
