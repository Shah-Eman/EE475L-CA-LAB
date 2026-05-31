#!/usr/bin/env python3
"""Generate draw.io diagrams for EE-475L Labs 5, 6, and 7."""

import html
import uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

S = {
    "block_blue": "rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;fontStyle=1;verticalAlign=middle;align=center;fontSize=12;",
    "block_green": "shape=trapezoid;perimeter=trapezoidPerimeter;whiteSpace=wrap;html=1;fixedSize=1;rotation=90;fillColor=#d5e8d4;strokeColor=#82b366;fontStyle=1;fontSize=12;",
    "block_yellow": "rounded=1;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;fontStyle=1;verticalAlign=middle;align=center;fontSize=12;",
    "block_purple": "rounded=1;whiteSpace=wrap;html=1;fillColor=#e1d5e7;strokeColor=#9673a6;fontStyle=1;verticalAlign=middle;align=center;fontSize=12;",
    "block_orange": "rounded=1;whiteSpace=wrap;html=1;fillColor=#ffe6cc;strokeColor=#d79b00;fontStyle=1;verticalAlign=middle;align=center;fontSize=12;",
    "mux": "rhombus;whiteSpace=wrap;html=1;fillColor=#f5f5f5;strokeColor=#666666;fontSize=10;",
    "pc": "rounded=1;whiteSpace=wrap;html=1;fillColor=#f8cecc;strokeColor=#b85450;fontStyle=1;fontSize=12;",
    "title": "text;html=1;strokeColor=none;fillColor=none;align=left;verticalAlign=middle;fontSize=20;fontStyle=1;",
    "subtitle": "text;html=1;strokeColor=none;fillColor=none;align=left;verticalAlign=middle;fontSize=12;fontColor=#666666;",
    "field": "rounded=0;whiteSpace=wrap;html=1;fillColor=#fafafa;strokeColor=#999999;fontSize=11;align=left;spacingLeft=8;spacingTop=4;",
    "legend": "rounded=1;whiteSpace=wrap;html=1;fillColor=#f5f5f5;strokeColor=#999999;fontSize=11;align=left;spacingLeft=8;dashed=1;",
    "edge": "endArrow=classic;html=1;rounded=0;strokeWidth=1;strokeColor=#333333;fontSize=10;",
    "edge_ctrl": "endArrow=classic;html=1;rounded=0;strokeWidth=1;strokeColor=#9673a6;dashed=1;fontSize=10;",
    "edge_data": "endArrow=classic;html=1;rounded=0;strokeWidth=2;strokeColor=#0066CC;fontSize=10;",
}


class D:
    def __init__(self, name: str):
        self.name = name
        self.cells: list[str] = []
        self._n = 2

    def id(self) -> str:
        n = self._n
        self._n += 1
        return str(n)

    def v(self, x, y, w, h, text, sk, parent="1") -> str:
        i = self.id()
        t = html.escape(text).replace("\n", "&#xa;")
        self.cells.append(
            f'        <mxCell id="{i}" parent="{parent}" style="{S[sk]}" value="{t}" vertex="1">\n'
            f'          <mxGeometry x="{x}" y="{y}" width="{w}" height="{h}" as="geometry"/>\n'
            f"        </mxCell>"
        )
        return i

    def e(self, x1, y1, x2, y2, label="", sk="edge", src=None, tgt=None):
        i = self.id()
        lbl = html.escape(label)
        sa = f' source="{src}"' if src else ""
        ta = f' target="{tgt}"' if tgt else ""
        self.cells.append(
            f'        <mxCell id="{i}" edge="1" parent="1" style="{S[sk]}" value="{lbl}"{sa}{ta}>\n'
            f'          <mxGeometry relative="1" as="geometry">\n'
            f'            <mxPoint x="{x1}" y="{y1}" as="sourcePoint"/>\n'
            f'            <mxPoint x="{x2}" y="{y2}" as="targetPoint"/>\n'
            f"          </mxGeometry>\n"
            f"        </mxCell>"
        )

    def link(self, src, tgt, label="", sk="edge"):
        i = self.id()
        lbl = html.escape(label)
        self.cells.append(
            f'        <mxCell id="{i}" edge="1" parent="1" source="{src}" target="{tgt}" '
            f'style="{S[sk]}" value="{lbl}">\n'
            f'          <mxGeometry relative="1" as="geometry"/>\n'
            f"        </mxCell>"
        )

    def xml(self) -> str:
        body = "\n".join(self.cells)
        return f"""  <diagram name="{html.escape(self.name)}" id="{uuid.uuid4().hex[:12]}">
    <mxGraphModel dx="1600" dy="900" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1600" pageHeight="1100" background="#ffffff">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
{body}
      </root>
    </mxGraphModel>
  </diagram>"""


