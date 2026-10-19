# Catálogo de pasivos — implementación

72 activos; 28 pendientes excluidos de tienda. Los 100 recursos y PNG están preparados. Los pasivos anteriores ya no aparecen en ofertas.

Precios base provisionales editables en cada .tres: común 10, raro 25, épico 50, legendario 80. Moneda de chocolate siempre cuesta 1 yema. Las copias suman salvo protecciones/eventos que no acumulan intensidad y conversión de Reducción infernal (idempotente).

## Activos

Doble yema, Moneda de chocolate, Carnicero amigo, Cocina eléctrica, Wasabi, Cáscara extra, Huevo frito, Papas fritas, Pizza casera, Chop suey, Engrudo, Cáscara resbaladiza, Chispa, Brazo auxiliar, Vianda, Diente libre, Guaraná, Delantal negro, Impresora de comida, Sobrecarga, Recalentado, Batido energético, Golpe de mesa, Bolsa de mercadería, Refrito, Reducción infernal.

## Criterios iniciales

- Sobrecarga y Recalentado cuentan entrada al estado, no cada refresco mientras ya está activo.
- Carnicero amigo suma 10 puntos de descuento por copia; el coste nunca es negativo.
- Guaraná respeta un mínimo técnico de 0,05 segundos.
- El último escenario comprado determina el próximo escenario. La selección de depuración conserva su prioridad.
- Batido energético usa el aumento porcentual positivo sobre la velocidad base del personaje, incluido el modificador final de velocidad.
- Horda usa la configuración de horda existente y conserva el número de oleada.
- Impresora solo copia comunes poseídos y activos; su contador persiste entre oleadas desde que se adquiere.
- Gambler dispone de una apuesta de 1 yema por tienda. Moneda de chocolate ejecuta la misma apuesta al comprarla.

## Estado completo

