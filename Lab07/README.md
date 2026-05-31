# Lab 07 — S, B, J & U Type Instructions (Part 2)

Complete single-cycle RV32I CPU extending Lab 06 with **store, branch, jump, and lui**.

## Instructions added in Lab 7

| Type | Instructions |
|------|-------------|
| S-type | sw |
| B-type | beq, bne |
| J-type | jal |
| U-type | lui |

## Block diagrams

Open `docs/datapath.drawio` in draw.io (5 pages):

1. **S-Type (SW)**  
2. **B-Type (BEQ/BNE)**  
3. **J-Type (JAL)**  
4. **U-Type (LUI)**  
5. **Complete Single-Cycle Datapath**

## Folder structure

```
Lab07/
├── docs/
│   └── datapath.drawio   ← SW, BEQ, JAL, LUI, complete (5 pages)
├── rtl/          ← full CPU (builds on Lab 06 modules)
├── tb/
│   └── mycpu_tb.sv   ← professor-provided testbench
└── single cycle.drawio
```

## Simulation (QuestaSim)

```tcl
cd Lab07
vlib work
vlog -sv +incdir+../include rtl/*.sv tb/mycpu_tb.sv
vsim -c -novopt cpu_tb -do "run -all; quit"
```

Expected: **22 tests passed** → `All tests passed!`

## Design notes

- PC resets to `0x1000_0000` (required by JAL test)
- Data memory: byte addressing `memory[addr[11:0]]`
- Instruction memory: word indexing `memory[pc[11:2]]`
- Header files: `../include/opcode.vh`, `../include/mem_path.vh`

## Allowed testbench edits

Only the include paths in `mycpu_tb.sv` were changed from the professor version.
