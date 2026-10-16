# In-game stress test

Select a character and implemented weapon normally, then choose **PRUEBA DE ESTRÉS — 500 ENEMIGOS** or **PRUEBA DE ESTRÉS — 1000 ENEMIGOS** on the difficulty/level screen. Both start with six independent copies of the chosen weapon and an invulnerable player. Preview-only pets with no implemented weapon cannot start this test.

StressTest spawns normal Mid enemies in batches of 100 every 2 seconds, spread across frames (10 new enemies per frame). It fills toward 1000 simultaneous living enemies and replenishes deaths to keep the load. Actual arena spawn geometry and ordinary Mid stats/AI/collision are retained. This separate spawner path bypasses normal wave population caps only for the stress test; regular caps/resources are unchanged.

The HUD displays FPS, living count/1000 and total generated count. Normal wave timers/hazards are stopped so the load does not end or vary due to stage events. The player can move/fight and pause/exit normally. Damage feedback, particles, corpses and yolk drops remain representative. Experience/level-up offers and achievement progression are excluded from this mode; it cannot unlock difficulties. Starting a normal run afterward restores ordinary health, weapons, progression and wave scheduling.

Runtime tuning is in `scenes/arena/stress_test.gd`: the selected button sets target_population to 500 or 1000, batch_size=100, batch_interval=2, spawn_per_frame=10. Reducing per-frame spawning changes fill speed, not the final target. Its lifecycle is owned by Arena and stops on clear/exit. Six-copy equipment respects the selected character's valid weapon choice.

Validation: `tests/verify_stress_mode.gd` activates the actual level-screen button, checks all six weapons, invulnerability, stopped wave timers, phased fill to exactly 1000, death replenishment, pause, no experience/progression, exit cleanup and a subsequent normal run. The automated population test disables enemy processing to test scheduling deterministically; live stress mode retains normal AI. `capture_stress_mode.gd` verifies native UI placement and a real initial six-Hydrant spawn batch.