| ID | Ítem | Estado |
|---|---|---|
| 001 | Pimentón | Implementado: +2% robo de vida; −1 regeneración por copia. |
| 002 | Comino | Implementado: +3 de vida máxima por copia. |
| 003 | Orégano | Implementado: +3 de Efectos por copia; sin escalado de control. |
| 004 | Canela | Implementado: +10% experiencia y −2 suerte por copia. Se conservan fracciones de XP. |
| 005 | Hoja de laurel | Implementado: +5% de experiencia por copia. |
| 006 | Cúrcuma | Implementado: +2 de daño a distancia y −1 de daño melee por copia. |
| 007 | Romero | Implementado: +15 empuje plano y −3% velocidad de ataque por copia. |
| 008 | Azafrán | Implementado: +5% velocidad de ataque por copia. |
| 009 | Sal fina | Implementado: +3 suerte y −5% área de efecto por copia. |
| 010 | Levadura | Implementado: +5% área de efecto por copia. |
| 011 | Azúcar | Implementado: +8% velocidad de ataque y −2 daño melee por copia. |
| 012 | Calcio | Implementado: +1 armadura por copia. |
| 013 | Doble yema | Implementado |
| 014 | Cacao amargo | Implementado: +3 puntos de bloqueo por copia. Tope efectivo global 70%. |
| 015 | Vinagre | Implementado: +5 puntos porcentuales de poder de bloqueo y −2 vida máxima por copia. |
| 016 | Aceite de oliva | Implementado: +8% velocidad de ataque y −3% daño general por copia. |
| 017 | Grano de mostaza | Implementado: +10 suerte por copia. |
| 018 | Sellado al vacío | Implementado: +15% alcance de recolección por copia. |
| 019 | Comida miniatura | Implementado: +25 alcance plano y −10% área por copia. |
| 020 | Crema cortada | Implementado: −3 vida máxima y +5 Efectos por copia. |
| 021 | Jugo de limón | Implementado: +10 puntos de crítico y −5% daño general por copia. |
| 022 | Diente de ajo | Implementado: +5 vida máxima por copia. |
| 023 | Manteca derretida | Implementado: +15 velocidad y −5% Control de masas por copia. |
| 024 | Queso untable | Implementado: +5 puntos de bloqueo y −5 velocidad por copia. |
| 025 | Tomate cherry | Implementado: −3 armadura y +5 puntos porcentuales de poder de bloqueo por copia. |
| 026 | Miel espesa | Implementado: +10% potencia Slow por copia, independiente de Rooted y Airbourne. |
| 027 | Cocción acelerada | Implementado: +10% experiencia por copia. |
| 028 | Bicarbonato | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 029 | Lengua mordida | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 030 | Cubiertos lujosos | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 031 | Brotes | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 032 | Lata de atún | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 033 | Masa madre | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 034 | Moneda de chocolate | Implementado |
| 035 | Leche entera | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 036 | Café doble | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 037 | Cuchara sopera | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 038 | Provenzal | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 039 | Nuez moscada | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 040 | Pimienta | Implementado: habilita críticos de Chilis; los ticks de Burning no pueden hacer críticos. |
| 041 | Vitamina A | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 042 | Carnicero amigo | Implementado |
| 043 | Arroz coreano | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 044 | Alcohol | Implementado: 2 puntos porcentuales Burning por copia, −3 vida; duración 3 s. Fuego = max(0,1; Efectos × 0,25), intervalo base 0,5 s. Registro por arma. |
| 045 | Salpicadura caliente | Implementado: 5% por copia; una tirada al entrar en Burning, radio 80 unidades de mundo, un vecino por salto, encadenable. −3 puntos de bloqueo. |
| 046 | Complejo B | Implementado: 5% por copia de curar 0,1 por yema realmente recogida, incluyendo bonus de reserva. Una tirada por yema, sin sobrecuración. |
| 047 | Imán amarillo | Implementado: 5% por copia; única tirada al aparecer cada yema física y atracción desde cualquier distancia. |
| 048 | Brochette | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 049 | Curry violento | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 050 | Chimichurri | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 051 | Champiñón raro | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 052 | Pelo en la comida | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 053 | Olor rico | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 054 | Espinacas | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 055 | Brasa de ébano | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 056 | Baño de aceite | Implementado: −0,05 s entre ticks y −0,1 s duración por copia. Máximo 5; excluido de ofertas al alcanzar el límite. |
| 057 | Cocina eléctrica | Implementado |
| 058 | Cocción lenta | Implementado: +25% daño por copia contra Slow/Rooted/Airbourne; una sola bonificación aunque coexistan estados. |
| 059 | Semillas de chili | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 060 | Pancake | Implementado: +25% daño de colisiones Airbourne por copia, sin aumentar el golpe inicial. |
| 061 | Wasabi | Implementado |
| 062 | Cáscara extra | Implementado |
| 063 | Salteado feroz | Implementado: explosión física por colisión Airbourne, radio base 60, 50% daño de colisión por copia. Sin explosiones recursivas; conserva registro del arma. |
| 064 | Huevo frito | Implementado |
| 065 | Papas fritas | Implementado |
| 066 | Pizza casera | Implementado |
| 067 | Chop suey | Implementado |
| 068 | Gorro de chef | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 069 | Engrudo | Implementado |
| 070 | Guantes de goma | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 071 | Masa elástica | Definir magnitudes numéricas de las bonificaciones y/o penalizaciones. |
| 072 | Cáscara resbaladiza | Implementado |
| 073 | Guante térmico | Implementado: +1 regeneración por copia mientras Burning; bonus temporal visible en la estadística, retirado al terminar. |
| 074 | Huevo añejo | Implementado: +1 regeneración permanente por copia por nivel posterior a la compra, sin retroactividad. |
| 075 | Chispa | Implementado |
| 076 | Imán de heladera | Implementado: electricidad propia aplica Slow 20%/1 s, también en secundarios; refresca sin sumar intensidad. Copias idénticas no suman potencia ni duración. Escala con CC. |
| 077 | Liquidación | Implementado: único; una oferta ponderada (10–30%: 50%; 31–50%: 28%; 51–70%: 14%; 71–90%: 6%) o 2×1 (2% configurable), sin combinar descuentos. Bloquear conserva oferta al refrescar; salir la elimina. 2×1 respeta capacidad y límites de copias. |
| 078 | Yema de oro | Implementado: contador almacenable, confirmación y selección; 25% rotura, 40% +10%, 23% +25%, 10% +50%, 2% perfecto. Beneficios aumentan y penalizaciones disminuyen. Una copia; únicos rotos vuelven al catálogo. Shader gradual en slot y arma, destellos perfectos. |
| 079 | Brazo auxiliar | Implementado |
| 080 | Vianda | Implementado |
| 081 | Rebozado | Implementado: consumible almacenable, selección de arma y tag nueva aleatoria compatible. Escalado adicional Melee/Ranged 25%; Chili/Pet +10% por cada equipada incluyéndose. Pyro/Electric 10%; explosión radio 40/25% golpe; Slow 20%/1s. Sin bonus global por compartir tag. |
| 082 | Giro de tortilla | Implementado: 10% por copia al aterrizar; 75% fuerza y 50% duración anteriores, hasta dos relanzamientos. Segundo: 56,25% fuerza y 25% duración originales. Reutiliza daño/registro sin multiplicar CC, resistencia o Pancake. |
| 083 | Diente libre | Implementado |
| 084 | Flambeado | Implementado: +10% daño general por enemigo Burning vivo y por copia, sin límite. Bono temporal visible en stats, cada enemigo cuenta una vez aunque tenga varias fuentes; actualización por eventos sin escanear enemigos cada frame. |
| 085 | Guaraná | Implementado |
| 086 | Delantal negro | Implementado |
| 087 | Impresora de comida | Implementado |
| 088 | Sobrecarga | Implementado |
| 089 | Recalentado | Implementado |
| 090 | Batido energético | Implementado |
| 091 | Golpe de mesa | Implementado |
| 092 | Bolsa de mercadería | Implementado |
| 093 | Receta de la abuela | Efecto pendiente. |
| 094 | Ingrediente secreto | Efecto pendiente. |
| 095 | Caramelizado | Efecto pendiente. |
| 096 | Refrito | Implementado |
| 097 | Reducción infernal | Implementado |
| 098 | Ayahuasca | Implementado: cuatro resultados de 25%; retrocede 1/2 oleadas preservando progreso/ofertas, mínimo próxima oleada 1; otorga 10 niveles reales con elecciones antes de combatir; reduce a la mitad una primaria positiva, respetando valores visibles, conversiones y modificadores. Consumible inmediato. |
| 099 | Hongo desconocido | Implementado. Ver unknown_mushroom.md. |
| 100 | Último bocado | Implementado: activo bajo 25% de vida, +50% empuje y mitad de cooldown del dash. |

## Archivos

Recursos editables: resources/items/passives/catalogue/item_NNN.tres. El índice ACTIVE_IDS en resources/items/passives/catalogue.gd contiene los efectos activos; se añade cada ID al terminar su implementación. La lógica por partida vive en scenes/units/players/passive_items.gd. No se cargan texturas de ítems pendientes al armar las ofertas.

## Validación

Pruebas específicas de catálogo y compras completas, generación de 1000 ofertas y estados de combate. La prueba anterior verify_shop_economy.gd conserva una tabla de armas antigua que no incluye spark_lighter; se detiene allí y queda pendiente actualizar ese inventario de prueba.


