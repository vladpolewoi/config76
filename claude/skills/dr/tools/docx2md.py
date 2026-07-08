#!/usr/bin/env python3
"""Convert a .docx to readable markdown, walking body in document order
(paragraphs + tables interleaved). Used by the DR-analysis flow."""
import sys, os
from docx import Document
from docx.oxml.ns import qn

def iter_block_items(doc):
    body = doc.element.body
    from docx.text.paragraph import Paragraph
    from docx.table import Table
    for child in body.iterchildren():
        if child.tag == qn('w:p'):
            yield Paragraph(child, doc)
        elif child.tag == qn('w:tbl'):
            yield Table(child, doc)

def para_md(p):
    t = p.text.rstrip()
    if not t.strip():
        return ""
    style = (p.style.name or "").lower()
    # numbering / bullets
    numpr = p._p.find(qn('w:pPr'))
    is_list = False
    if numpr is not None and numpr.find(qn('w:numPr')) is not None:
        is_list = True
    if style.startswith("heading"):
        lvl = ''.join(ch for ch in style if ch.isdigit()) or "1"
        return f"{'#'*min(int(lvl)+1,6)} {t}"
    if "title" in style:
        return f"# {t}"
    if is_list or style.startswith("list"):
        return f"- {t}"
    return t

def table_md(tbl):
    rows = []
    for r in tbl.rows:
        cells = [c.text.strip().replace("\n", "<br>") for c in r.cells]
        rows.append(cells)
    if not rows:
        return ""
    out = []
    header = rows[0]
    out.append("| " + " | ".join(header) + " |")
    out.append("| " + " | ".join("---" for _ in header) + " |")
    for r in rows[1:]:
        # pad
        while len(r) < len(header): r.append("")
        out.append("| " + " | ".join(r) + " |")
    return "\n".join(out)

def convert(path):
    doc = Document(path)
    from docx.table import Table
    from docx.text.paragraph import Paragraph
    out = []
    for blk in iter_block_items(doc):
        if isinstance(blk, Paragraph):
            md = para_md(blk)
            if md: out.append(md)
        elif isinstance(blk, Table):
            out.append("")
            out.append(table_md(blk))
            out.append("")
    return "\n\n".join(out)

if __name__ == "__main__":
    src, dst = sys.argv[1], sys.argv[2]
    md = convert(src)
    with open(dst, "w") as f:
        f.write(md)
    print(f"{os.path.basename(src)} -> {dst}  ({len(md)} chars)")
