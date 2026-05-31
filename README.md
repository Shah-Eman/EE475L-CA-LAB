# EE-475L — Computer Architecture Lab

RISC-V RV32I processor design labs (UET Lahore, Spring 2026).

## Repository Structure

```
├── include/              # Shared headers (opcode.vh, mem_path.vh, alu_ops.vh)
├── Lab01/docs/           # Design tables + block diagrams
├── Lab02/docs/
├── Lab03/rtl/ + tb/      # ALU & controllers (Part 1)
├── Lab04/rtl/ + tb/      # ALU & controllers (Part 2)
├── Lab05/rtl/ + tb/      # Immediate generator
├── Lab06/rtl/ + tb/      # Single-cycle CPU — R & I type (Part 1)
├── Lab07/rtl/ + tb/      # Single-cycle CPU — S, B, J, U type (Part 2)
├── Lab08/rtl/ + tb/      # 3-stage pipelined CPU
├── Lab09/docs/           # Hazard analysis (no RTL)
└── Lab10/rtl/ + tb/      # Pipeline with forwarding + load-use stall
```

Each lab keeps **RTL** and **testbench** in separate folders.

## Lab Summary

| Lab | Topic | Testbench |
|-----|-------|-----------|
| 01–02 | ALU & controller design | — (docs only) |
| 03–04 | ALU & controllers in SV | `alu_tb`, `alu_controller_tb`, … |
| 05 | Immediate generator | `imm_gen_tb` |
| 06 | R & I-type CPU (Part 1) | `lab6_tb.sv` (14 tests) |
| 07 | S/B/J/U-type CPU (Part 2) | `mycpu_tb.sv` (22 tests) |
| 08 | 3-stage pipelined CPU | `lab8_tb.sv` (7 tests) |
| 09 | Pipeline hazard analysis | docs only (no RTL) |
| 10 | Hazard resolution (forward + stall) | `lab10_tb.sv` (8 tests) |

## Quick simulation

**Lab 6:**
```tcl
cd Lab06
vlog -sv +incdir+../include rtl/*.sv tb/lab6_tb.sv
vsim -c -novopt cpu_tb -do "run -all; quit"
```

**Lab 7:**
```tcl
cd Lab07
vlog -sv +incdir+../include rtl/*.sv tb/mycpu_tb.sv
vsim -c -novopt cpu_tb -do "run -all; quit"
```

**Lab 8:**
```tcl
cd Lab08
vlog -sv +incdir+../include rtl/*.sv tb/lab8_tb.sv
vsim -c -novopt cpu_tb -do "run -all; quit"
```

**Lab 10:**
```tcl
cd Lab10
vlog -sv +incdir+../include rtl/*.sv tb/lab10_tb.sv
vsim -c -novopt cpu_tb -do "run -all; quit"
```

## Authors
```
Shah Eman — 2023-EE-178 
Huzaifa Kashif — 2023-EE-177
Zain Haider — 
Ali Ahmed —
```
