# Rarezas de mejoras por nivel

La progresión usa el nivel real del personaje que generó la recompensa, no la oleada terminada. Los refrescos conservan ese mismo nivel y sus probabilidades. Se conservan cuatro opciones, estadísticas distintas por tanda, aplicación de mejoras y precios de refresco.

- Niveles 1 y 2: solo comunes.
- Nivel 3: se habilita raro, con 3,33% de probabilidad inicial.
- Nivel 10: se habilita épico, con 1,82% inicial.
- Nivel 15: se habilita legendario, con 0,83% inicial.
- Nivel 20 en adelante: 40% común, 40% raro, 15% épico y 5% legendario.
- Suerte no interviene, según lo acordado para esta primera versión.

Los caps acumulados son Raro o superior 60%, Épico o superior 20%, Legendario 5%. Cada categoría crece linealmente desde su desbloqueo hasta el nivel 20 (incluyendo un primer incremento en el nivel de desbloqueo). Común es el residual. Se realizan tiradas secuenciales de mayor a menor rareza, con probabilidades condicionales que reproducen la distribución final.

Para una rareza con desbloqueo S y cap C, la probabilidad acumulada es cero antes de S; desde S es `min(C, C × (nivel-S+1)/(20-S+1))`, usando un nivel limitado a 20. Las probabilidades finales son `[1-R, R-E, E-L, L]`.

| Nivel | Común | Raro | Épico | Legendario |
|---|---:|---:|---:|---:|
| 1 | 100.00% | 0.00% | 0.00% | 0.00% |
| 2 | 100.00% | 0.00% | 0.00% | 0.00% |
| 3 | 96.67% | 3.33% | 0.00% | 0.00% |
| 5 | 90.00% | 10.00% | 0.00% | 0.00% |
| 9 | 76.67% | 23.33% | 0.00% | 0.00% |
| 10 | 73.33% | 24.85% | 1.82% | 0.00% |
| 14 | 60.00% | 30.91% | 9.09% | 0.00% |
| 15 | 56.67% | 32.42% | 10.08% | 0.83% |
| 20 | 40.00% | 40.00% | 15.00% | 5.00% |

## Edición y simulaciones

`resources/upgrade_rarity.gd` contiene STARTS, CAPS y LAST_BASE_LEVEL. La tienda conserva su curva independiente en shop_rarity.gd, con desbloqueos 2/9/15. Los ítems encontrados fuera de ambos paneles no se modifican.

Prueba de reglas e integración: `godot --headless --path yolk-survivors --script res://tests/verify_upgrade_progression.gd`.

Simulación repetible: `godot --headless --path yolk-survivors --script res://tests/simulate_upgrade_rarity.gd -- --samples=50000 --seed=12345`. Genera un millón de tiradas entre los niveles 1 y 20 y comprueba que cada proporción quede dentro de seis desviaciones estándar más 0,05 puntos porcentuales. Exporta `output/upgrade-rarity-simulation.csv`.

Con `--offers --samples=1000` genera cuatro ofertas mediante el selector real, usando un catálogo controlado con todas las rarezas para aislar la política de rareza. Exporta `output/upgrade-full-offers-simulation.csv`. No es necesario jugar oleadas.
