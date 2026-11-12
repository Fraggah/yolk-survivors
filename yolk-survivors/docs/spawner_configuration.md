# Configuración de oleadas y spawner

En `scenes/arena/arena.tscn → Spawner → Difficulties`, cada posición (0 a 5) referencia un recurso de `resources/wave/difficulties/`. Abrí la dificultad y editá **Waves** para cambiar el orden o la longitud de la partida. La primera entrada es la oleada 1 y la última marca la victoria. Asignar **Boss Encounter** activa ese encuentro con su propia arena y mecánicas.

Los seis recursos arrancan con la progresión existente de 20 oleadas y comparten las referencias a `resources/wave/data/`. Si editás un WaveData compartido, el cambio se aplica a todas sus referencias. Para balancear una sola dificultad, duplicá el WaveData y los SpawnGroup o ScheduledSpawn que quieras modificar, guardá la copia como recurso y reemplazá esa entrada solo en su lista.

**Enemy Multipliers** configura vida, daño, velocidad, resistencia al empuje y frecuencia de aparición. Un valor de 1 conserva la base. Los modificadores de oleada se aplican además de los de dificultad. La frecuencia divide el intervalo de los grupos, respetando su mínimo. Los eventos programados conservan su segundo y cantidad. El encuentro dedicado de Salchichón conserva sus propias estadísticas.

## Duración y tipo

- **Wave Time**: segundos de la oleada. Valor base y configuración de las 20 actuales: **30**. Se puede editar individualmente.
- **Wave Type**: Normal, Horde, Special o Boss. Horde aplica ×2 a los enemigos comunes por tanda en Groups y Events, incluidos los cardúmenes. Se combina con la densidad aplicable y respeta el cupo común. Scheduled Spawns conserva su cantidad literal.
- **Arena Mode**: Base, Fixed o Random Special. Es independiente del tipo: una horda puede usar la arena base o una especial.
- **Base**: plato sin mecánicas (`neutral_plate`).
- **Fixed**: asignar la arena concreta en **Fixed Arena**, usando un recurso de `resources/environments/stages/`.
- **Random Special**: sortea únicamente entre arenas que tienen una mecánica. No incluye el plato base. Se sortea una vez por oleada y partida: el anuncio de la tienda y el combate usan el mismo resultado.

Las oleadas que ya estaban marcadas Special conservan su carácter especial mediante Random Special. Las demás usan Base salvo configuración explícita. No se cambió la composición de la horda existente (11) ni de los enemigos de otras oleadas.

Los ítems que fuerzan una arena, el ítem que fuerza horda y el selector temporal de pruebas siguen funcionando. El selector de pruebas tiene prioridad: dejarlo en **usar configuración de oleada** para probar estas reglas. La selección de arenas se reinicia al comenzar una partida.

## Enemigos por peso: Groups

Cada elemento de **Groups** es un recurso SpawnGroup:

- **Enemies**: perfiles de `resources/wave/enemies/` que pueden aparecer en ese grupo.
- **Weights**: pesos relativos, en el mismo orden que Enemies. Ejemplo: Mini/Mid/Fast con pesos 6/3/1 produce aproximadamente 60%/30%/10%. No hace falta que sumen 100. Peso 0 deshabilita esa entrada; un peso omitido equivale a 1.
- **Start Second**, **Interval**, **Minimum/Maximum Count**: inicio, cadencia y cantidad por tanda. **Repetitions = -1** repite hasta el final; un número positivo limita las tandas.
- **Spawn Zone**: Anywhere (libre), Edges (bordes) o Interior (excluye bordes).
- **Edge Width**: ancho de la franja interior que se considera borde, en unidades del mundo (200 de base). Se mide contra el contorno real, incluyendo arenas ovaladas y esquinas redondeadas. No es el borde de la cámara.
- **School**, **School Radius** y **School Probability** conservan los cardúmenes; cada integrante respeta la zona elegida.
- **Affected By Density** y las opciones de densidad/prueba existentes se conservan. La ponderación elige qué enemigo sale, no altera la cadencia.

Se respetan distancia mínima al jugador, margen del enemigo, obstáculos y límites de población. Si la franja elegida no tiene una posición segura, no se usa otra zona como reemplazo. La reubicación al terminar la advertencia de aparición también respeta la zona.

## Apariciones forzadas: Scheduled Spawns

Agregar un elemento a **Scheduled Spawns**, crear un recurso **ScheduledSpawn** y editar:

- **Enemy**: perfil exacto del enemigo.
- **Second**: segundo de la oleada en el que aparece (usar un valor menor a Wave Time).
- **Count**: cantidad literal de enemigos; no recibe multiplicadores de densidad, dificultad ni cantidad de enemigos.
- **Spawn Zone / Edge Width**: mismas reglas de zona que los grupos.
- **Telegraph**: desactivado por defecto, aparece el enemigo al segundo elegido con precisión del planificador (hasta 0,1 s). Si se activa, ese segundo inicia la animación de advertencia y el enemigo aparece al terminarla.

Estos eventos no tiran probabilidades ni pesos y tienen prioridad sobre los grupos ponderados en el mismo paso. Cada evento se ejecuta una sola vez por oleada. Si falta capacidad o una posición segura, conserva la cantidad pendiente y reintenta mientras esa oleada continúe; no supera el límite de población. Lo que no llegó a entrar se cancela al terminar la oleada, no pasa a la siguiente. Un reinicio de oleada reinicia sus eventos.

La lista antigua **Events** se conserva para eventos avanzados basados en SpawnGroup, con sus reglas anteriores. Para elegir simplemente un enemigo, segundo y cantidad, usar Scheduled Spawns.

## Pruebas

- `verify_spawner_configuration.gd`: 20.000 sorteos de pesos; peso cero; 30 segundos; base/fija/aleatoria y selección estable; bordes/interior de las seis arenas; evento literal en el segundo indicado; reintentos por límite; cardúmenes y reinicio.
- `verify_school_waves.gd`: cardúmenes y horda existentes.
- `verify_spawn_limits.gd`: límites reales y reservas de apariciones.
- `verify_arena_stages.gd`, `verify_stage_mechanics.gd`: geometría, vista previa y mecánicas.
- `verify_wave_run.gd`: recorrido completo por las 20 oleadas con tiempos comprimidos solo en la prueba.

Ejecutar con Godot headless usando `--path yolk-survivors --script res://tests/NOMBRE.gd`.

## Enemigos de recompensa

Yolker e Incógnito tienen perfiles en `resources/wave/enemies/yolker.tres` e `incognito.tres`. Se usan en Groups o Scheduled Spawns igual que los demás. Su población es REWARD y el límite se configura por oleada con **Reward Limit** (2 de base); no consumen Hazard Limit ni Boss Limit. La oleada 1 incluye apariciones iniciales de prueba en los segundos 10 y 18. Ver reward_enemies.md para arte, estadísticas y recompensas.
