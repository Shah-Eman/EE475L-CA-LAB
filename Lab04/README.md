# Lab 04 — ALU & Controllers in SystemVerilog (Part 2)

Same RTL as Lab 03 with extended randomized testbenches.

## Folder Structure

```
Lab04/
├── rtl/          ← alu, alu_controller, main_controller
└── tb/           ← randomized verification testbenches
```

## Simulation

```tcl
cd Lab04
vlib work
vlog -sv +incdir+../include rtl/*.sv tb/*.sv
vsim -c -novopt alu_tb -do "run -all; quit"
```

Run each testbench top module separately: `alu_tb`, `alu_controller_tb`, `main_controller_tb`.
