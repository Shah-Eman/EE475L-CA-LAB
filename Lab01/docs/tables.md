# Lab 1 - Controller Design Tables

## Table 1.1 – ALU Operations (alu_operation encoding, 4-bit)

| Operations        | alu_operation (Controller Output) |
|-------------------|-----------------------------------|
| and               | 0000                              |
| or                | 0001                              |
| add               | 0010                              |
| xor               | 0011                              |
| sub               | 0110                              |
| slt  (signed)     | 0111                              |
| sltu (unsigned)   | 1000                              |
| sll               | 1001                              |
| srl               | 1010                              |
| sra               | 1011                              |

## Table 1.2 – ALU Controller Truth Table

ALUOp encoding:
  00 = memory (lw/sw/lb/lh/lbu/lhu)
  01 = branch
  10 = R-type
  11 = I-type arithmetic / jalr

| Instruction | func3 | func7   | ALUOp | Desired ALU Action |
|-------------|-------|---------|-------|--------------------|
| add         | 000   | 0000000 | 10    | ADD                |
| sub         | 000   | 0100000 | 10    | SUB                |
| xor         | 100   | 0000000 | 10    | XOR                |
| or          | 110   | 0000000 | 10    | OR                 |
| and         | 111   | 0000000 | 10    | AND                |
| slt         | 010   | 0000000 | 10    | SLT                |
| sltu        | 011   | 0000000 | 10    | SLTU               |
| sll         | 001   | 0000000 | 10    | SLL                |
| srl         | 101   | 0000000 | 10    | SRL                |
| sra         | 101   | 0100000 | 10    | SRA                |
| addi        | 000   | XXXXXXX | 11    | ADD                |
| xori        | 100   | XXXXXXX | 11    | XOR                |
| ori         | 110   | XXXXXXX | 11    | OR                 |
| andi        | 111   | XXXXXXX | 11    | AND                |
| slti        | 010   | XXXXXXX | 11    | SLT                |
| sltui       | 011   | XXXXXXX | 11    | SLTU               |
| slli        | 001   | 0000000 | 11    | SLL                |
| srli        | 101   | 0000000 | 11    | SRL                |
| srai        | 101   | 0100000 | 11    | SRA                |
| lb/lh/lw/lbu/lhu | XXX | XXXXXXX | 00 | ADD (addr)        |
| sb/sh/sw    | XXX   | XXXXXXX | 00    | ADD (addr)         |
| lui         | XXX   | XXXXXXX | --    | (no ALU, pass imm) |
| auipc       | XXX   | XXXXXXX | --    | ADD (PC + imm)     |
| jal         | XXX   | XXXXXXX | --    | ADD (PC + imm)     |
| jalr        | 000   | XXXXXXX | 11    | ADD                |
| beq         | 000   | XXXXXXX | 01    | SUB (zero flag)    |
| bne         | 001   | XXXXXXX | 01    | SUB (zero flag)    |
| blt         | 100   | XXXXXXX | 01    | SLT                |
| bge         | 101   | XXXXXXX | 01    | SLT (inverted)     |
| bltu        | 110   | XXXXXXX | 01    | SLTU               |
| bgeu        | 111   | XXXXXXX | 01    | SLTU (inverted)    |
