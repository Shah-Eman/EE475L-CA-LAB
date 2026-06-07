#!/usr/bin/env python3
"""
Minimal RISC-V (RV32I subset) assembler for Lab 11.

It supports exactly the instruction subset implemented by the lab's
3-stage pipelined processor and emits:

    imem.hex  - one 32-bit instruction word per line (for $readmemh into
                instr_mem, which is word indexed: memory[pc[11:2]]).
    dmem.hex  - the unsorted array, using @<byte-addr> records because the
                lab's data_mem is byte-address indexed (word k @ 4*k).

Run:  python3 assemble.py
"""

# ----------------------------------------------------------------------
# The program (mirrors program/insertion_sort.s). Each entry is a tuple.
# Labels are plain strings ending in ':'.
# ----------------------------------------------------------------------
PROGRAM = [
    ("addi", "x10", "x0", 0),
    ("addi", "x11", "x0", 4),
    ("addi", "x5",  "x0", 1),
    "outer_loop:",
    ("slt",  "x1",  "x5",  "x11"),
    ("beq",  "x1",  "x0",  "end_outer"),
    ("slli", "x12", "x5",  2),
    ("add",  "x12", "x12", "x10"),
    ("lw",   "x6",  0, "x12"),
    ("addi", "x7",  "x5",  -1),
    "inner_loop:",
    ("slti", "x1",  "x7",  0),
    ("bne",  "x1",  "x0",  "end_inner"),
    ("slli", "x13", "x7",  2),
    ("add",  "x13", "x13", "x10"),
    ("lw",   "x8",  0, "x13"),
    ("slt",  "x1",  "x6",  "x8"),
    ("beq",  "x1",  "x0",  "end_inner"),
    ("sw",   "x8",  4, "x13"),
    ("addi", "x7",  "x7",  -1),
    ("jal",  "x0",  "inner_loop"),
    "end_inner:",
    ("addi", "x14", "x7",  1),
    ("slli", "x14", "x14", 2),
    ("add",  "x14", "x14", "x10"),
    ("sw",   "x6",  0, "x14"),
    ("addi", "x5",  "x5",  1),
    ("jal",  "x0",  "outer_loop"),
    "end_outer:",
    ("jal",  "x0",  "end_outer"),
]

# Unsorted input array (byte address -> value)
ARRAY = [9, 3, 7, 5]   # sorted result: [3, 5, 7, 9]

OPC = {
    "rtype": 0b0110011,
    "itype": 0b0010011,
    "load":  0b0000011,
    "store": 0b0100011,
    "branch":0b1100011,
    "jal":   0b1101111,
}

FUNCT3 = {
    "add": 0b000, "slt": 0b010, "sltu": 0b011, "and": 0b111, "or": 0b110,
    "xor": 0b100, "sll": 0b001, "srl": 0b101,
    "addi": 0b000, "slti": 0b010, "andi": 0b111, "ori": 0b110, "slli": 0b001,
    "lw": 0b010, "sw": 0b010,
    "beq": 0b000, "bne": 0b001,
}


def reg(r):
    assert r[0] == "x", f"bad register {r}"
    n = int(r[1:])
    assert 0 <= n < 32
    return n


def u(val, bits):
    return val & ((1 << bits) - 1)


def first_pass(program):
    """Map label -> instruction index (PC word index)."""
    labels, idx = {}, 0
    for item in program:
        if isinstance(item, str) and item.endswith(":"):
            labels[item[:-1]] = idx
        else:
            idx += 1
    return labels


def encode(instr, idx, labels):
    op = instr[0]

    if op in ("add", "slt", "sltu", "and", "or", "xor", "sll", "srl"):
        rd, rs1, rs2 = reg(instr[1]), reg(instr[2]), reg(instr[3])
        funct7 = 0
        return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | \
               (FUNCT3[op] << 12) | (rd << 7) | OPC["rtype"]

    if op in ("addi", "slti", "andi", "ori"):
        rd, rs1, imm = reg(instr[1]), reg(instr[2]), instr[3]
        return (u(imm, 12) << 20) | (rs1 << 15) | (FUNCT3[op] << 12) | \
               (rd << 7) | OPC["itype"]

    if op == "slli":
        rd, rs1, shamt = reg(instr[1]), reg(instr[2]), instr[3]
        return (0 << 25) | (u(shamt, 5) << 20) | (rs1 << 15) | \
               (FUNCT3[op] << 12) | (rd << 7) | OPC["itype"]

    if op == "lw":
        rd, imm, rs1 = reg(instr[1]), instr[2], reg(instr[3])
        return (u(imm, 12) << 20) | (rs1 << 15) | (FUNCT3[op] << 12) | \
               (rd << 7) | OPC["load"]

    if op == "sw":
        rs2, imm, rs1 = reg(instr[1]), instr[2], reg(instr[3])
        imm = u(imm, 12)
        return ((imm >> 5) << 25) | (rs2 << 20) | (rs1 << 15) | \
               (FUNCT3[op] << 12) | ((imm & 0x1F) << 7) | OPC["store"]

    if op in ("beq", "bne"):
        rs1, rs2, label = reg(instr[1]), reg(instr[2]), instr[3]
        off = (labels[label] - idx) * 4
        imm = u(off, 13)
        b12   = (imm >> 12) & 1
        b11   = (imm >> 11) & 1
        b10_5 = (imm >> 5) & 0x3F
        b4_1  = (imm >> 1) & 0xF
        return (b12 << 31) | (b10_5 << 25) | (rs2 << 20) | (rs1 << 15) | \
               (FUNCT3[op] << 12) | (b4_1 << 8) | (b11 << 7) | OPC["branch"]

    if op == "jal":
        rd, label = reg(instr[1]), instr[2]
        off = (labels[label] - idx) * 4
        imm = u(off, 21)
        b20    = (imm >> 20) & 1
        b10_1  = (imm >> 1) & 0x3FF
        b11    = (imm >> 11) & 1
        b19_12 = (imm >> 12) & 0xFF
        return (b20 << 31) | (b19_12 << 12) | (b11 << 20) | \
               (b10_1 << 21) | (rd << 7) | OPC["jal"]

    raise ValueError(f"unsupported instruction: {instr}")


def main():
    labels = first_pass(PROGRAM)
    words, idx = [], 0
    for item in PROGRAM:
        if isinstance(item, str) and item.endswith(":"):
            continue
        words.append(encode(item, idx, labels))
        idx += 1

    with open("imem.hex", "w") as f:
        for w in words:
            f.write(f"{w & 0xFFFFFFFF:08x}\n")

    # data_mem is byte-address indexed; word k sits at index 4*k.
    with open("dmem.hex", "w") as f:
        for k, val in enumerate(ARRAY):
            f.write(f"@{k * 4:08x} {val & 0xFFFFFFFF:08x}\n")

    print(f"Assembled {len(words)} instructions -> imem.hex")
    print(f"Initial array {ARRAY} -> dmem.hex (sorted result: {sorted(ARRAY)})")


if __name__ == "__main__":
    main()
