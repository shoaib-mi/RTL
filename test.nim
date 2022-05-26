import nimPDF/nimPDF, RTL, strutils, os

var 
    opts = newPDFOptions()
    home = getHomeDir()
    linespacing: float = 10
    margin_left:float = 15
    margin_top:float = 15
    font_family:string = "B Nazanin"
    font_size: float = 5
    font_style = {FS_REGULAR}
    encoding = ENC_UTF8
    text: string = """متن آزمایشی خط اول
متن آزمایشی خط دوم 
    """
    lines = text.split("\n")
    line_number: float
    line_text: string

when defined windows:
    opts.addFontsPath(r"C:\Windows\Fonts")
when defined linux:
    opts.addFontsPath(home & "/.local/share/fonts")

var doc = newPDF(opts)
doc.addPage(getSizeFromName("A4"), PGO_PORTRAIT)
doc.setFont(fontFamily, font_style, fontSize, encoding)

for i,line in lines:
    line_text = str2uni(line)
    line_number = linespacing*float(i) + margin_top
    doc.drawText(margin_left, line_number, line_text)
if not doc.writePDF(r"hello.pdf"):
    echo "cannot open: hello.pdf"
