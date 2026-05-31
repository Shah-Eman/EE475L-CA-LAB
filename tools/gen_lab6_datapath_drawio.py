#!/usr/bin/env python3
"""Generate Lab 6 single-cycle datapath draw.io matching the manual screenshot."""

from xml.sax.saxutils import escape

PAGE_W, PAGE_H = 1520, 620

def cell(cid, parent, style, value, x, y, w, h, vertex=True):
    tag = "vertex" if vertex else "edge"
    v = f' value="{escape(value)}"' if value else ""
    return (
        f'        <mxCell id="{cid}" parent="{parent}" style="{style}"{v} {tag}="1">\n'
        f'          <mxGeometry x="{x}" y="{y}" width="{w}" height="{h}" as="geometry"/>\n'
        f'        </mxCell>'
    )

def edge(cid, parent, style, points, value="", src=None, tgt=None):
    pts = ""
    if len(points) > 2:
        pts = "\n            <Array as=\"points\">\n"
        for px, py in points[1:-1]:
            pts += f'              <mxPoint x="{px}" y="{py}"/>\n'
        pts += "            </Array>"
    src_tgt = ""
    if src:
        src_tgt += f' source="{src}"'
    if tgt:
        src_tgt += f' target="{tgt}"'
    v = f' value="{escape(value)}"' if value else ""
    return (
        f'        <mxCell id="{cid}" edge="1" parent="{parent}" style="{style}"{src_tgt}{v}>\n'
        f'          <mxGeometry relative="1" as="geometry">\n'
        f'{pts}\n'
        f'            <mxPoint x="{points[0][0]}" y="{points[0][1]}" as="sourcePoint"/>\n'
        f'            <mxPoint x="{points[-1][0]}" y="{points[-1][1]}" as="targetPoint"/>\n'
        f'          </mxGeometry>\n'
        f'        </mxCell>'
    )

def label(cid, text, x, y, w=80, h=18, align="center", size=11, bold=False):
    b = ";fontStyle=1" if bold else ""
    st = (
        f"text;html=1;strokeColor=none;fillColor=none;align={align};"
        f"verticalAlign=middle;fontSize={size};fontColor=#000000{b};"
    )
    return cell(cid, "1", st, text, x, y, w, h)

def box(cid, text, x, y, w, h, fill="#ffffff", stroke="#000000", bold=True):
    b = "&lt;b&gt;" if bold else ""
    b_end = "&lt;/b&gt;" if bold else ""
    st = (
        f"rounded=0;whiteSpace=wrap;html=1;fillColor={fill};strokeColor={stroke};"
        f"strokeWidth=1;align=center;verticalAlign=middle;fontSize=12;"
    )
    return cell(cid, "1", st, f"{b}{text}{b_end}", x, y, w, h)

def mux(cid, x, y, w=36, h=64, rot=0):
    st = (
        "shape=trapezoid;perimeter=trapezoidPerimeter;whiteSpace=wrap;html=1;"
        "fixedSize=1;fillColor=#ffffff;strokeColor=#000000;strokeWidth=1;"
        f"rotation={rot};"
    )
    return cell(cid, "1", st, "", x, y, w, h)

def alu(cid, x, y):
    st = (
        "shape=trapezoid;perimeter=trapezoidPerimeter;whiteSpace=wrap;html=1;"
        "fixedSize=1;rotation=90;fillColor=#ffffff;strokeColor=#000000;strokeWidth=1;"
        "align=center;verticalAlign=middle;fontSize=12;fontStyle=1;"
    )
    return cell(cid, "1", st, "&lt;b&gt;ALU&lt;/b&gt;", x, y, 90, 110)

def arrow():
    return "endArrow=classic;html=1;rounded=0;strokeColor=#000000;strokeWidth=1;endFill=1;"

def line():
    return "endArrow=none;html=1;rounded=0;strokeColor=#000000;strokeWidth=1;"

def orth():
    return arrow() + "edgeStyle=orthogonalEdgeStyle;"

parts = []

# --- Blocks ---
parts.append(box("pc_mux", "", 58, 72, 38, 52))
parts.append(label("pc_mux_lbl", "+4", 18, 82, 36, 20, align="center", size=12))
parts.append(box("pc", "PC", 72, 168, 44, 72))
parts.append(box("inst_mem", "Inst.&#xa;Mem", 168, 152, 88, 104, fill="#d5e8d4", stroke="#82b366"))
parts.append(label("im_addr", "Addr", 148, 188, 40, 18, align="right"))
parts.append(label("im_inst", "Inst.", 258, 188, 40, 18, align="left"))

