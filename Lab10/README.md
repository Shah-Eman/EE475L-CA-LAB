# Lab 10 — Pipeline Hazard Resolution (Part II)

Implements the Lab 9 resolution strategy on the Lab 8 **3-stage pipeline**.

## Hazard hardware added

| Module | Function |
|--------|----------|
| `hazard_unit.sv` | Load-use stall detection + forwarding select |
| `if_id_reg` | **Stall** hold on IF/ID |
| `IF_STAGE` / `pc` | **PC enable** (`pc_en = !stall`) |
| `ID_EX` | Forwarding muxes on ALU inputs and store data |

## Techniques implemented

1. **Data forwarding** — from ID/MEM ALU result and MEM/WB write-back to ID/EX operands  
2. **Load-use stall** — hold PC + IF/ID, insert bubble into ID/MEM when `lw` is followed by a dependent op  
3. **Branch/jump flush** — IF/ID flush on taken branch/jump (from Lab 8)

## Module hierarchy

```
cpu
├── HAZARD          (hazard_unit)
├── IF_STAGE
├── IF_ID           (if_id_reg)
├── ID_EX
├── ID_MEM          (id_mem_reg)
└── MEM_WB
```

## Folder structure

```
Lab10/
├── docs/     ← datapath + hazard logic diagram (draw.io)
├── rtl/
│   ├── hazard_unit.sv   ← new
│   └── …
└── tb/
    └── lab10_tb.sv
```

## Simulation (QuestaSim)

```tcl
cd Lab10
vlib work
vlog -sv +incdir+../include rtl/*.sv tb/lab10_tb.sv
vsim -c -novopt cpu_tb -do "run -all; quit"
```

Expected: **`All Lab 10 pipeline tests passed!`**

## Tests (`lab10_tb.sv`)

| Test | Verifies |
|------|----------|
| Forward ALU RAW | Back-to-back `addi` + `add` without NOP |
| Load-use stall | `lw` immediately followed by dependent `add` |
| R-type, LW, SW | Basic pipeline ops |
| BEQ, JAL | Control + flush |

## Testbench hierarchy paths

```verilog
`define REGFILE_PATH cpu.ID_EX.Reg_file
`define DMEM_PATH    cpu.MEM_WB.Data_Mem
`define IMEM_PATH    cpu.IF_STAGE.Inst_Mem
```

## Related labs

- Lab 8 — base 3-stage pipeline  
- Lab 9 — hazard analysis (`../Lab09/docs/`)
