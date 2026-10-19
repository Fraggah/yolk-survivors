# Filtrado de iconos de tienda

Los iconos grandes se reducen a 80–100 píxeles en las tarjetas. Las tarjetas usaban LINEAR_WITH_MIPMAPS, pero sus texturas no generaban mipmaps y aparecían bordes dentados.

Se habilitó `mipmaps/generate=true` en las importaciones de 142 texturas referenciadas como `item_icon` por los recursos de armas y pasivos. Se conserva la compresión sin pérdida, transparencia y corrección de bordes alfa. El icono de WeaponTooltip también usa `texture_filter=4` (Linear with mipmaps), igual que ShopCard e ItemCard.

Para nuevos iconos, activar Generate Mipmaps en Import y reimportar; mantener Linear with mipmaps en el TextureRect. No cambia el arte ni los tamaños configurados por ítem.

Validación: reimportación y comparación renderizada en Godot con y sin mipmaps, a tamaño reducido. Comparación local: `../tmp/shop-icons-comparison.png` desde la raíz del repositorio.
