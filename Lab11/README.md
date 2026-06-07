# Lab 11 — Insertion Sort on the Pipelined Processor + FPGA Display

Implements the **insertion-sort** algorithm on the Lab 10 **3-stage pipelined
RISC-V processor**, verifies it in simulation, and drives the **sorted array
onto the FPGA seven-segment displays**.

## What this lab adds

| Part | Files | Purpose |
|------|-------|---------|
| Insertion-sort program | `program/insertion_sort.s`, `program/assemble.py`, `program/imem.hex`, `program/dmem.hex` | Assembly + the assembled machine code / initial data |
| Memory pre-load | `rtl/instr_mem.sv`, `rtl/data_mem.sv` | `$readmemh` init so the program/data live in the design (FPGA-ready) |
| Array tap-out | `rtl/data_mem.sv`, `rtl/MEM_WB.sv`, `rtl/cpu.sv` | Four debug outputs expose the sorted words to the top level |
| Display driver | `rtl/seven_seg_display.sv`, `rtl/clk_delay_display.sv`, `rtl/t_ff.sv` | The two provided modules (+ the missing `t_ff`), integrated |
| FPGA top | `rtl/lab11_top.sv`, `constraints/lab11_nexys_a7.xdc` | Connects processor → display, pin-mapped for the board |

The processor datapath (ALU, controllers, hazard unit, pipeline registers,
register file, immediate generator) is **identical to Lab 10** — only the
memories, `cpu` ports, and the new display/top wrappers changed.

## The program

```
arr[] = [9, 3, 7, 5]   ->   sorted   [3, 5, 7, 9]
```

The four words live at byte addresses `0x0, 0x4, 0x8, 0xC` in data memory
(the lab's `data_mem` is byte-address indexed). Because the branch unit only
resolves `BEQ`/`BNE`, every `<`/`>`/`>=` comparison is built from
`SLT`/`SLTI` followed by a branch, and loops are closed with `JAL x0`.

The pipeline hazards it exercises (all handled by the Lab 10 hardware):
* **Forwarding** — e.g. `slt x1,..` → `beq x1,..`, `add x12,..` → `lw .. (x12)`
* **Load-use stall** — `lw x8,0(x13)` → `slt x1,x6,x8`
* **Branch flush** — the `beq`/`bne` loop exits and the backward `jal` loops

Re-assemble after editing the program or the input array:

```bash
cd program && python3 assemble.py      # -> imem.hex, dmem.hex
```

## Simulation

### Icarus Verilog (Makefile)

```bash
cd Lab11
make sort     # insertion-sort functional check  -> "insertion_sort PASSED"
make top      # processor + display integration   -> "lab11_top PASSED"
```

`make sort` prints the initial and sorted arrays and checks both the
`cpu` debug outputs and the raw data-memory words:

```
Initial array : [9, 3, 7, 5]
Sorted array  : [3, 5, 7, 9]
RESULT: insertion_sort PASSED (array sorted ascending)
```

`make top` walks a full display refresh and confirms each digit:

```
display 0 shows digit 3 ...  display 3 shows digit 9 ...
RESULT: lab11_top PASSED (displays show sorted array 3 5 7 9)
```

### QuestaSim / ModelSim

```tcl
cd Lab11
vsim -do run.do                              ;# insertion_sort_tb
vsim -do "set TB lab11_top_tb; do run.do"    ;# lab11_top_tb
```

## FPGA implementation (Vivado, Nexys A7 / Nexys 4 DDR)

1. Add sources: all `rtl/*.sv`, set **`lab11_top`** as top.
2. Add `program/imem.hex` and `program/dmem.hex` as simulation/synthesis
   sources (Vivado loads them by file name through `$readmemh`).
3. Add `constraints/lab11_nexys_a7.xdc`.
4. Generate bitstream and program the board.

On the board the processor sorts the array within microseconds; the four
right-most seven-segment displays then show **`3 5 7 9`** (the remaining
displays show `0`). Press **BTNC** (reset) to re-run.

> The display refresh divider (`DISP_TAP = 17` → clk/2³⁹… i.e. clk/2¹⁸ from a
> 100 MHz clock) is the original tap from the provided `clk_delay_display`.
> Simulation overrides it (`DISP_TAP = 1`) so the multiplexer runs fast.

## Module hierarchy

```
lab11_top
├── CPU (cpu)                       ← runs insertion sort, exposes arr_word0..3
│   ├── IF_STAGE → pc, instr_mem    ← imem.hex
│   ├── IF_ID  (if_id_reg)
│   ├── HAZARD (hazard_unit)
│   ├── ID_EX  → main_controller, imm_gen, reg_file, alu_controller, alu
│   ├── ID_MEM (id_mem_reg)
│   └── MEM_WB → data_mem           ← dmem.hex, dbg_word0..3
└── DISPLAY (seven_seg_display)
    └── clk_delay_display → t_ff ×26
```

## Deliverables checklist

- [x] RTL for all modules (`rtl/`)
- [x] Insertion-sort assembly + machine code (`program/`)
- [x] Simulation proving correct sorting (`make sort`)
- [x] Display integration + simulation (`make top`)
- [x] FPGA top level and pin constraints (`rtl/lab11_top.sv`, `constraints/`)

See `docs/LAB11_GUIDE.md` for a line-by-line explanation.