parts.append(box("reg_file", "Register&#xa;File", 392, 132, 96, 132, fill="#f5f5f5", stroke="#666666"))
parts.append(label("rf_raddr1", "raddr1", 318, 148, 56, 16, align="right"))
parts.append(label("rf_raddr2", "raddr2", 318, 178, 56, 16, align="right"))
parts.append(label("rf_waddr", "waddr", 318, 228, 56, 16, align="right"))
parts.append(label("rf_rdata1", "rdata1", 492, 148, 56, 16, align="left"))
parts.append(label("rf_rdata2", "rdata2", 492, 178, 56, 16, align="left"))
parts.append(label("rf_wdata", "wdata", 408, 278, 56, 16, align="center"))

parts.append(box("imm_gen", "Immediate&#xa;Gen.", 392, 318, 96, 58, fill="#ffffff", stroke="#000000", bold=False))
parts.append(mux("alu_src_mux", 548, 228, 34, 72))
parts.append(alu("alu", 628, 158))
parts.append(label("alu_a", "A", 612, 168, 20, 16, align="right", size=11))
parts.append(label("alu_b", "B", 612, 218, 20, 16, align="right", size=11))

parts.append(box("data_mem", "Data&#xa;Mem", 792, 152, 88, 104, fill="#d5e8d4", stroke="#82b366"))
parts.append(label("dm_addr", "addr", 772, 168, 40, 16, align="right"))
parts.append(label("dm_wdata", "wdata", 772, 228, 44, 16, align="right"))
parts.append(label("dm_rdata", "rdata", 884, 188, 44, 16, align="left"))

parts.append(mux("wb_mux", 938, 198, 34, 72))

# --- IR field labels ---
parts.append(label("ir1915", "IR [19:15]", 318, 132, 72, 16, align="right", size=10))
parts.append(label("ir2420", "IR [24:20]", 318, 162, 72, 16, align="right", size=10))
parts.append(label("ir117", "IR [11:7]", 318, 212, 64, 16, align="right", size=10))

# --- PC update loop ---
parts.append(edge("e_pc_out_im", "1", arrow(), [(116, 204), (168, 204)]))
parts.append(edge("e_pc_up", "1", line(), [(116, 168), (116, 96)]))
parts.append(edge("e_add4", "1", arrow(), [(116, 96), (58, 96)]))
parts.append(label("add4_txt", "+4", 78, 78, 28, 16, size=11))
parts.append(edge("e_mux_pc", "1", arrow(), [(96, 124), (96, 168)]))

# Inst to RF addresses and imm gen
parts.append(edge("e_inst_rf", "1", orth(), [(256, 204), (392, 204), (392, 156)]))
parts.append(edge("e_inst_imm", "1", orth(), [(256, 204), (300, 204), (300, 347), (392, 347)]))

# rdata1 -> ALU A
parts.append(edge("e_rd1_alu", "1", arrow(), [(548, 156), (628, 156)]))

# rdata2 -> alu mux top
parts.append(edge("e_rd2_mux", "1", orth(), [(548, 186), (548, 248)]))

# imm -> alu mux bottom
parts.append(edge("e_imm_mux", "1", orth(), [(488, 347), (520, 347), (520, 292), (548, 292)]))

# alu mux -> ALU B
parts.append(edge("e_mux_alub", "1", arrow(), [(582, 264), (628, 208)]))

# ALU -> Data Mem addr
parts.append(edge("e_alu_dm", "1", arrow(), [(718, 188), (792, 188)]))

# rdata2 -> Data Mem wdata
parts.append(edge("e_rd2_dm", "1", orth(), [(548, 196), (740, 196), (740, 236), (792, 236)]))

# ALU -> WB mux top
parts.append(edge("e_alu_wb", "1", orth(), [(718, 208), (860, 208), (860, 218), (938, 218)]))

# Data Mem rdata -> WB mux bottom
parts.append(edge("e_dm_wb", "1", orth(), [(880, 204), (910, 204), (910, 248), (938, 248)]))

# WB mux -> RF wdata (bottom loop)
parts.append(edge("e_wb_rf", "1", orth(), [
    (972, 234), (972, 520), (440, 520), (440, 264),
]))

xml = f"""<mxfile host="app.diagrams.net" agent="EE-475L" version="24.7.17">
  <diagram name="Single-Cycle Datapath" id="lab6-datapath">
    <mxGraphModel dx="1520" dy="620" grid="0" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="{PAGE_W}" pageHeight="{PAGE_H}" background="#ffffff" math="0" shadow="0">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
{chr(10).join(parts)}
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
"""

out = "/home/shah-eman/6th Semester/CA LAB/Lab06/docs/datapath.drawio"
with open(out, "w", encoding="utf-8") as f:
    f.write(xml)
print(f"Wrote {out}")
