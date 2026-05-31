# Lab 9 — Pipeline Hazard Analysis (3-Stage CPU)

This document analyzes hazards for the Lab 8 pipeline:

```
IF  →  [IF/ID]  →  ID/EX  →  [ID/MEM]  →  MEM/WB  →  RegFile write
```

Register reads and ALU operate in **ID/EX**. Register writes occur at the end of **MEM/WB**.

---

## 1. Data hazards (RAW — Read After Write)

A **data hazard** occurs when an instruction reads a register that a previous instruction has not yet written back.

### 1.1 EX/MEM → EX hazard (1-cycle apart)

**Pattern:** back-to-back dependent ALU ops

```asm
add  x1, x2, x3    # producer
add  x4, x1, x0    # consumer uses x1
```

| Cycle | IF | ID/EX | MEM/WB |
|-------|----|-------|--------|
| 1 | `add x1` | — | — |
| 2 | `add x4` | `add x1` (ALU computes) | — |
| 3 | … | `add x4` reads **stale x1** | `add x1` writes x1 |

**Why:** The consumer enters ID/EX in the same cycle the producer completes MEM/WB. RegFile is updated on the clock edge, but the read in ID/EX is combinational **before** that write is visible.

**When:** Any R-type or I-type ALU instruction immediately followed by an instruction that uses its destination register as rs1 or rs2.

---

### 1.2 MEM → EX hazard (load-use)

**Pattern:**

```asm
lw   x1, 0(x2)     # producer
add  x3, x1, x0    # consumer uses loaded value
```

| Cycle | IF | ID/EX | MEM/WB |
|-------|----|-------|--------|
| 1 | `lw` | — | — |
| 2 | `add` | `lw` (addr calc) | — |
| 3 | … | `add` reads **stale x1** | `lw` reads memory |

**Why:** Load data (`mem_rdata`) is only available during MEM/WB. The dependent instruction is already in ID/EX and needs the value one cycle earlier.

**When:** Any `lw` followed by an instruction that uses the loaded register (ALU op, `sw`, branch compare, etc.) with **no independent instruction between them**.

This is the classic **load-use hazard** and always needs at least **one stall cycle** (forwarding alone is not enough).

---

### 1.3 MEM → EX hazard (ALU result still in ID/MEM)

**Pattern:** two dependent ops with one unrelated instruction between them is OK; zero gaps fails (see 1.1).

If the producer is in MEM/WB while consumer is in ID/EX, forwarding from the **ID/MEM pipeline register** (ALU output) or from the write-back value can supply the correct operand before the register file is updated.

---

## 2. Control hazards

A **control hazard** occurs when the pipeline fetches/decodes instructions along the wrong control-flow path.

### 2.1 Taken branch / jump (partially handled in Lab 8)

**Pattern:**

```asm
beq  x1, x2, target
add  x3, x4, x5      # fall-through (may be wrongly fetched)
```

Branch resolution happens in **ID/EX**. Meanwhile IF may have fetched the fall-through instruction into **IF/ID**.

**Lab 8 behaviour:** On taken branch/jump, PC ← `pc + imm` and **IF/ID is flushed** (bubble inserted).

**Remaining issue:** One cycle of penalty on every taken branch/jump (bubble in IF/ID). Not-taken branches do not flush.

**When:** Any taken `beq`, `bne`, or `jal`.

---

### 2.2 Not-taken branch

No flush needed — fetched fall-through is correct.

---

## 3. Structural hazards

A **structural hazard** occurs when two stages need the same hardware at the same time.

### Our design

| Resource | Usage | Conflict? |
|----------|--------|-----------|
| RegFile | Read in ID/EX, write in MEM/WB | No separate ports — handled by forwarding/timing, not a stall |
| Inst_Mem | IF only | No |
| Data_Mem | MEM/WB only | No |

**Conclusion:** No structural hazards in the current Harvard-style 3-stage design (separate instruction and data memories, 2 read + 1 write register file).

---

## 4. Summary table

| Hazard | Type | Example | Currently handled? |
|--------|------|---------|------------------|
| Back-to-back ALU dependency | Data (RAW) | `add x1,…` then `add x2,x1,…` | **No** — wrong result |
| Load-use | Data (RAW) | `lw x1,…` then `add x2,x1,…` | **No** — wrong result |
| Taken branch/jump | Control | `beq` taken, `jal` | **Partial** — IF/ID flush only |
| Not-taken branch | Control | `beq` not taken | OK |
| Memory / reg port conflict | Structural | — | None in this design |

---

## 5. Comparison with 5-stage pipeline

In a classic 5-stage (IF, ID, EX, MEM, WB) design, the same RAW patterns appear but at different stage boundaries (EX/MEM, MEM/WB). Our 3-stage design merges ID+EX and MEM+WB, so:

- Fewer pipeline registers
- Hazards appear between **ID/EX** and **MEM/WB** more often
- Load-use still requires a stall because memory data is not ready until the combined MEM/WB stage

See `resolution_strategy.md` for the planned Lab 10 fixes.
