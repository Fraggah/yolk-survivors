from pathlib import Path
import re
r=Path('yolk-survivors')
def edit(p,a,b):
 p=r/p;s=p.read_text(encoding='utf-8-sig');assert a in s,p;p.write_text(s.replace(a,b),encoding='utf-8')
edit(Path('scenes/units/players/player.gd'),'\t\tfor key in equipped.data.final_stat_modifiers:\n\t\t\tcombined[key] = float(combined.get(key, 0.0)) + float(equipped.data.final_stat_modifiers[key])','\t\tvar chili_factor: float = 1.0 + 0.1 * (passive_items.count("wasabi") if is_instance_valid(passive_items) and equipped.data.has_tag(ItemWeapon.Tag.CHILI) else 0)\n\t\tfor key in equipped.data.final_stat_modifiers:\n\t\t\tcombined[key] = float(combined.get(key, 0.0)) + float(equipped.data.final_stat_modifiers[key]) * chili_factor')
edit(Path('scenes/units/players/player.gd'),'equipped.data.health_drain_per_second\n','equipped.data.health_drain_per_second * chili_factor\n')
edit(Path('scenes/units/players/player.gd'),'equipped.data.max_health_drain_percent_per_second\n','equipped.data.max_health_drain_percent_per_second * chili_factor\n')
edit(Path('scenes/units/players/player.gd'),'\tvar wasabi: float = 1.0 + 0.1 * (passive_items.count("wasabi") if is_instance_valid(passive_items) else 0)\n\tfor key in combined: combined[key] *= wasabi\n','')
edit(Path('resources/unit_stats.gd'),'speed / maxf(1.0, base_speed)','speed * final_multiplier("speed") / maxf(1.0, base_speed)')
edit(Path('scenes/components/health_component.gd'),'max_health = stats.health','max_health = maxf(1.0, stats.health)')
# Correct active/pending metadata and produce an auditable list.
pending={
74:'Definir si la regeneración por nivel es retroactiva.',
76:'Definir intensidad y duración del Slow eléctrico.',
77:'Definir probabilidad del 2×1 y sus reglas de consumo.',
78:'Definir magnitudes, probabilidad de destrucción, compatibilidad y selección de objetivo.',
81:'Definir compatibilidad y comportamiento de cada tag añadido a cada arma.',
82:'Definir probabilidad, duración e intensidad del relanzamiento.',
84:'Definir porcentaje de daño por enemigo Burning.',
93:'Efecto pendiente.',94:'Efecto pendiente.',95:'Efecto pendiente.',
98:'Definir conjunto de estadísticas reducibles, tratamiento de valores negativos y reglas de retroceso/recompensas.',
99:'Definir daño/radio de explosión, magnitud/duración de buffs y parámetros de Burning/Shocked propios.',
100:'Definir duración y reactivación.'
}
rows=[];active=[]
for p in sorted((r/'resources/items/passives/catalogue').glob('*.tres')):
 s=p.read_text(encoding='utf-8');i=int(re.search(r'catalogue_id = (\d+)',s)[1]);name=__import__('json').loads(re.search(r'item_name = (.*)',s)[1])
 ready='ready_for_shop = true' in s
 reason='' if ready else pending.get(i,'Definir magnitudes numéricas de las bonificaciones y/o penalizaciones'+(' y parámetros del efecto.' if i in [44,45,46,47,58,60,63,73] else '.'))
 s=re.sub(r'pending_reason = .*','pending_reason = '+__import__('json').dumps(reason,ensure_ascii=False),s);p.write_text(s,encoding='utf-8')
 rows.append(f'| {i:03d} | {name} | '+('Implementado' if ready else reason)+' |')
 if ready:active.append(name)
(r/'docs/item_catalogue_status.md').write_text('# Catálogo de pasivos — implementación\n\n26 activos; 74 pendientes excluidos de tienda. Los 100 recursos y PNG están preparados. Los pasivos anteriores ya no aparecen en ofertas.\n\nPrecios base provisionales editables en cada .tres: común 10, raro 25, épico 50, legendario 80. Moneda de chocolate siempre cuesta 1 yema. Las copias suman salvo protecciones/eventos que no acumulan intensidad y conversión de Reducción infernal (idempotente).\n\n## Activos\n\n'+', '.join(active)+'.\n\n## Criterios iniciales\n\n- Sobrecarga y Recalentado cuentan entrada al estado, no cada refresco mientras ya está activo.\n- Carnicero amigo suma 10 puntos de descuento por copia; el coste nunca es negativo.\n- Guaraná respeta un mínimo técnico de 0,05 segundos.\n- El último escenario comprado determina el próximo escenario. La selección de depuración conserva su prioridad.\n- Batido energético usa el aumento porcentual positivo sobre la velocidad base del personaje, incluido el modificador final de velocidad.\n- Horda usa la configuración de horda existente y conserva el número de oleada.\n- Impresora solo copia comunes poseídos y activos; su contador persiste entre oleadas desde que se adquiere.\n- Gambler dispone de una apuesta de 1 yema por tienda. Moneda de chocolate ejecuta la misma apuesta al comprarla.\n\n## Estado completo\n\n| ID | Ítem | Estado |\n|---|---|---|\n'+'\n'.join(rows),encoding='utf-8')
print(', '.join(active))

