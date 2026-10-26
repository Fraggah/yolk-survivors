# Boss en la oleada 20

`resources/wave/data/wave_20.tres` usa el tipo BOSS y referencia `resources/bosses/salchichon.tres` mediante `boss_encounter`.

El encuentro elige su propia arena, conserva la build de la partida y reemplaza los grupos y eventos de spawn de esa oleada. No usa el límite de tiempo de la wave: termina al derrotar al boss y continúa por el flujo habitual de recompensas y victoria. La tienda posterior a la oleada 19 muestra el aviso del boss. El recurso del boss sigue controlando vida, tiempos y ataques; no se aplican los atributos del personaje de prueba.

El botón de prueba conserva su comportamiento aislado. Las escenas mantienen sus transformaciones editables como base.

Verificación: `tests/verify_wave20_boss.gd` cubre aviso, entrada con build real, temporizadores detenidos, pausa, tres fases y victoria. `verify_boss_encounter.gd` cubre el modo de prueba. `verify_wave_run.gd` usa copias sin encuentro para comprobar el flujo alternativo de oleadas temporizadas.