def mxfile(pages: list[str]) -> str:
    return "<mxfile host=\"app.diagrams.net\" agent=\"EE-475L\" version=\"24.7.17\">\n" + "\n".join(pages) + "\n</mxfile>\n"


def lab5() -> str:
    d = D("Immediate Generator")
    d.v(40, 24, 520, 32, "Lab 5 — Immediate Generator", "title")
    d.v(40, 58, 900, 22, "Module: imm_gen  ·  Input: instr_word [31:0]  ·  Output: imm_out [31:0]  ·  Combinational", "subtitle")

    # Main flow (top)
    ins = d.v(80, 130, 120, 56, "instr_word\n[31:0]", "block_blue")
    dec = d.v(280, 130, 150, 56, "Opcode\nDecoder\ninstr[6:0]", "block_purple")
    asm = d.v(500, 118, 180, 80, "Immediate Field\nExtract &\nSign-Extend", "block_orange")
    out = d.v(760, 130, 120, 56, "imm_out\n[31:0]", "block_green")
    d.link(ins, dec, "instr[6:0]", "edge_data")
    d.link(dec, asm, "format", "edge_ctrl")
    d.link(asm, out, "32-bit", "edge_data")

    # Format table
    d.v(80, 240, 800, 28, "Immediate Encoding by Instruction Format (RISC-V RV32I)", "subtitle")
    rows = [
        ("I-Type / Load / JALR", "OPC: 0010011, 0000011, 1100111", "{{20{inst[31]}}, inst[31:20]}"),
        ("S-Type (sw)", "OPC: 0100011", "{{20{inst[31]}}, inst[31:25], inst[11:7]}"),
        ("B-Type (beq/bne)", "OPC: 1100011", "{{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}"),
        ("U-Type (lui / auipc)", "OPC: 0110111, 0010111", "{inst[31:12], 12'b0}"),
        ("J-Type (jal)", "OPC: 1101111", "{{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}"),
    ]
    y = 280
    for fmt, opc, formula in rows:
        d.v(80, y, 200, 48, fmt, "block_blue")
        d.v(300, y, 220, 48, opc, "field")
        d.v(540, y, 340, 48, formula, "field")
        d.e(280, y + 24, 300, y + 24)
        d.e(520, y + 24, 540, y + 24)
        y += 58

    d.v(920, 280, 260, 200,
        "Block Diagram Summary\n\n"
        "┌─────────────────┐\n"
        "│   instr_word    │──► Decode by opcode\n"
        "│     [31:0]      │         │\n"
        "└─────────────────┘         ▼\n"
        "                    Assemble + sign-extend\n"
        "                            │\n"
        "                            ▼\n"
        "                    ┌─────────────┐\n"
        "                    │   imm_out   │\n"
        "                    │   [31:0]    │\n"
        "                    └─────────────┘",
        "legend")

    d.v(80, 580, 700, 22, "RTL: Lab05/rtl/imm_gen.sv  ·  Uses opcode.vh macros for format decode", "subtitle")
    return mxfile([d.xml()])


