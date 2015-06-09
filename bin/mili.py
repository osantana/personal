from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm

from reportlab.pdfgen import canvas

c = canvas.Canvas("mili.pdf", pagesize=A4, pageCompression=1)
c.translate(mm, mm)
c.setStrokeColorRGB(0.9, 0.9, 0.9)
c.setLineWidth(0.3)
margin = 10*mm
for i in range(0, 195, 5):
    c.line(margin + i*mm, margin, margin + i*mm, 290*mm)
for i in range(0, 285, 5):
    c.line(margin, margin + i*mm, 200*mm, margin + i*mm)
c.showPage()
c.save()
