# Lab 08 — 3-Stage Pipelined RISC-V Processor

Transition from the Lab 7 single-cycle CPU to a **3-stage pipeline** with pipeline registers and a pipelined controller.

## Pipeline stages

| Stage | Name | Operations |
|-------|------|------------|
| 1 | **IF** (Fetch) | PC, instruction memory |
| 2 | **ID/EX** (Decode + Execute) | Main controller, reg read, imm gen, ALU, branch/jump resolve |
| 3 | **MEM/WB** (Memory + Write-back) | Data memory, write-back mux, register write |

## Pipeline registers

| Register | Holds |
|----------|--------|
| **IF/ID** | `pc`, `pc+4`, `instr`, valid |
| **ID/MEM** | ALU result, `rs2`, `rd`, control signals for MEM/WB |

Control signals are generated in stage 2 from the opcode and latched into **ID/MEM** for stage 3.

## Module hierarchy

```
cpu
├── IF_STAGE      (pc, Inst_Mem)
├── if_id_reg
├── ID_EX         (main_controller, Reg_file, imm_gen, alu, branch logic)
├── id_mem_reg
└── MEM_WB        (Data_Mem, write-back mux)
```

## Branch / jump (minimal control handling)

When a branch or jump is resolved in **ID/EX**:

- PC is redirected to `pc + imm`
- **IF/ID is flushed** (bubble inserted)

Full hazard detection (stalling, forwarding) is **Lab 9–10** — not implemented here.

## Folder structure

```
Lab08/
├── docs/     ← add pipelined datapath + controller diagrams (draw.io)
├── rtl/
└── tb/
    └── lab8_tb.sv
```

## Simulation (QuestaSim)

```tcl
cd Lab08
vlib work
vlog -sv +incdir+../include rtl/*.sv tb/lab8_tb.sv
vsim -c -novopt cpu_tb -do "run -all; quit"
```

Expected: `All Lab 8 pipeline tests passed!`

## Testbench hierarchy paths

```verilog
`define REGFILE_PATH cpu.ID_EX.Reg_file
`define DMEM_PATH    cpu.MEM_WB.Data_Mem
`define IMEM_PATH    cpu.IF_STAGE.Inst_Mem
```

## Notes

- PC resets to `0x1000_0000` (same as Lab 7)
- Reuses Lab 7 ALU, controllers, memories, and ISA support
- Dependent back-to-back instructions may produce wrong results until Lab 10 hazard logic is added