def draw_cpu(d: D, ctrl_note: str, flow_note: str, branch_pc: bool):
    """Classic left-to-right single-cycle datapath skeleton."""
    d.v(40, 90, 520, 22, ctrl_note, "subtitle")

    # Fetch
    pc = d.v(60, 180, 90, 48, "PC\n[31:0]", "pc")
    imem = d.v(200, 172, 120, 64, "Instruction\nMemory\nInst_Mem", "block_yellow")
    d.link(pc, imem, "pc_curr", "edge_data")

    # Decode / control column
    mc = d.v(380, 100, 130, 64, "Main\nController", "block_purple")
    ac = d.v(380, 190, 130, 52, "ALU\nController", "block_purple")
    ig = d.v(380, 270, 130, 52, "ImmGen\nimm_gen", "block_orange")

    # Execute
    rf = d.v(560, 160, 140, 90, "Register File\nReg_file\nRegisters[31:0]", "block_blue")
    muxb = d.v(740, 290, 56, 56, "B", "mux")
    alu = d.v(840, 175, 90, 90, "ALU", "block_green")
    muxwb = d.v(980, 290, 56, 56, "WB", "mux")
    dmem = d.v(1100, 172, 120, 64, "Data Memory\nData_Mem", "block_yellow")

    # Data paths
    d.link(imem, rf, "rs1/rs2/rd", "edge_data")
    d.link(rf, alu, "rd_data1", "edge_data")
    d.link(rf, muxb, "rd_data2", "edge_data")
    d.link(ig, muxb, "imm_val", "edge_data")
    d.link(muxb, alu, "src_b", "edge_data")
    d.link(alu, dmem, "address", "edge_data")
    d.link(alu, muxwb, "alu_out", "edge_data")
    d.link(dmem, muxwb, "rd_data", "edge_data")
    d.link(muxwb, rf, "wb_data", "edge_data")

    # Control
    d.link(imem, mc, "opcode", "edge_ctrl")
    d.link(imem, ac, "funct3/7", "edge_ctrl")
    d.link(mc, ac, "alu_op", "edge_ctrl")
    d.e(510, 132, 560, 190, "ctrl", "edge_ctrl")
    d.e(510, 296, 740, 318, "imm_sel", "edge_ctrl")
    d.e(1036, 318, 630, 230, "result_mux", "edge_ctrl")

    if branch_pc:
        pcmux = d.v(200, 290, 64, 56, "PC", "mux")
        d.link(pcmux, pc, "next_pc", "edge_data")
        d.e(150, 204, 232, 318, "PC+4", "edge_dash" if "edge_dash" in S else "edge_ctrl")
        d.link(ig, pcmux, "offset", "edge_ctrl")
        d.v(60, 360, 220, 50, "Branch/Jump PC update\nPC ← PC+imm  or  PC+4", "field")
    else:
        d.e(150, 204, 105, 204, "PC+4", "edge_ctrl")
        d.v(60, 260, 160, 40, "PC ← PC + 4\n(reset = 0x0)", "field")

    d.v(560, 400, 620, 130, flow_note, "field")
    return pc, rf, alu


def lab6() -> str:
    pages = []

    d = D("R-Type Datapath")
    d.v(40, 24, 480, 32, "Lab 6 — R-Type Instruction Datapath", "title")
    draw_cpu(d,
             "Instructions: ADD, SUB, AND, OR, XOR, SLL, SRL",
             "Control: imm_sel=0 · result_mux=00 (ALU) · reg_wr=1 · mem_wr=0 · alu_op=10\n"
             "Flow: rs1, rs2 → ALU → rd  |  ALU operand B selected from register (not immediate)",
             False)
    pages.append(d.xml())

    d = D("I-Type Arithmetic")
    d.v(40, 24, 520, 32, "Lab 6 — I-Type Arithmetic Datapath", "title")
    draw_cpu(d,
             "Instructions: ADDI, XORI, ORI, ANDI, SLLI, SRLI",
             "Control: imm_sel=1 · result_mux=00 (ALU) · reg_wr=1 · mem_wr=0 · alu_op=11\n"
             "Flow: rs1 + immediate → ALU → rd  |  ImmGen supplies sign-extended imm[11:0]",
             False)
    pages.append(d.xml())

    d = D("Load Word (LW)")
    d.v(40, 24, 480, 32, "Lab 6 — Load Word (LW) Datapath", "title")
    draw_cpu(d,
             "Instruction: LW  —  Memory read after address calculation",
             "Control: imm_sel=1 · result_mux=01 (Memory) · reg_wr=1 · mem_wr=0 · alu_op=00 (ADD addr)\n"
             "Flow: rs1 + offset → ALU (address) → Data_Mem read → rd",
             False)
    pages.append(d.xml())

    return mxfile(pages)


