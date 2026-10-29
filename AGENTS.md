# Reglas del proyecto

## Escenas editables en Godot

- Dejar siempre correcta la disposición base en la propia escena: sprites, pivotes, sombras, escalas, posiciones y colisiones deben estar acomodados y ser editables en el editor.
- La escena es la fuente de esos valores. No corregir una escena desacomodada mediante valores hardcodeados al iniciar ni sobrescribir silenciosamente los ajustes del usuario.
- El código puede animar o modificar valores durante el juego cuando la mecánica lo requiere, partiendo de la configuración de la escena y respetándola como base.
- Verificar tanto la configuración guardada de la escena como el resultado en juego.

- En UI, la jerarquía, los contenedores, botones, tamaños, fuentes, márgenes y disposición base deben existir en las escenas `.tscn`. No crearlos, reparentarlos ni acomodarlos en `_ready` para reemplazar el diseño del editor. El código solo actualiza datos/estados o realiza animaciones y posicionamiento contextual que realmente dependen del juego (por ejemplo un popup sobre el slot elegido), respetando la base editable.
