from pathlib import Path
import re, json, math, unicodedata
from xml.sax.saxutils import escape
from reportlab.pdfgen import canvas
from reportlab.lib.colors import HexColor, Color
from reportlab.lib.pagesizes import A4
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import Paragraph
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.utils import ImageReader
from PIL import Image
from pypdf import PdfReader

ROOT = Path.cwd()
GAME = ROOT / 'yolk-survivors'
OUT = ROOT / 'output/pdf/yolk-survivors-catalogo-de-armas.pdf'
LABELS = ['Melee','Ranged','Explosive','Pyro','Electric','Chily','Control','Pet']

# Read the actual selection roster, then the catalogues appended at runtime.
scene = (GAME/'scenes/ui/selection_panel/selection_panel.tscn').read_text(encoding='utf-8')
resources = {b:a for a,b in re.findall(r'\[ext_resource[^\n]*path="([^"]+)" id="([^"]+)"',scene)}
roster = next(line for line in scene.splitlines() if line.startswith('weapons_list ='))
paths = [resources[key] for key in re.findall(r'ExtResource\("([^"]+)"\)',roster)[1:]]
paths.append('res://resources/items/weapons/melee/spark_lighter/item_spark_lighter_1.tres')
for category, folder in [('ranged','range'),('spicy','spicy')]:
    source = (GAME/f'resources/items/weapons/{category}_catalogue.gd').read_text(encoding='utf-8')
    ids = re.findall(r'"([a-z_]+)"', re.search(r'const IDS := \[(.*?)\]', source, re.S)[1])
    for key in ids:
        paths.append(f'res://resources/items/weapons/{folder}/{key}/item_{key}_1.tres' if folder=='range' else f'res://resources/items/weapons/spicy/item_{key}.tres')
pet_source = (GAME/'resources/items/weapons/pet_catalogue.gd').read_text(encoding='utf-8')
paths += re.findall(r'load\("(res://[^"]+\.tres)"\)',pet_source)
assert len(paths)==42 and len(set(paths))==42