def lab7() -> str:
    pages = []

    d = D("S-Type (SW)")
    d.v(40, 24, 480, 32, "Lab 7 — S-Type Store (SW) Datapath", "title")
    draw_cpu(d,
             "Instruction: SW  —  Store rs2 to memory at rs1 + offset",
             "Control: imm_sel=1 · mem_wr=1 · reg_wr=0 · alu_op=00\n"
             "Flow: rs1+imm → ALU (address) · rs2 → Data_Mem.write_data",
             False)
    pages.append(d.xml())

    d = D("B-Type (BEQ/BNE)")
    d.v(40, 24, 520, 32, "Lab 7 — Branch Datapath (BEQ / BNE)", "title")
    draw_cpu(d,
             "Instructions: BEQ, BNE  —  Conditional PC update",
             "Control: imm_sel=0 · alu_op=01 (SUB) · is_branch=1 · zero flag decides taken\n"
             "BEQ: taken if (rs1−rs2)=0 · BNE: taken if (rs1−rs2)≠0 · Target: PC + imm",
             True)
    pages.append(d.xml())

    d = D("J-Type (JAL)")
    d.v(40, 24, 480, 32, "Lab 7 — Jump And Link (JAL) Datapath", "title")
    draw_cpu(d,
             "Instruction: JAL  —  Unconditional jump, link PC+4 to rd",
             "Control: is_jump=1 · result_mux=10 (PC+4) · reg_wr=1\n"
             "PC ← PC + imm · rd ← PC + 4 · PC reset = 0x1000_0000 for testbench",
             True)
    pages.append(d.xml())

    d = D("U-Type (LUI)")
    d.v(40, 24, 480, 32, "Lab 7 — Load Upper Immediate (LUI)", "title")
    draw_cpu(d,
             "Instruction: LUI  —  Load upper 20 bits into register",
             "Control: result_mux=11 (Immediate) · reg_wr=1 · no memory access\n"
             "Flow: ImmGen U-format → Write-back MUX → rd  (lower 12 bits = 0)",
             False)
    pages.append(d.xml())

    d = D("Complete Datapath")
    d.v(40, 24, 560, 32, "Lab 7 — Complete Single-Cycle RV32I Datapath", "title")
    draw_cpu(d,
             "All tested instructions: R, I, LW, SW, BEQ, JAL, LUI",
             "Hierarchy (mem_path.vh):\n"
             "  cpu.DATAPATH.Reg_file.Registers[]\n"
             "  cpu.MEMORY.Inst_Mem.memory[]  — word index pc[11:2]\n"
             "  cpu.MEMORY.Data_Mem.memory[]  — byte index addr[11:0]\n\n"
             "WB MUX: 00=ALU · 01=Mem · 10=PC+4 · 11=Imm  |  ALU B MUX: rs2 or imm",
             True)
    pages.append(d.xml())

    return mxfile(pages)


def main():
    paths = [
        ROOT / "Lab05/docs/imm_gen.drawio",
        ROOT / "Lab06/docs/datapath.drawio",
        ROOT / "Lab07/docs/datapath.drawio",
    ]
    contents = [lab5(), lab6(), lab7()]
    for p, c in zip(paths, contents):
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(c, encoding="utf-8")
        print(f"Wrote {p} ({len(c)} bytes, {c.count('<diagram')} pages)")


if __name__ == "__main__":
    main()
