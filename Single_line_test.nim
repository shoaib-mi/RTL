import nimPDF/nimPDF, RTL, os

var opts = newPDFOptions()
when defined windows:
    opts.addFontsPath(r"C:\Windows\Fonts")
when defined linux:
    var home = getHomeDir()    
    opts.addFontsPath(home & "/.local/share/fonts")

var doc = newPDF(opts)
doc.addPage(getSizeFromName("A4"), PGO_PORTRAIT)
doc.setFont("B Nazanin", {FS_REGULAR}, 5, ENC_UTF8)

var line: string
line = str2uni("متن آزمایشی")
doc.drawText(15, 50, line)
if not doc.writePDF(r"hello.pdf"):
    echo "cannot open: hello.pdf"
