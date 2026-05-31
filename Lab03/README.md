# Lab 03 — ALU & Controllers in SystemVerilog (Part 1)

## Folder Structure

```
Lab03/
├── rtl/
│   ├── alu.sv
│   ├── alu_controller.sv
│   └── main_controller.sv      ← first-level: opcode → ALUOp
└── tb/
    ├── alu_tb.sv
    ├── alu_controller_tb.sv
    └── main_controller_tb.sv
```

## QuestaSim

From the repo root:

```tcl
cd Lab03
vlib work
vlog -sv +incdir+../include rtl/*.sv tb/*.sv
vsim -c -novopt alu_tb -do "run -all; quit"
vsim -c -novopt alu_controller_tb -do "run -all; quit"
vsim -c -novopt main_controller_tb -do "run -all; quit"
```

## Verilator (CLI)

```bash
cd Lab03
verilator --binary -I../include --top-module alu_tb rtl/alu.sv tb/alu_tb.sv
./obj_dir/Valu_tb
```

Repeat with `alu_controller_tb` and `main_controller_tb`.
