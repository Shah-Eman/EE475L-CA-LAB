# Lab 06 — R & I Type Instructions (Part 1)

Single-cycle CPU supporting **R-type**, **I-type arithmetic**, and **LW** only.

## Instructions supported

| Type | Instructions |
|------|-------------|
| R-type | add, sub, sll, srl, xor, or, and |
| I-type | addi, xori, ori, andi, slli, srli |
| Load | lw |

## Block diagram

Open **`docs/datapath.drawio`** in [draw.io](https://app.diagrams.net/) — single-cycle RISC-V datapath matching the lab manual (PC, Inst. Mem, Register File, Immediate Gen., ALU, Data Mem, write-back mux).

## Folder structure

```
Lab06/
├── docs/
│   └── datapath.drawio   ← single-cycle datapath diagram
├── rtl/          ← cpu, datapath, memory, alu, controllers, …
├── tb/
│   └── lab6_tb.sv
└── single cycle.drawio
```

## Simulation (QuestaSim)

```tcl
cd Lab06
vlib work
vlog -sv +incdir+../include rtl/*.sv tb/lab6_tb.sv
vsim -c -novopt cpu_tb -do "run -all; quit"
```

Expected: **14 tests passed** → `All Lab 6 tests passed!`

## Notes

- PC resets to `0x0000_0000`
- No branch, jump, store, or lui support (see Lab 07)
- Uses same hierarchy as Lab 07 (`cpu.DATAPATH.Reg_file`, etc.)
