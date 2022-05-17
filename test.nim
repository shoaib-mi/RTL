import nimPDF/nimPDF, RTL
var opts = newPDFOptions()
opts.addFontsPath(r"C:\Windows\Fonts")
var doc = newPDF(opts)
doc.addPage(getSizeFromName("A4"), PGO_PORTRAIT)
doc.setFont("B Nazanin", {FS_REGULAR}, 5, ENC_UTF8)

var line: string
line = "متن آزمایشی"
doc.drawText(15, 50, str2uni(line))
if not doc.writePDF(r"hello.pdf"):
    echo "cannot open: hello.pdf"