DESCRIPTIONS = {
'spatula': 'Ataque cuerpo a cuerpo frontal con la espátula. Avanza hacia el objetivo y vuelve a su posición de reposo.',
'blender': 'Golpea con un batidor mediante estocadas frontales. Su movimiento alterna pequeños desplazamientos laterales durante el ataque.',
'mace': 'Ataque cuerpo a cuerpo en arco. Barre la zona frente al jugador con un palo de amasar de madera.',
'mitten': 'Un puñetazo aplica Airbourne: empuja al enemigo y lo convierte en una fuente de daño por colisión contra otros enemigos. El impacto directo es secundario.',
'butcher_knife': 'Cuchilla de cocina que realiza un barrido semicircular. Daña a los enemigos que cruza durante el movimiento.',
'the_bloody': 'Dispara cápsulas de ketchup. Al impactar, salpica gotas detrás del enemigo; esas gotas funcionan como proyectiles secundarios de recorrido corto.',
'knifer': 'Dispara un cuchillo con punta de chef. Su proyectil es perforante y puede atravesar al objetivo para continuar su recorrido.',
'corpse_l': 'Lanza un huevo frito hacia la posición del enemigo. El contacto solo empuja; al caer queda horizontal, vibra y explota. Cada disparo genera una yema extra.',
'smasher': 'Dispara un palo de amasar que atraviesa enemigos y sigue hasta salir del fondo completo del escenario. No admite rebotes, incluso si los aportan otros ítems.',
'hydrant': 'Mantiene un chorro continuo de mayonesa con daño por ticks. Se detiene en el primer objetivo, salvo que se agregue perforación, y salpica al salir y al impactar.',
'tenderizer': 'Ataque de martillo con golpes de preparación y un remate. Combina empuje durante la secuencia con un impacto final más contundente.',
'grater': 'Atrapa e inmoviliza enemigos en el rallador y los daña durante el ataque. El punto de contacto queda fijado al mundo aunque el jugador se mueva.',
'carving_fork': 'Ataque punzante hacia delante con un tenedor de trinchar. La zona de daño recorre la trayectoria de la estocada.',
'ladle': 'El cucharón barre hacia otro enemigo cercano cuando hay un objetivo secundario válido. La trayectoria permite golpear enemigos durante el recorrido.',
'frying_pan': 'Golpe de sartén con un impacto que ralentiza a los enemigos cercanos. Combina contacto cuerpo a cuerpo y control de una zona alrededor del golpe.',
'pizza_cutter': 'La rueda cortadora avanza en línea recta y daña al pasar. Regresa con una inclinación y un recorrido de vuelta diferenciado.',
'electric_knife': 'Realiza una estocada cuerpo a cuerpo y aplica Shoked. La electricidad daña y se propaga a enemigos cercanos, sin ralentizarlos.',
'immersion_blender': 'Dispara una sierra eléctrica giratoria. Al impactar aplica Shoked, con daño eléctrico y propagación cercana; ya no ralentiza.',
'spark_lighter': 'Encendedor chispero de ataque punzante corto. Aplica Burning y Shoked en el mismo impacto, combinando fuego persistente y electricidad.',
'bomb_corn': 'Pistola rápida de semillas de maíz. El grano daña y desaparece al impactar; puede explotar y lanzar un pochoclo más grande en una dirección aleatoria.',
'toothpick_shotgun': 'Escopeta de palillos. Dispara un grupo de proyectiles simultáneos en abanico para cubrir una zona frontal.',
'pressure_cooker': 'Lanza una olla horizontal que no hace daño por contacto. Al caer ralentiza en un área; después se infla, vibra y explota.',
'meatball_machinegun': 'Dispara albóndigas en ráfagas de tres. Conserva la dirección de apuntado durante cada tanda y solo busca otro objetivo en la siguiente.',
'pepper_bazooka': 'Lanza munición explosiva de pimienta. Detona al impactar o al agotarse su mecha y daña un área alrededor de la explosión.',
'anchovy_doublebarrel': 'Escopeta de doble caño que dispara dos anchoas al mismo tiempo. Ambos proyectiles salen en una misma descarga.',
'baguette_harpoon': 'Engancha a los enemigos que atraviesa y los arrastra hasta el final del recorrido o el borde de la arena. Allí se clava y los deja inmovilizados brevemente.',
'plate_launcher': 'Dispara platos que conservan su orientación horizontal. Tras cada impacto pueden romperse o rebotar; al romperse generan fragmentos de vajilla.',
'olive_launcher': 'Dispara la aceituna hacia delante y expulsa el carozo hacia atrás con una desviación aleatoria. El carozo también es un proyectil y tiene un recorrido más corto.',
'fusilli_launcher': 'Dispara pasta que aplica Airbourne y empuja al enemigo en la dirección del proyectil. El enemigo lanzado daña a otros al chocar, con menor daño que el guante.',
'kitchen_torch': 'Soplete de cocina con un chorro continuo de fuego de corta distancia. Daña al contacto y aplica Burning.',
'bell_pepper': 'Dispara semillas en direcciones aleatorias sin necesitar un objetivo. Como efecto de equipo, favorece la suerte a cambio de reducir el daño final.',
'jalapeno': 'Mantiene un aura oval de daño alrededor del jugador. Varias copias comparten el efecto y aportan su daño según la cobertura. Favorece la armadura a cambio de movilidad.',
'habanero': 'Genera explosiones sucesivas alrededor del jugador con anticipación visual e ignición de enemigos. Favorece el área de efecto a cambio de probabilidad de crítico.',
'cayenne': 'Deja una estela de fuego al moverse que daña y aplica Burning. Las copias comparten el rastro y conservan sus aportes de daño. Favorece los ticks de fuego a cambio de movilidad.',
'poblano': 'Gira alrededor del jugador y daña por contacto. Su órbita responde a la velocidad de ataque. Favorece la probabilidad de bloqueo a cambio de su efectividad.',
'carolina_reaper': 'Mantiene tornados de fuego recorriendo la arena. Dañan por la base y dejan un rastro ardiente; las copias suman tornados. Aporta daño final a cambio de consumir vida de forma continua.',
'ghost_pepper': 'Crea nubes rojizas de daño dentro de un radio del jugador. Las copias buscan posiciones separadas. Favorece la potencia de ralentización a cambio de empuje.',
'aji_amarillo': 'Dispara semillas en una espiral continua. Las copias reparten sus direcciones para cubrir distintos lados. Favorece la velocidad de ataque a cambio del multiplicador crítico.',
'scotch_bonnet': 'Planta minas de proximidad semienterradas alrededor del jugador, con explosiones rápidas. Las copias amplían la zona de aparición. Prolonga efectos a cambio de más enemigos.',
'rocoto': 'Emite una onda oval rápida que daña y empuja. Las copias de configuración equivalente comparten el efecto visual. Favorece el empuje, pero también acelera a los enemigos.',
'sausage_dog': 'Perro construido íntegramente con salchichas alemanas. Su arte está integrado y se puede seleccionar; por ahora no tiene ataques ni comportamiento de mascota.',
'toaster_cat': 'Tostadora robótica con forma de gato y expresiones en pantalla. En el panel aparece con la tostada adentro. Está integrada como arte; su ataque y cambio de estado quedan pendientes.',
}

