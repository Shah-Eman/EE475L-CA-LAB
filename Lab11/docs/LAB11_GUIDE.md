# Lab 11 — Detailed Guide

This guide explains everything **new** in Lab 11 on top of the Lab 10
pipelined processor: the insertion-sort program, how it maps to the lab's
ISA subset, how the memories are pre-loaded, and how the two provided
seven-segment modules are integrated to display the sorted array.

---

## Part 0 — Big picture

```
            ┌────────────────────────────────────────────────────────┐
            │ lab11_top                                                │
            │                                                          │
  clk  ───► │   ┌───────────────┐  arr_word0..3  ┌──────────────────┐ │ ──► an0..an7
  reset ──► │   │      cpu       │ ─────────────► │ seven_seg_display│ │ ──► segA..segG
            │   │ (insertion    │   (4 sorted     │ (8-digit mux)    │ │
            │   │  sort runs)   │    words)       │ + clk_delay_disp │ │
            │   └───────────────┘                 │   + t_ff ×26     │ │
            │                                      └──────────────────┘ │
            └────────────────────────────────────────────────────────┘
```

* The **cpu** is the Lab 10 processor with two additions:
  1. instruction/data memories are pre-loaded from hex files (`$readmemh`),
     so the design is self-contained for the FPGA (no testbench poking);
  2. four debug outputs (`arr_word0..3`) continuously expose the array
     words so the display can read them without touching the load/store port.
* The **seven_seg_display** time-multiplexes the eight common-anode digits.
* The processor sorts in a few microseconds and then spins forever, so the
  sorted array stays in data memory and on the displays.

---

## Part 1 — The insertion-sort program

### 1.1 Reference C and the assembly

```c
for (int i = 1; i < n; i++) {
    int key = arr[i];
    int j   = i - 1;
    while (j >= 0 && arr[j] > key) {
        arr[j + 1] = arr[j];
        j = j - 1;
    }
    arr[j + 1] = key;
}
```

See `program/insertion_sort.s` for the full annotated assembly. Register map:

| Reg | Role | Reg | Role |
|-----|------|-----|------|
| x1  | comparison/scratch | x10 | base address (=0) |
| x5  | `i` | x11 | `n` (=4) |
| x6  | `key` | x12 | `&arr[i]` |
| x7  | `j` | x13 | `&arr[j]` |
| x8  | `arr[j]` | x14 | `&arr[j+1]` |

### 1.2 Working within the ISA subset

The processor (Lab 10 `ID_EX`) resolves **only `BEQ` and `BNE`** in its branch
unit, and has **no `JALR`**. So:

| High-level test | Implemented as |
|-----------------|----------------|
| `i < n` (continue)         | `slt x1,x5,x11` ; `beq x1,x0,end_outer` (exit when `i>=n`) |
| `j >= 0` (continue)        | `slti x1,x7,0` ; `bne x1,x0,end_inner` (exit when `j<0`) |
| `arr[j] > key` (continue)  | `slt x1,x6,x8` ; `beq x1,x0,end_inner` (exit when `arr[j]<=key`) |
| unconditional loop back    | `jal x0,<label>` (link discarded into x0) |
| halt                       | `jal x0,end_outer` (offset 0 → jumps to itself) |

Addresses use `slli xK, xi, 2` (`i*4`) then `add` with the base — the only
multiply needed is by 4, done as a shift.

### 1.3 Hazards the program triggers

All are handled automatically by the Lab 10 hazard hardware:

| Site | Hazard | Hardware response |
|------|--------|-------------------|
| `slt x1,..` → `beq x1,..` | RAW on x1 | forward (ID/MEM → ID_EX) |
| `add x12,..` → `lw ..(x12)` | RAW on x12 | forward |
| `lw x8,0(x13)` → `slt x1,x6,x8` | **load-use** | 1-cycle stall, then forward |
| taken `beq`/`bne`, backward `jal` | control | IF/ID flush |

### 1.4 Assembling

`program/assemble.py` is a tiny RV32I assembler for exactly this subset. It
does a label pass, encodes each instruction, and writes:

* `imem.hex` — one 32-bit word per line. `instr_mem` is **word indexed**
  (`memory[addr[11:2]]`) and the reset PC is `0x1000_0000`, so line 0 is the
  first instruction.
* `dmem.hex` — `@<byte-addr> <word>` records. `data_mem` is **byte-address
  indexed**, so the words land at indices 0, 4, 8, 12.

```bash
cd program && python3 assemble.py
```

Encoding spot-checks: `addi x10,x0,0` = `0x00000513`, `jal x0,.` = `0x0000006f`
(both match a standard RISC-V assembler).

---

## Part 2 — Memory pre-load (FPGA-ready)

