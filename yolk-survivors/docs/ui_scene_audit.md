# Auditoría de escenas UI — 27/10/2026

Etapa 1: comparación de jerarquía guardada frente a jerarquía en ejecución. Los nodos adicionales de datos repetidos (inventario/ofertas) se distinguen de la estructura base ausente.

## selection_panel
- Escena: res://scenes/ui/selection_panel/selection_panel.tscn
- Nodos guardados: 32. Nodos en ejecución: 194. Rutas adicionales o reubicadas: 180.
  - RosterLayout
  - RosterLayout/Label
  - RosterLayout/CustomButtonExit
  - RosterLayout/Panel
  - RosterLayout/Panel/MarginContainer
  - RosterLayout/Panel/MarginContainer/Control
  - RosterLayout/Panel/MarginContainer/Control/PlayerIcon
  - RosterLayout/Panel/MarginContainer/Control/PlayerName

## weapon_selection_panel
- Escena: res://scenes/ui/selection_panel/weapon_selection_panel.tscn
- Nodos guardados: 32. Nodos en ejecución: 429. Rutas adicionales o reubicadas: 415.
  - RosterLayout
  - RosterLayout/Label
  - RosterLayout/CustomButtonExit
  - RosterLayout/Panel
  - RosterLayout/Panel/MarginContainer
  - RosterLayout/Panel/MarginContainer/Control
  - RosterLayout/Panel/MarginContainer/Control/PlayerIcon
  - RosterLayout/Panel/MarginContainer/Control/PlayerName

## start_panel
- Escena: res://scenes/ui/start_panel/start_panel.tscn
- Nodos guardados: 16. Nodos en ejecución: 20. Rutas adicionales o reubicadas: 4.
  - DebugProgressTools
  - DebugProgressTools/@Button@263
  - DebugProgressTools/@Button@264
  - DebugProgressTools/@Label@265

## upgrade_panel
- Escena: res://scenes/ui/upgrades/upgrade_panel.tscn
- Nodos guardados: 189. Nodos en ejecución: 201. Rutas adicionales o reubicadas: 12.
  - HBoxContainer/VBoxContainer/ItemContainer/UpgradeCard/RarityMarker
  - HBoxContainer/VBoxContainer/ItemContainer/UpgradeCard/RarityMarker/Text
  - HBoxContainer/VBoxContainer/ItemContainer/UpgradeCard2/RarityMarker
  - HBoxContainer/VBoxContainer/ItemContainer/UpgradeCard2/RarityMarker/Text
  - HBoxContainer/VBoxContainer/ItemContainer/UpgradeCard3/RarityMarker
  - HBoxContainer/VBoxContainer/ItemContainer/UpgradeCard3/RarityMarker/Text
  - HBoxContainer/VBoxContainer/ItemContainer/UpgradeCard4/RarityMarker
  - HBoxContainer/VBoxContainer/ItemContainer/UpgradeCard4/RarityMarker/Text

## incognito_rewards
- Escena: No existía; construida por script
- Nodos guardados: 0. Nodos en ejecución: 13. Rutas adicionales o reubicadas: 13.
  - @ColorRect@353
  - @CenterContainer@354
  - @CenterContainer@354/@PanelContainer@355
  - @CenterContainer@354/@PanelContainer@355/@MarginContainer@356
  - @CenterContainer@354/@PanelContainer@355/@MarginContainer@356/@VBoxContainer@357
  - @CenterContainer@354/@PanelContainer@355/@MarginContainer@356/@VBoxContainer@357/@Label@358
  - @CenterContainer@354/@PanelContainer@355/@MarginContainer@356/@VBoxContainer@357/@Label@359
  - @CenterContainer@354/@PanelContainer@355/@MarginContainer@356/@VBoxContainer@357/@TextureRect@360

## chocolate_coin_reveal
- Escena: No existía; construida por script
- Nodos guardados: 0. Nodos en ejecución: 6. Rutas adicionales o reubicadas: 6.
  - @ColorRect@377
  - @Panel@378
  - @Panel@378/@TextureRect@379
  - @Panel@378/@Label@380
  - @Panel@378/@Button@381
  - @Node2D@382

## golden_yolk_reveal
- Escena: No existía; construida por script
- Nodos guardados: 0. Nodos en ejecución: 8. Rutas adicionales o reubicadas: 8.
  - @ColorRect@384
  - @Panel@385
  - @Panel@385/@TextureRect@386
  - @Panel@385/@Label@387
  - @Panel@385/@Button@388
  - @Panel@385/@TextureRect@390
  - @Panel@385/@ColorRect@391
  - @Node2D@389

## player_damage_feedback
- Escena: No existía; construida por script
- Nodos guardados: 0. Nodos en ejecución: 5. Rutas adicionales o reubicadas: 5.
  - @CanvasLayer@347
  - @CanvasLayer@347/@ColorRect@348
  - @ColorRect@349
  - @Sprite2D@350
  - @CPUParticles2D@351

## health_bar
- Escena: res://scenes/health_bar/health_bar.tscn
- Nodos guardados: 2. Nodos en ejecución: 4. Rutas adicionales o reubicadas: 2.
  - ProgressBar/ClippedFill
  - ProgressBar/Outline

