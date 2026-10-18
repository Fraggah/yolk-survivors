# Soplete de cocina / Kitchen Torch

Integrado al juego, selección y tienda con cuatro tiers y la versión de arte aprobada (depósito estrecho y boquilla al 60% de la original). Icono inclinado -35 grados y centrado con el mismo padding del catálogo. El selector temporal con scroll admite ahora 42 armas.

Arma ranged llameante de muy corto alcance. Usa un chorro continuo con trazado por hurtboxes y daño por ticks; no crea proyectiles viajeros. Aplica fuego al 100%, sin electricidad. Balance inicial: alcance 140; daño por tick 2/3/4/5, 25% de escalado ranged; intervalos 0.18/0.17/0.16/0.15 s. Quemado: 2/3/4/5 de daño cada 0.5 s, durante 2.5 s, escalando con Efectos y velocidad de tick como los demás estados. El daño directo conserva crítico, robo de vida y atribución al arma.

El flujo reutiliza la detección continua de Hydrant, con presentación propia: una silueta de llama continua animada en Line2D mediante kitchen_torch_flame.gdshader, con márgenes transparentes explícitos y punta que se desvanece, sin sprites rectangulares superpuestos ni partículas de mayonesa. Se detiene al perder el objetivo o reiniciar el arma y se pausa con el juego. Z relativo 0 dentro del grupo del personaje para respetar profundidad con enemigos y columnas.

Ajustes: `resources/items/weapons/range/kitchen_torch/stats_kitchen_torch_1.tres` y tiers 2–4 para alcance, tick de daño y ancho; `item_kitchen_torch_1.tres` y tiers para quemado y upgrades. Escena `scenes/weapons/range/weapon_kitchen_torch.tscn`; comportamiento `kitchen_torch_stream.gd`. El arte aprobado original queda en Source/kitchen_torch.png, exportaciones en InGame y Icons; script de exportación reproducible en documentacion-local/conceptos/soplete-v1/build-assets.ps1.

Validación: verify_kitchen_torch comprueba trazado real sobre hurtbox, daño repetido, quemado sin electricidad, pausa, pérdida de objetivo, reset, cuatro tiers de tienda y selección. También pasan verify_spark_lighter, verify_selection_layout, verify_weapon_selection_scroll y verify_hydrant_stream. Capturas GPU: documentacion-local/validacion/soplete-in-game.png y soplete-panel.png.

Corrección visual: se reemplaza el primer grupo de sprites, que podía verse cuadrado al amontonarse cerca del objetivo. Alcance duplicado de 70 a 140 en los cuatro tiers. La regresión comprueba un enemigo situado a 150 unidades mundiales desde la boquilla, más allá del límite previo de 105. Captura actual: documentacion-local/validacion/soplete-flame-v2.png.