### `instr_mem.sv`
```verilog
initial begin
    for (int i=0;i<1024;i++) memory[i] = 32'h0000_0013; // NOP
    if (INIT_FILE != "") $readmemh(INIT_FILE, memory);
end
```
* Fills with `NOP` (`addi x0,x0,0`) so unused locations are harmless.
* `$readmemh` works both in simulation and as **BRAM initialisation** in
  Vivado — this is what makes the design run on the FPGA with no testbench.

### `data_mem.sv`
* Same `$readmemh` pattern (with `@`-address records for the byte indexing).
* Adds four **debug read ports**:
  ```verilog
  assign dbg_word0 = memory[ARR_BASE + 0];
  assign dbg_word1 = memory[ARR_BASE + 4];
  assign dbg_word2 = memory[ARR_BASE + 8];
  assign dbg_word3 = memory[ARR_BASE + 12];
  ```
  These are pure combinational reads, independent of the load/store port, so
  the display always sees the current array contents.

`MEM_WB.sv` and `cpu.sv` simply pass `INIT_FILE`/`ARR_BASE` down and route
`dbg_word0..3` up to the new `cpu` outputs `arr_word0..3`.

---

## Part 3 — Display integration

### `t_ff.sv` (was missing)
A toggle flip-flop with async reset: `clk_out <= ~clk_out`. Each one divides
its clock by two.

### `clk_delay_display.sv`
A 26-stage ripple chain of `t_ff`s (identical hardware to the provided file),
refactored only so the output tap is a **parameter**:
```verilog
assign clk_out = q[TAP];   // TAP=17 (default) reproduces the original q17
```
* FPGA: `TAP=17` → `clk/2^18` ≈ 381 Hz from a 100 MHz clock — a comfortable
  scan rate for the 8-digit multiplexer.
* Simulation: testbenches pass `TAP=1` so the digits cycle in tens of clocks.

### `seven_seg_display.sv` (the provided `sim_dis`)
Renamed to match its file name and given the same `TAP` parameter. Operation:
* a 3-bit counter (clocked by the divided clock) walks digits 0→7;
* a mux picks `num[count]` (a 4-bit value);
* one decoder maps the value → 7 segment bits (active low),
* another maps the count → which anode is enabled (active low).

Persistence of vision makes all eight digits look simultaneously lit.

### `lab11_top.sv`
```verilog
num[0]=arr0[3:0]; num[1]=arr1[3:0]; num[2]=arr2[3:0]; num[3]=arr3[3:0];
num[4..7]=0;
```
The four sorted values are small (0–9), so their low nibble is the hex digit
to show. They go to the four right-most displays; the rest show `0`.

---

## Part 4 — Verification

### `tb/insertion_sort_tb.sv`
Builds the `cpu` with `IMEM_FILE`/`DMEM_FILE` set to the hex files, releases
reset, waits for the sort to finish, then checks `arr_word0..3` **and** the raw
`data_mem` words equal `[3,5,7,9]`.

### `tb/lab11_top_tb.sv`
Builds the full `lab11_top` with `DISP_TAP=1`, lets the sort finish, then over
several refresh cycles samples the segment bus whenever each anode is active
and compares it to the expected digit for that position (3,5,7,9,0,0,0,0). It
also asserts every digit slot was driven at least once.

Both print `... PASSED`.

---

## Part 5 — FPGA notes (Nexys A7 / Nexys 4 DDR)

* The board has exactly **8** common-anode seven-segment displays — a direct
  match for `seven_seg_display`.
* `constraints/lab11_nexys_a7.xdc` maps `clk`→E3 (100 MHz), `reset`→BTNC (N17),
  `segA..segG`→`CA..CG`, `an0..an7`→`AN0..AN7`.
* Flow: add `rtl/*.sv` (top = `lab11_top`), add `program/*.hex`, add the XDC,
  generate bitstream, program. Displays show `3 5 7 9`; BTNC re-runs.

---

## Quick file index

| File | Role |
|------|------|
| `program/insertion_sort.s` | Annotated assembly |
| `program/assemble.py` | RV32I-subset assembler → hex |
| `program/imem.hex` / `dmem.hex` | Machine code / initial array |
| `rtl/instr_mem.sv` / `data_mem.sv` | Memories + `$readmemh` (+ array taps) |
| `rtl/MEM_WB.sv` / `cpu.sv` | Thread init params + expose `arr_word0..3` |
| `rtl/t_ff.sv` | Toggle FF (clock-divider stage) |
| `rtl/clk_delay_display.sv` | Parameterised ripple divider |
| `rtl/seven_seg_display.sv` | 8-digit multiplexed driver |
| `rtl/lab11_top.sv` | FPGA top: cpu + display |
| `tb/insertion_sort_tb.sv` | Sort correctness |
| `tb/lab11_top_tb.sv` | Display integration |
| `constraints/lab11_nexys_a7.xdc` | Board pin map |

*All other `rtl/*.sv` files are unchanged copies of the Lab 10 processor.*
