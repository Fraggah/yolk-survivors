# SFX conectados: campos del Inspector

Asignar los archivos en `autoload/sound_manager.tscn`. Todos los campos de SFX quedan vacíos, incluidos los anteriores: un campo vacío no reproduce audio. Las conexiones y los archivos de audio se conservan.

| Grupo | Campos nuevos y evento |
|---|---|
| Jugador y recompensas | `dash`: al iniciar el dash; `enemy_death`: muerte real, sin reproducirse en la limpieza de oleada; `yolker_burst`: al soltar sus yemas; `incognito_confetti`: al generar el confeti; `level_up`: al ganar el nivel. |
| Estados | `burning_apply`: inicio de Burning; `electric_apply`: entrada en Shoked. Renovar un estado todavía activo o aplicar un tick no vuelve a reproducir la entrada. |
| Explosiones y ataques continuos | `explosion`: explosiones de proyectiles, chilis y Scotch Bonnet; `default_continuous_attack`: alternativa para armas de chorro sin audio continuo propio. |
| Moneda de chocolate | `coin_spin`: comienzo del giro; `coin_reveal`: resultado visible; `coin_win` / `coin_lose`: resultado correspondiente. También se aplica a Gambler. |
| Yema de oro y Rebozado | `golden_anticipation`: inicio de la secuencia; `golden_impact`: choque y destello blanco; `golden_reveal`: revelación; `golden_success` / `golden_broken`: resultado; `breading_apply`: aplicación válida de una tag. |
| Boss | `laser_warning`: comienzo del aviso; `laser_fire`: encendido; `turret_spawn`: aparición; `boss_jump`: despegue después de comprimirse; `boss_fall_warning`: inicio del aviso oval; `boss_impact`: impacto. |
| Fueguitos | `fueguito_spawn` y `fueguito_exit`: materialización y retirada, tanto en escenarios normales como en las secciones/fases del boss y los generados por el spawner. El campo antiguo `fueguito` sirve de alternativa para aparición si el nuevo está vacío. |

## Cada arma

En el nodo raíz de la escena del arma:

- `Attack Sound`: sonido puntual de ataque, ya existente.
- `Impact Sound`: impacto de esa arma al causar daño a un enemigo. Sigue al proyectil aunque el arma haya sido vendida. No se reproduce por ticks de estado.
- `Continuous Sound`: audio sostenido para chorro de mayonesa, soplete e hidrante, que comparten el comportamiento continuo. Repite mientras ataca, se pausa con el juego y se corta al perder objetivo, reiniciar el ataque, terminar la oleada o eliminar el arma. Para una repetición sin cortes, conviene importar el audio con loop; un clip sin loop vuelve a reproducirse al finalizar.

Los sonidos puntuales conservan la protección de 40 ms entre repeticiones del mismo evento y el límite de voces. Los rayos de un patrón comparten evento para no superponer un sonido por cada línea. El audio continuo usa un reproductor propio de cada arma, vinculado al bus SFX.

## Verificación

`tests/verify_selected_sfx.gd`: campos vacíos, dash y nivel, secuencias de moneda/Yema de oro, estados, recompensas, Fueguitos, impactos, repetición/pausa/corte del continuo y ataques del boss.

## Nivel de los sonidos de UI

Todos los eventos usan la ganancia por defecto, sin compensaciones individuales (0 dB). Event Gain Db queda vacío. Los archivos y las asignaciones de audio se conservan.

