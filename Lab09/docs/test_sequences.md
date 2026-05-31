# Lab 9 — Test Instruction Sequences

Use these programs to **test the Lab 8 pipeline** and **demonstrate hazards** before Lab 10 fixes.

Compile with the course RISC-V toolchain or assemble manually into `Inst_Mem.memory[]` like the existing testbenches.

---

## Test 1 — Independent instructions (baseline)

Should pass on Lab 8 pipeline.

```asm
    addi x1, x0, 10
    addi x2, x0, 20
    add  x3, x1, x2      # x3 = 30
```

**Expected:** x3 = 30  
**Hazard:** None

---

## Test 2 — Back-to-back ALU dependency (RAW)

Should **fail** on Lab 8 without forwarding.

```asm
    addi x1, x0, 5
    add  x2, x1, x1      # x2 should be 10; reads stale x1 without forward
```

**Expected (correct):** x2 = 10  
**Lab 8 likely:** x2 = 0 or wrong value  
**Hazard:** EX/MEM → EX RAW

---

## Test 3 — Load-use hazard

Should **fail** on Lab 8 without stall.

```asm
    addi x1, x0, 0x100   # base address
    sw   x2, 0(x1)       # setup: store known value first (x2 preset in TB)
    lw   x3, 0(x1)
    add  x4, x3, x0      # uses load result immediately
```

**Expected:** x4 = value loaded from memory  
**Lab 8 likely:** x4 uses old x3  
**Hazard:** Load-use (needs stall in Lab 10)

---

## Test 4 — Branch taken (control)

Should pass on Lab 8 (flush implemented).

```asm
    addi x1, x0, 1
    addi x2, x0, 1
    beq  x1, x2, skip    # offset to skip next insn
    addi x3, x0, 99      # should NOT execute
skip:
    addi x4, x0, 7       # should execute
```

**Expected:** x3 unchanged, x4 = 7  
**Hazard:** Control — handled by IF/ID flush

---

## Test 5 — Branch not taken

```asm
    addi x1, x0, 1
    addi x2, x0, 2
    beq  x1, x2, skip
    addi x3, x0, 42      # should execute
skip:
    addi x4, x0, 0
```

**Expected:** x3 = 42, x4 = 0  
**Hazard:** None

---

## Test 6 — JAL (control + link)

```asm
    jal  x1, target      # x1 = return addr, jump forward
    addi x2, x0, 99      # skipped
target:
    addi x3, x0, 11
```

**Expected:** x1 = addr of `addi x2`, x2 ≠ 99, x3 = 11  
**Hazard:** Control — flush handles wrong-path fetch

---

## Test 7 — Mixed program (Lab 10 regression)

After hazard logic is added, run all instruction types in one image:

```asm
    addi x1, x0, 1
    addi x2, x0, 2
    add  x3, x1, x2
    sw   x3, 0(x4)       # x4 = base set in data mem setup
    lw   x5, 0(x4)
    add  x6, x5, x1
    beq  x6, x3, ok
    addi x7, x0, 0
ok:
    addi x7, x0, 1
```

Compare final registers with Lab 7 single-cycle simulation.

---

## How to run in simulation

1. Encode instructions into `cpu.IF_STAGE.Inst_Mem.memory[word_index]`
2. Initialize `Reg_file` / `Data_Mem` as needed
3. Reset CPU, run until write completes or timeout
4. Log `Reg_file.Registers[]` each cycle to observe pipeline overlap

See `Lab08/tb/lab8_tb.sv` for encoding examples (`IMM[12]` slice style for branches, etc.).
