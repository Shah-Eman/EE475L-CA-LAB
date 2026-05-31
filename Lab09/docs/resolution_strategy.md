# Lab 9 — Proposed Hazard Resolution Strategy (Lab 10 Implementation)

No hardware changes in Lab 9. This is the plan for Lab 10.

---

## Overview

| Hazard | Technique | Where in pipeline |
|--------|-----------|-------------------|
| ALU RAW (EX/MEM → EX) | **Data forwarding** | ID/EX ALU inputs |
| Load-use RAW | **Stall + forwarding** | Stall IF/ID; forward after load completes |
| Taken branch/jump | **Flush** (exists) + PC redirect | IF/ID flush (Lab 8) |
| Structural | None needed | — |

---

## 1. Data forwarding unit

Add forwarding muxes on **ALU operand inputs** in ID/EX:

| MUX select | Source | Use when |
|------------|--------|----------|
| `00` | RegFile read data | No hazard |
| `01` | **ID/MEM** pipeline reg (`alu_out`) | Producer in MEM/WB stage, consumer in ID/EX |
| `10` | **MEM/WB** write-back data (`wb_data`) | Producer completing write same cycle |
| `11` | (optional) imm / don't care | I-type already uses imm on B |

### Forwarding conditions (conceptual)

```
forward_A from ID/MEM if (id_mem.reg_wr && id_mem.rd == rs1 && id_mem.rd != 0)
forward_A from WB     if (mem_wb.reg_wr && mem_wb.rd == rs1 && mem_wb.rd != 0)
                       && !forward_from_id_mem
(same for forward_B with rs2)
```

For **`sw`**, also forward rs2 data to the store datapath when the value to store comes from a recent ALU/load result.

---

## 2. Load-use stall

Forwarding cannot fix load-use: memory data is not valid until the MEM/WB stage finishes the read.

**Detection:**

```
stall = id_mem.valid && id_mem.is_load && id_mem.rd != 0 &&
        if_id.valid && (if_id.rs1 == id_mem.rd || if_id.rs2 == id_mem.rd)
```

**Actions when `stall` asserted:**

1. **PC hold** — do not advance PC (`pc_en = 0`)
2. **IF/ID hold** — do not load new instruction (insert bubble in ID/EX instead)
3. **ID/MEM** continues normally so the load completes

After one stall, forward `wb_data` from the completed load into ID/EX.

---

## 3. Control hazard — branch / jump

**Already in Lab 8:**

- Branch/jump resolved in ID/EX
- `pc_next = redirect_pc` when taken
- `if_id_flush` clears wrong-path instruction in IF/ID

**Optional Lab 10 improvement:**

- Also squash/flush **ID/MEM** if a branch in ID/EX makes an ALU op in ID/MEM part of the wrong path (only needed for more complex multi-branch overlap; minimal design may not require it if flush timing is clean)

**Penalty:** 1 bubble per taken branch/jump (acceptable for this lab).

---

## 4. Hazard detection unit (block diagram addition)

New combinational block in the controller path:

```
Inputs:
  - IF/ID: rs1, rs2, opcode
  - ID/MEM: rd, reg_wr, mem_read (load flag)
  - MEM/WB: rd, reg_wr

Outputs:
  - forward_sel_A, forward_sel_B
  - stall (PC_en, IF/ID_en)
  - flush (IF/ID) — already from branch unit
```

Draw this unit in the Lab 8 datapath diagram for submission (Lab 9 deliverable: block diagram **with hazard logic shown**, even if not yet implemented).

---

## 5. Verification plan (Lab 10)

Use sequences from `test_sequences.md`:

1. **Forward test** — back-to-back `add` without NOP; expect correct sum
2. **Load-use stall** — `lw` + dependent `add`; expect 1-cycle stall then correct value
3. **Branch taken** — PC and register results match single-cycle reference
4. **Mixed program** — combine R, I, load, store, branch in one IMEM image

Compare against Lab 7 single-cycle results for the same program.

---

## 6. Expected CPI impact

| Case | Cycles per instruction (approx.) |
|------|----------------------------------|
| Independent ops | 1.0 (pipeline full) |
| ALU RAW | 1.0 with forwarding |
| Load-use | ~2.0 for the pair (1 stall) |
| Taken branch | ~1 bubble penalty |

Exact CPI depends on program mix; document measured results in Lab 10 simulation report.
