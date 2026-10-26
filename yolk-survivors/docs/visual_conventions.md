# Criterios visuales

## Configuración base en escena

Mantener sprites, pivotes, sombras, escalas, posiciones y colisiones correctamente
acomodados en la propia escena de Godot para facilitar su edición. No arreglar la
disposición mediante valores hardcodeados al iniciar. Las animaciones y mecánicas
deben partir de los valores de la escena, sin sobrescribir los ajustes del usuario.
Verificar la configuración guardada y el resultado en juego.

Las áreas circulares sobre el suelo se representan como óvalos achatados en Y,
para respetar la perspectiva del juego. Esto se aplica a ondas, áreas de efecto
y sus partículas. No se aplica a elementos circulares de la interfaz.

La sartén usa una proporción Y de 0,55 y una opacidad máxima de 0,30. Su zona
efectiva de ralentización usa el mismo óvalo que el efecto visible.

## Paleta de armas elementales · Chispero

Referencia persistente para nuevas armas: conservar el azul eléctrico actual y usar el rojo del chispero para las armas llameantes.

| Uso | Base | Luz | Sombra |
|---|---|---|---|
| Electricidad, mango azul del cuchillo eléctrico | `#62849F` | `#89ADBE` | `#405F74` |
| Fuego, rojo del encendedor chispero | `#D94A35` | `#F27A56` | `#A92E25` |
| Contorno compartido | `#141611` | — | — |
| Metal marfil | `#EEEADD` | — | — |

El azul se tomó de los tonos predominantes del arte actual de Electric Knife. La nueva referencia de fuego es un rojo cálido, con luz coral y sombra roja oscura. Aplicar superficies amplias, pocos detalles y el grosor de contorno de las armas ranged existentes. La propuesta del chispero conserva mango con gatillo y tubo recto, orientado a la derecha en el sprite y hacia arriba a la derecha en las tarjetas. Diseño en `documentacion-local/conceptos/chispero-v1/`.

Ficha de ataque solicitada: melee de estocada a corta distancia; aplica simultáneamente fuego y electricidad. Chispero integrado al catálogo melee en cuatro tiers, con icono inclinado -35 grados.

### Soplete de cocina · propuesta de sprite

Se conserva el rojo llameante #D94A35 del chispero, con luces #F27A56 y sombras #A92E25. Silueta de soplete culinario tradicional: depósito vertical que sirve de agarre, base de apoyo, cabezal oscuro, botón posterior y boquilla metálica corta a la derecha. Propuesta de ataque: chorro de fuego de muy corto alcance, separado del arte en reposo. Arte y prompt en `documentacion-local/conceptos/soplete-v1/`. Versión aprobada v3 integrada al catálogo ranged en cuatro tiers, con icono inclinado -35 grados y chorro corto de fuego.
