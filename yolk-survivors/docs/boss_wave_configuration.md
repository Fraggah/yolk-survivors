# Configurar una oleada de boss

En el WaveData, asigná `resources/bosses/salchichon.tres` a **Boss Encounter**. Esa asignación activa el combate y tiene prioridad sobre **Wave Type** y **Arena Mode**. La arena y las mecánicas ya forman parte del encuentro. `salchichon_arena.tres` solo se edita para cambiar la arena propia del boss.

El encuentro conserva la build de la partida y reemplaza los grupos y eventos de spawn de esa oleada. La oleada termina al derrotar al boss. Si es la última de la dificultad, activa la victoria. La tienda anterior muestra el aviso del boss. El recurso del encuentro controla la vida, los tiempos y los ataques.

El botón de prueba conserva su comportamiento aislado. Las escenas mantienen sus transformaciones editables como base.

Verificación: `tests/verify_wave20_boss.gd` cubre aviso, entrada con build real, temporizadores detenidos, pausa, tres fases y victoria. `verify_boss_encounter.gd` cubre el modo de prueba. `verify_wave_run.gd` usa copias sin encuentro para comprobar el flujo alternativo de oleadas temporizadas.
