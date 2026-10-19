# Curación del jugador

## Causa de las curaciones grandes

El temporizador de regeneración esperaba 3 segundos y cada pulso curaba el valor entero de `hp_regen`. Con 5, 7 u 8 puntos, eso producía curaciones de 5, 7 u 8 HP de golpe. El robo de vida también multiplicaba los 0,1 HP por activaciones completas cuando la probabilidad superaba 100%.

## Regla acordada

Cada punto positivo de regeneración aporta **0,1 HP por segundo**, acumulando fracciones y aplicando pulsos de hasta **0,1 HP**. Por ejemplo: 1 punto = 0,1 HP/s; 5 = 0,5 HP/s; 8 = 0,8 HP/s. Valores fraccionarios se conservan; valores negativos o cero no curan ni dañan.

`HPTimer` comprueba la recuperación cada 0,1 s. El intervalo se convierte en segundos de curación mediante la tasa anterior; no se utiliza la estadística entera como cantidad de un pulso. Si la tasa es alta puede haber varios micropulsos en una comprobación, todos de hasta 0,1 HP. Los textos usan la cantidad efectivamente recuperada, incluido el último pulso parcial para llegar a la vida máxima.

La pausa no acumula curación. Estar a vida completa o muerto descarta el crédito pendiente; el cambio de oleada lo reinicia. Se conserva la recuperación completa propia del inicio de oleada.

El robo de vida realiza una sola consulta por golpe confirmado: `clamp(probabilidad, 0, 1)`. Un éxito cura como máximo 0,1 HP, independientemente del daño infligido y de los puntos por encima de 100%. Conserva el enfriamiento compartido de 0,1 s entre fuentes, el bloqueo durante pausa/muerte y el límite de vida máxima.

Los ítems con curación explícita (por ejemplo Vitamina B o Hongo desconocido) conservan sus cantidades; no se limita globalmente HealthComponent.heal porque esos son efectos separados.

Los bonus temporales de Guante térmico y los puntos permanentes de Huevo añejo siguen sumándose a la misma estadística y usan la nueva tasa. El selector de personajes deja de indicar una regeneración cada 3 s; el panel de estadísticas incluye una explicación al pasar el cursor.

## Verificación

- `verify_player_healing.gd`: valores 1/5/7/8/20, micropulsos, valores fraccionarios, timer real, pausa, vida completa, muerte y cambio de oleada; robo de vida con exceso de probabilidad.
- `verify_core_player_stats.gd`: probabilidad fraccionaria y daño real de un enemigo para activar el robo de vida, enfriamiento y recuperación parcial hasta vida máxima.
- `verify_thermal_glove.gd`, `verify_aged_egg.gd`, `verify_player_roster.gd`: bonus de regeneración y personajes.