## unlock_notice
- Escena: No existía; construida por script
- Nodos guardados: 0. Nodos en ejecución: 11. Rutas adicionales o reubicadas: 11.
  - UnlockScreen
  - UnlockScreen/@ColorRect@398
  - UnlockScreen/@Control@399
  - UnlockScreen/@Control@399/@Label@400
  - UnlockScreen/@Control@399/@CPUParticles2D@408
  - UnlockScreen/@Control@399/@TextureRect@401
  - UnlockScreen/@Control@399/@Label@402
  - UnlockScreen/@Control@399/@Label@403

## boss_health_bar
- Escena: No existía; construida por script
- Nodos guardados: 0. Nodos en ejecución: 5. Rutas adicionales o reubicadas: 5.
  - @Label@410
  - @ProgressBar@411
  - @ProgressBar@411/@ColorRect@412
  - @ProgressBar@411/@ColorRect@413
  - @Label@414

## options_panel
- Escena: res://scenes/ui/options_panel/options_panel.tscn
- Nodos guardados: 18. Nodos en ejecución: 18. Rutas adicionales o reubicadas: 0.

## credits_panel
- Escena: res://scenes/ui/credits_panel/credits_panel.tscn
- Nodos guardados: 36. Nodos en ejecución: 36. Rutas adicionales o reubicadas: 0.

## pause_panel
- Escena: res://scenes/ui/pause_panel/pause_panel.tscn
- Nodos guardados: 169. Nodos en ejecución: 169. Rutas adicionales o reubicadas: 0.

## level_panel
- Escena: res://scenes/ui/level_panel/level_panel.tscn
- Nodos guardados: 22. Nodos en ejecución: 22. Rutas adicionales o reubicadas: 0.


# Etapa 2 — Correcciones aplicadas

La comparación anterior conserva el diagnóstico **previo** a esta migración.

| Grupo | Resultado |
| --- | --- |
| Selección de personajes y armas | Grillas, retratos, tarjetas de detalle, filas cooperativas y marcadores guardados en sus escenas. Se eliminó la construcción y reubicación inicial. Contenedor adaptable visible en editor, con tamaño de diseño editable. |
| Menú principal | Herramientas de desarrollo y controles guardados en escena. |
| Mejoras de nivel | Refresco y bandas de rareza nativos; títulos parten del tamaño definido en la escena. |
| Objetos obtenidos | Escena individual completa y contenido del botón de venta cooperativo en su jerarquía definitiva. |
| Moneda y Yema de oro | Escenas completas del modal, sprites, botones, destello y capa de partículas. La moneda tiene sus cuadros de animación como recursos editables. |
| Desbloqueos | Escena completa; tamaños, fuentes, posiciones iniciales y marcadores de destino de la animación editables. |
| Pausa e inventarios | Plantillas de armas y espacios vacíos nativas. El código solo añade instancias según los objetos del jugador. |
| Estadísticas y detalles de armas | Variantes cooperativas con sus fuentes guardadas; se retiraron los cambios de tamaño al iniciar. |
| HUD y vida del boss | Escena de barra del boss y variante de barras de interfaz con relleno y contorno nativos. |
| Daño, muerte y pantalla final | Escenas de feedback y pantalla final; derrota y victoria tienen vistas propias guardadas. |
| Elementos compartidos | Rareza, ofertas, carteles de oferta, texto de estados y herramientas de prueba usan escenas/plantillas editables. |
| Opciones, créditos y dificultad | La comparación original confirmó su estructura nativa; no requerían reconstrucción. |

## Qué sigue siendo dinámico

Los datos, inventarios, visibilidad por estado, colores de rareza/jugador y animaciones siguen siendo dinámicos. Los tooltips se colocan junto al elemento seleccionado y se limitan al espacio disponible. Los contenedores adaptan el diseño al tamaño disponible también en el editor. Esto no reemplaza los tamaños, fuentes o disposición base guardados.

Para editar un modal oculto, activar temporalmente su visibilidad en el editor. Sus controles ya existen antes de ejecutar. Los ítems repetidos se editan en sus escenas plantilla, no como elementos creados a mano por el script.

# Etapa 3 — Verificación

- Comparación automatizada de jerarquía y marcos nativos frente a ejecución: `tests/verify_ui_scene_sources.gd`.
- Tienda individual: comparación de geometría y respeto de cambios de posición/altura hechos antes de iniciar.
- Selección: 1280×720, 1920×1080 y 2560×1440; transición, vuelta y confirmación.
- Cooperativo: selección independiente, tienda, mejoras separadas, pausa por propietario y bloqueo persistente del mouse.
- Revelaciones: moneda, Yema de oro y desbloqueos; derrota y feedback de daño.
- Revisión de capturas de selección, tienda cooperativa y mejoras.

Las comparaciones de geometría excluyen mínimos dependientes del texto/datos dentro de grillas y filas de estadísticas; su estructura y plantillas sí se comprueban. Las pruebas antiguas que simulaban hover de mouse en cooperativo se actualizaron al comportamiento vigente: el mouse permanece bloqueado.

Resultado: las pruebas de UI enumeradas pasaron. Una prueba antigua adicional de combate (`verify_status_system.gd`, línea 36) falla en su expectativa de daño al bloquear, antes de alcanzar los textos de estados; no se modificó esa mecánica como parte de esta revisión de UI.
