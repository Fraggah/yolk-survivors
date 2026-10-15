# Balance de armas en el editor

Abrir el `stats_…_1.tres`, `stats_…_2.tres`, etc. del arma en
`resources/items/weapons/melee/` o `resources/items/weapons/range/`.
Cada archivo configura un tier. Cambiar uno no cambia los otros.

Los campos habituales controlan daño, escalado, cooldown, alcance, críticos,
robo de vida, empuje, perforación, rebotes y velocidad del proyectil.
`Slow Duration` controla la duración de la ralentización de la sartén.

Desplegar `Melee Settings` para los ataques especiales:

| Grupo | Qué controla |
| --- | --- |
| Animation | Velocidad, preparación, avance, retorno, contacto y pausa |
| Motion | Distancia relativa al alcance, ángulos y desplazamientos |
| Repeated hits | Cantidad de golpes por ataque |
| Glove | Daño directo, daño por choque, velocidad y duración del lanzamiento |
| Hammer | Daño y empuje de las dos fases |
| Grater | Radio del grupo capturado |
| Pan | Radio, intensidad de ralentización y zona del golpe inicial |
| Pan visual effect | Duración, opacidad, color, forma ovalada, líneas, partículas y texto |
| Rotating blade visual | Velocidad, radio, color y grosor del brillo giratorio |

Solo se usan los grupos correspondientes a la mecánica del arma.
Las duraciones son segundos y los multiplicadores usan `1 = 100%`.
Los campos que terminan en `angle` usan grados; las rotaciones del rallador,
minipimer y brillo giratorio usan radianes.

La recuperación final del arma usa `Back Duration`. La espátula y el cuchillo
de carnicero usan también `Recoil Duration` y `Attack Duration` para sus fases;
el cuchillo usa los ángulos y radio semicircular de `Melee Settings > Motion`.
Las otras melee usan las duraciones de `Melee Settings > Animation`.

`Animation Speed = 1` es velocidad normal; `0.35` reproduce la animación del
guante actual. La velocidad de ataque del personaje sigue afectando al ciclo.
`Timing Reference` y `Animation Cooldown Fraction` conservan la relación entre
animación y cooldown; no hace falta tocarlos para ajustar las fases habituales.

El daño del guante mostrado en su tarjeta es la base del choque: sus
multiplicadores permiten ajustar por separado el golpe directo y la colisión.
Los ataques repetidos muestran daño por impacto. El texto de comportamiento
de cada tarjeta se edita en el `item_…tres`, mediante `Attack Description`.

Conservar un recurso de `Melee Settings` propio para cada tier. Si se comparte
manualmente el mismo recurso entre tiers, todos usarán los cambios de ese recurso.