entries=[]
for path in paths:
    content=(GAME/path.removeprefix('res://')).read_text(encoding='utf-8')
    key = Path(path).parent.name
    if key in ['spicy','pets']:
        key = Path(path).stem.removeprefix('item_')
    title=re.search(r'^item_name = "([^"]+)"',content,re.M)[1]
    title=re.sub(r' (?:IV|III|II|I)$','',title)
    if key=='corpse_l': title='Corpse Launcher'
    icon_id=re.search(r'^item_icon = ExtResource\("([^"]+)"\)',content,re.M)[1]
    exts={b:a for a,b in re.findall(r'\[ext_resource[^\n]*path="([^"]+)" id="([^"]+)"',content)}
    tags=[LABELS[int(x)] for x in re.findall(r'\d+',re.search(r'^tags = Array\[int\]\(\[(.*?)\]\)',content,re.M)[1])]
    entries.append(dict(key=key,title=title,tags=tags,description=DESCRIPTIONS[key],icon=str(GAME/exts[icon_id].removeprefix('res://')),resource=path))
entries.sort(key=lambda e:unicodedata.normalize('NFKD',e['title']).encode('ascii','ignore').decode().lower())
(ROOT/'tmp/pdfs/weapon-catalogue-source.json').write_text(json.dumps(entries,ensure_ascii=False,indent=2),encoding='utf-8')

pdfmetrics.registerFont(TTFont('Segoe','C:/Windows/Fonts/segoeui.ttf'))
pdfmetrics.registerFont(TTFont('SegoeBold','C:/Windows/Fonts/segoeuib.ttf'))
BG=HexColor('#F8F2E5'); INK=HexColor('#352F28'); GREEN=HexColor('#227557'); MUTED=HexColor('#71695D')
TAG_COLORS={'Melee':'#80613C','Ranged':'#3B6D78','Explosive':'#A76524','Pyro':'#B84231','Electric':'#476D89','Chily':'#517A35','Control':'#785E91','Pet':'#A4556C'}
W,H=A4
c=canvas.Canvas(str(OUT),pagesize=A4)
c.setTitle('Yolk Survivors | Catálogo de armas')
c.setAuthor('Yolk Survivors')
style=ParagraphStyle('body',fontName='Segoe',fontSize=10.1,leading=13.5,textColor=INK)
text_checks=[]
for page in range(7):
    c.setFillColor(BG); c.rect(0,0,W,H,fill=1,stroke=0)
    c.setFillColor(GREEN); c.rect(0,H-9,W,9,fill=1,stroke=0)
    c.setFont('SegoeBold',10);c.drawString(36,H-35,'YOLK SURVIVORS')
    c.setFillColor(INK);c.setFont('SegoeBold',23);c.drawString(36,H-64,'Catálogo de armas')
    c.setFont('Segoe',9.8);c.setFillColor(MUTED)
    c.drawString(36,H-84,'42 armas, picantes y mascotas · Características y tags · 17/10/2026')
    top=H-105
    for pos,entry in enumerate(entries[page*6:page*6+6]):
        y=top-pos*115-107
        c.setFillColor(HexColor('#FFFCF5')); c.setStrokeColor(HexColor('#E1D8C7'));c.setLineWidth(.65)
        c.roundRect(36,y,W-72,107,9,fill=1,stroke=1)
        # Trim transparent padding only for document presentation.
        img=Image.open(entry['icon']).convert('RGBA'); bbox=img.getbbox()
        if bbox: img=img.crop(bbox)
        ratio=min(69/img.width,69/img.height); iw,ih=img.width*ratio,img.height*ratio
        c.drawImage(ImageReader(img),45+(73-iw)/2,y+(107-ih)/2,width=iw,height=ih,mask='auto')
        x=130
        c.setFillColor(INK);c.setFont('SegoeBold',12.2);c.drawString(x,y+88,entry['title'])
        pill_x=x
        for tag in entry['tags']:
            color=HexColor(TAG_COLORS[tag]); tw=pdfmetrics.stringWidth(tag,'SegoeBold',8.2)+14
            c.setFillColor(Color(color.red,color.green,color.blue,alpha=.11));c.roundRect(pill_x,y+64,tw,16,5,fill=1,stroke=0)
            c.setFillColor(color);c.setFont('SegoeBold',8.2);c.drawString(pill_x+7,y+69,tag);pill_x+=tw+5
        para=Paragraph(escape(entry['description']),style)
        pw,ph=para.wrap(W-173,80)
        assert ph<=45, (entry['key'],ph)
        para.drawOn(c,x,y+55-ph)
        text_checks.append(entry['title'])
    c.setStrokeColor(HexColor('#DDD2BD'));c.line(36,37,W-36,37)
    c.setFillColor(MUTED);c.setFont('Segoe',8)
    c.drawString(36,24,'Catálogo actual del juego · Sin estadísticas ni desglose de tiers')
    c.drawRightString(W-36,24,f'{page+1} / 7')
    c.showPage()
c.save()
reader=PdfReader(str(OUT))
assert len(reader.pages)==7
text='\n'.join(page.extract_text() for page in reader.pages)
for title in text_checks: assert title in text, title
assert len(entries)==len(DESCRIPTIONS)==42
print(json.dumps({'output':str(OUT),'pages':len(reader.pages),'weapons':len(entries),'bytes':OUT.stat().st_size},ensure_ascii=False))
