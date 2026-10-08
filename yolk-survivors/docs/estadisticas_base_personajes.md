# Yolk Survivors â€” EstadÃ­sticas base

Primera pasada del rework de daÃ±o y cadencia.

| Personaje | Vida | DaÃ±o % | Melee | A distancia | Ataque % | Velocidad | Suerte | Bloqueo % | Regen / 3 s | Robo % | Cosecha |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Well Rounded | 20 | 10 | 2 | 2 | 5 | 300 | 5 | 5 | 0 | 0 | 0 |
| Tiny Egg | 14 | -10 | 0 | 0 | 30 | 375 | 10 | 12 | 0 | 0 | 0 |
| Hardboiled | 36 | 0 | 5 | 0 | -10 | 250 | 0 | 22 | 0 | 0 | 0 |
| Mutant | 22 | 5 | 3 | 3 | 0 | 285 | 0 | 3 | 1 | 0 | 0 |
| Vampire | 18 | 0 | 2 | 2 | 10 | 310 | 0 | 0 | 0 | 12 | 0 |
| Gambler | 16 | 0 | 0 | 2 | 5 | 310 | 35 | 5 | 0 | 0 | 0 |
| Scrapper | 24 | 0 | 4 | 1 | 10 | 290 | 5 | 10 | 1 | 0 | 5 |
| Glass Egg | 10 | 40 | 0 | 0 | 0 | 325 | 0 | 0 | 0 | 0 | 0 |
| Hoarder | 22 | -10 | 0 | 0 | 0 | 275 | 15 | 5 | 0 | 0 | 15 |
| Berserker | 16 | 15 | 8 | -2 | 15 | 335 | 0 | 0 | 0 | 0 | 0 |

DaÃ±o por impacto: mÃ¡ximo entre 1 y `(base del arma + bono del tipo Ã— escalado) Ã— (1 + daÃ±o % / 100)`. El crÃ­tico se aplica despuÃ©s. Se conservan decimales.

Cooldown positivo: `base / (1 + ataque % / 100)`. Con penalizaciÃ³n: `base Ã— (1 + abs(ataque %) / 100)`. MÃ­nimo: 0,05 s. Las animaciones se acortan cuando es necesario para completar cada ataque antes del siguiente.

Velocidad de movimiento, bloqueo, regeneraciÃ³n, robo de vida y cosecha conservan su funcionamiento previo. Los valores requieren ajuste despuÃ©s de partidas completas.

Los jugadores no aumentan su vida máxima por oleada. El crecimiento por oleada pertenece a los enemigos; las mejoras de vida máxima del jugador siguen funcionando.
