# Lab 09 — Pipeline Hazard Detection and Resolution (Part I)

Analysis of hazards in the **Lab 8 three-stage pipeline**. **No RTL changes** in this lab — implementation is Lab 10.

## Pipeline under study

| Stage | Name | Key operations |
|-------|------|----------------|
| 1 | **IF** | PC, instruction memory |
| 2 | **ID/EX** | Decode, reg read, imm gen, ALU, branch/jump resolve |
| 3 | **MEM/WB** | Data memory, write-back mux, register write |

Pipeline registers: **IF/ID**, **ID/MEM**

Lab 8 already implements **IF/ID flush** on taken branch/jump. Data forwarding and load-use stalls are **not** implemented yet.

## Deliverables

| Item | Location |
|------|----------|
| Hazard identification & explanation | [`docs/hazard_analysis.md`](docs/hazard_analysis.md) |
| Proposed resolution strategy | [`docs/resolution_strategy.md`](docs/resolution_strategy.md) |
| Test instruction sequences | [`docs/test_sequences.md`](docs/test_sequences.md) |
| Block diagram | Reuse/update **Lab 8** pipelined datapath in `Lab08/docs/` (draw.io) |

## Task 1 — Verify pipeline before hazard study

1. Write RISC-V assembly for each test case in `docs/test_sequences.md`
2. Compile to machine code (course RISC-V compiler / Venus)
3. Load into `Inst_Mem`, simulate Lab 8 CPU, observe register file and data memory
4. Confirm which sequences pass/fail compared to single-cycle expectations

## Task 2 — Hazard analysis (this lab)

For each hazard type, document:

- **Why** it occurs in our 3-stage design
- **When** it appears (instruction pattern + cycle timing)
- **Planned fix** for Lab 10 (stall / forward / flush)

See the docs above — no implementation in Lab 9.

## Simulation (Lab 8 CPU used for testing)

```tcl
cd Lab08
vlog -sv +incdir+../include rtl/*.sv tb/lab8_tb.sv
vsim -c -novopt cpu_tb -do "run -all; quit"
```

Use the same hierarchy paths as Lab 8 when probing registers/memory in custom tests.

## Folder structure

```
Lab09/
├── README.md
└── docs/
    ├── hazard_analysis.md
    ├── resolution_strategy.md
    └── test_sequences.md
```
