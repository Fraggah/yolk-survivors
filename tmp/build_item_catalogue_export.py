from pathlib import Path
from io import BytesIO
import re, json, shutil, unicodedata, math
from xml.sax.saxutils import escape
from reportlab.pdfgen import canvas
from reportlab.lib.colors import HexColor
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import Paragraph
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.pagesizes import A4
from pypdf import PdfReader
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
PROJECT = ROOT / 'yolk-survivors'
OUT = ROOT / 'output'
PDF = OUT / 'pdf/catalogo-items-yolk-survivors.pdf'
STAGE = ROOT / 'tmp/items-sprites-export/sprites-items'
PDF.parent.mkdir(parents=True, exist_ok=True)
STAGE.mkdir(parents=True, exist_ok=True)
items = []
for i in range(1,101):
    text = (PROJECT / f'resources/items/passives/catalogue/item_{i:03}.tres').read_text(encoding='utf-8')
    def quoted(key):
        match = re.search(r'^'+key+r' = "(.*)"$', text, re.M)
        return match.group(1) if match else ''
    name, desc = quoted('item_name'), quoted('description')
    active = 'ready_for_shop = true' in text
    if not active:
        if desc == 'EFECTO PENDIENTE':
            desc = 'Efecto: X (pendiente de definir).'
        else:
            # Insert X only where a signed stat has no numerical magnitude.
            desc = re.sub(r'([+−])(?=[A-Za-zÁÉÍÓÚáéíóúÑñ])', r'\1X de ', desc)
    desc = desc.replace('–','-').replace('—','-').replace('Airborne','Airbourne')
    tier = int(re.search(r'^item_tier = (\d+)', text, re.M).group(1))
    source = PROJECT / f'assets/sprites/Items/Catalogue/{i:03}.png'
    assert source.exists()
    with Image.open(source) as image:
        assert image.width > 0 and image.height > 0
    slug = unicodedata.normalize('NFKD', name).encode('ascii','ignore').decode().lower()
    slug = re.sub(r'[^a-z0-9]+','-',slug).strip('-')
    target = STAGE / f'{i:03}-{slug}.png'
    shutil.copy2(source, target)
    items.append(dict(id=i,name=name,description=desc,tier=tier,active=active,sprite=str(source),file=target.name))

# Clarify current mechanics that are more detailed than the short shop descriptions.
extra = {
  77: 'El 2x1 tiene 2% de probabilidad y no puede aplicarse a únicos.',
  99: 'Burning y los tres buffs duran 4 s; el fuego hace un tick cada 0,5 s. En oleadas de 30 s se activa en 5, 10, 15, 20 y 25 s.',
}
for item in items:
    if item['id'] in extra: item['description'] += ' ' + extra[item['id']]

(STAGE / 'indice.txt').write_text('YOLK SURVIVORS - SPRITES DE LOS 100 ITEMS\nPNG originales, sin reescalado.\nNumeración del catálogo.\n\n'+'\n'.join(f"{i['file']} | {i['name']}" for i in items)+'\n',encoding='utf-8')
(ROOT / 'tmp/items-export-manifest.json').write_text(json.dumps(items,ensure_ascii=False,indent=2),encoding='utf-8')
pdfmetrics.registerFont(TTFont('Segoe','C:/Windows/Fonts/segoeui.ttf'))
pdfmetrics.registerFont(TTFont('SegoeBold','C:/Windows/Fonts/segoeuib.ttf'))
W,H=A4
INK=HexColor('#3e3026'); GREEN=HexColor('#227651'); MUTED=HexColor('#786b5b')
RARITIES=['COMÚN','RARO','ÉPICO','LEGENDARIO']
COLORS=['#227651','#5a6c85','#985ca2','#b47a22']
style=ParagraphStyle('body',fontName='Segoe',fontSize=10.1,leading=13.5,textColor=INK)
c=canvas.Canvas(str(PDF),pagesize=A4)
c.setTitle('Yolk Survivors - Catálogo completo de ítems')
c.setAuthor('Yolk Survivors')
c.setSubject('100 ítems, sprites y descripciones. Valores no definidos indicados con X.')
page_count=20
for page in range(page_count):
    c.setFillColor(HexColor('#f6eedc'));c.rect(0,0,W,H,fill=1,stroke=0)
    c.setFillColor(GREEN);c.setFont('SegoeBold',10);c.drawString(34,H-32,'YOLK SURVIVORS')
    c.setFillColor(INK);c.setFont('SegoeBold',23);c.drawString(34,H-62,'Catálogo de ítems')
    c.setFillColor(MUTED);c.setFont('Segoe',9)
    c.drawString(34,H-80,'100 ítems | X = valor o efecto por definir | Catálogo al 18/10/2026')
    for row,item in enumerate(items[page*5:page*5+5]):
        top=H-103-row*139
        bottom=top-131
        c.setFillColor(HexColor('#fffaf0'));c.roundRect(30,bottom,W-60,131,10,fill=1,stroke=0)
        color=HexColor(COLORS[item['tier']]);c.setFillColor(color);c.roundRect(30,bottom,4,131,2,fill=1,stroke=0)
        c.setFont('SegoeBold',8);c.drawString(44,top-18,f"{item['id']:03}")
        c.setFillColor(MUTED);c.setFont('Segoe',7.2)
        c.drawString(74,top-18,RARITIES[item['tier']]+('  |  POR DEFINIR' if not item['active'] else ''))
        c.setFillColor(INK);c.setFont('SegoeBold',13)
        c.drawString(143,top-39,item['name'])
        with Image.open(item['sprite']) as original:
            icon=original.convert('RGBA')
            icon.thumbnail((320,320),Image.Resampling.LANCZOS)
            image_data=BytesIO()
            icon.save(image_data,format='PNG')
            image_data.seek(0)
            c.drawImage(ImageReader(image_data),43,bottom+24,width=86,height=86,mask='auto',preserveAspectRatio=True,anchor='c')
        p=Paragraph(escape(item['description']),style)
        pw,ph=p.wrap(W-190,1000)
        available=82
        if ph>available:
            smaller=ParagraphStyle('smaller',parent=style,fontSize=9.1,leading=11.8)
            p=Paragraph(escape(item['description']),smaller);pw,ph=p.wrap(W-190,1000)
        assert ph<=available,(item['id'],ph)
        p.drawOn(c,143,top-47-ph)
    c.setFillColor(MUTED);c.setFont('Segoe',8)
    c.drawString(34,24,'Sprites originales del catálogo. Incluye ítems aún no habilitados en tienda.')
    c.drawRightString(W-34,24,f'{page+1} / {page_count}')
    c.showPage()
c.save()
reader=PdfReader(PDF)
assert len(reader.pages)==20
extracted='\n'.join(page.extract_text() for page in reader.pages)
for item in items:
    assert item['name'] in extracted,item['name']
assert len(list(STAGE.glob('*.png')))==100
print(f'PDF: {PDF}\nPages: {len(reader.pages)}; all 100 names verified\nSprites: {STAGE}')
