# Moneda de chocolate: revelación

La compra conserva su coste y su tirada única de 50%: duplica las yemas restantes o las deja en cero. El resultado real alimenta la animación; no se vuelve a sortear para mostrarlo. La apuesta del personaje Gambler utiliza la misma presentación.

Panel oscuro modal, aparición de la cara ganadora, giro por sprites durante 1 segundo, contracción de 0,14 s y revelación de 0,18 s. Al ganar salen confetis desde los bordes y destellos desde la moneda. Al perder solo se muestra la cara negativa. Continuar se habilita a los 2,8 s, con mouse o mando; la tienda y pausa no reciben acciones durante la revelación. Si un 2×1 produce dos resultados, se presentan en secuencia.

Arte: `assets/sprites/UI/chocolate_coin/coin-turn.png`. Cuatro dibujos únicos, usados mediante AtlasTexture: ganadora, intermedia, perfil y perdedora; la quinta pose invierte horizontalmente la intermedia. Se conserva el PNG original con transparencia y no se altera el icono de inventario.

Script: `scenes/ui/shop/chocolate_coin_reveal.gd`. Las regiones del atlas, secuencia TURN, tiempos, tamaño y partículas se ajustan allí.

Verificación: `tests/verify_chocolate_coin_reveal.gd`; `-- --capture` guarda capturas de ambos resultados en tmp. Comprueba compra real, saldo, giro, contracción, revelación, exclusión de partículas al perder y cierre modal.
