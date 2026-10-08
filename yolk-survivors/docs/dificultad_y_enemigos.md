# Yolk Survivors — Dificultad y enemigos

La partida conserva diez oleadas y seis dificultades. Los identificadores guardados 0–5 siguen siendo compatibles.

| Nivel | Vida y daño totales | Composición y hordas |
| --- | --- | --- |
| 0 | ×1 | Composición base |
| 1 | ×1 | Shooter y Charger disponibles desde la oleada 3 |
| 2 | ×1 | Apariciones anticipadas y horda en la 6 |
| 3 | ×1,12 | Apariciones anticipadas y horda en la 6 |
| 4 | ×1,26 | Apariciones anticipadas y hordas en la 4, 6 y 9 |
| 5 | ×1,40 | Apariciones anticipadas y hordas en la 4, 6 y 9 |

Los bonus son totales por nivel. No se suman los de niveles anteriores. Los multiplicadores siguen la referencia de Danger 0–5 de Brotato; las hordas se adaptan a nuestra partida de diez oleadas. No hay élites ni jefes en esta implementación.

Cada aparición calcula desde valores base inmutables:

`Vida = (vida base + vida por oleada × (oleada − 1)) × multiplicador`

`Daño = (daño base + daño por oleada × (oleada − 1)) × multiplicador`

Se conservan decimales y velocidades existentes. La dificultad se configura antes de iniciar la primera oleada. Reiniciar no acumula crecimiento.

| Enemigo | Vida base | Vida / oleada | Daño base | Daño / oleada | Velocidad |
| --- | --- | --- | --- | --- | --- |
| Fast | 6 | 2 | 2 | 0,35 | 350 |
| Mid | 10 | 4 | 3 | 0,45 | 250 |
| Slow | 20 | 9 | 4 | 0,60 | 150 |
| Charger | 12 | 5 | 5 | 0,75 | 230 |
| Shooter | 8 | 3 | 3 | 0,40 | 250 |

Las hordas usan 50% Fast, 37,5% Mid y 12,5% Slow, con intervalo de aparición ×0,65. Se mantienen las duraciones y los intervalos base existentes. El aviso visual de aparición dura lo mismo y no bloquea el siguiente aviso.

Máximo configurable: 80 enemigos comunes vivos. Las apariciones pendientes reservan plazas; al llegar al límite se espera, sin eliminar enemigos ni generar recompensas. Terminar, salir o reiniciar invalida las apariciones pendientes.

Fueguito conserva su escena, estadísticas, comportamiento y aparición desde la oleada 2; se maneja por separado y no recibe estos multiplicadores.

Referencia: https://brotato.wiki.spellsandguns.com/Danger_Levels y https://brotato.wiki.spellsandguns.com/Enemies.

Esta es una primera pasada de balance; verificar con partidas completas.
