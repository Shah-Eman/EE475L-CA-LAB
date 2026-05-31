# Lab 05 — Immediate Generator

## Folder Structure

```
Lab05/
├── docs/
│   └── imm_gen.drawio    ← block diagram
├── rtl/
│   └── imm_gen.sv
└── tb/
    └── imm_gen_tb.sv
```

## Supported Formats

| Format | Instructions |
|--------|-------------|
| I-type | ADDI, LW, JALR |
| S-type | SW |
| B-type | BEQ, BNE, … |
| U-type | LUI, AUIPC |
| J-type | JAL |

## Simulation

```tcl
cd Lab05
vlib work
vlog -sv +incdir+../include rtl/imm_gen.sv tb/imm_gen_tb.sv
vsim -c -novopt imm_gen_tb -do "run -all; quit"
```

```bash
verilator --binary -I../include --top-module imm_gen_tb rtl/imm_gen.sv tb/imm_gen_tb.sv
./obj_dir/Vimm_gen_tb
```

## Block Diagram

Open **`docs/imm_gen.drawio`** in [draw.io](https://app.diagrams.net/) — matches **Figure 5.1** from the lab manual (oval Imm gen block, 32-bit instruction in, 32-bit immediate out).
