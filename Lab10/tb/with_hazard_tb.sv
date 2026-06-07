`timescale 1ns/1ns

`include "opcode.vh"

`define REGFILE_PATH cpu.ID_EX.Reg_file
`define DMEM_PATH    cpu.MEM_WB.Data_Mem
`define IMEM_PATH    cpu.IF_STAGE.Inst_Mem

// Program (exercises forwarding + load-use stall + taken branch):
//   addi x1, x0, 6
//   addi x2, x0, 2
//   add  x4, x1, x2          ; x4 = 8
//   sw   x4, 0x20(x0)        ; mem[0x20] = 8
//   lw   x9, 0x20(x0)        ; x9 = 8   (load-use hazard with next instr)
//   add  x5, x9, x2          ; x5 = 10  (needs stall on x9)
//   add  x11, x1, x2         ; x11 = 8
//   beq  x4, x11, label      ; 8 == 8 -> taken (offset = +12 bytes)
//   addi x9, x0, 2           ; skipped
//   addi x4, x0, 16          ; skipped
//   label: or x2, x9, x4     ; x2 = 8 | 8 = 8
module cpu_tb();
    reg clk, rst;
    parameter CPU_CLOCK_PERIOD = 20;
    integer i;
    integer errors = 0;
    reg [31:0] IMM;

    initial clk = 0;
    always #(CPU_CLOCK_PERIOD/2) clk = ~clk;

    cpu cpu ( .clk (clk), .rst (rst) );

    task check_rf;
        input [4:0]  rd;
        input [31:0] expected;
        input [127:0] name;
        begin
            if (`REGFILE_PATH.Registers[rd] === expected)
                $display("  [PASS] %0s : x%0d = %0d (0x%h)", name, rd,
                         `REGFILE_PATH.Registers[rd], `REGFILE_PATH.Registers[rd]);
            else begin
                $display("  [FAIL] %0s : x%0d = 0x%h, expected 0x%h", name, rd,
                         `REGFILE_PATH.Registers[rd], expected);
                errors = errors + 1;
            end
        end
    endtask

    task check_mem;
        input [31:0] addr;
        input [31:0] expected;
        input [127:0] name;
        begin
            if (`DMEM_PATH.memory[addr[11:0]] === expected)
                $display("  [PASS] %0s : mem[0x%h] = 0x%h", name, addr,
                         `DMEM_PATH.memory[addr[11:0]]);
            else begin
                $display("  [FAIL] %0s : mem[0x%h] = 0x%h, expected 0x%h", name, addr,
                         `DMEM_PATH.memory[addr[11:0]], expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        rst = 1;
        for (i = 0; i < 32;   i = i + 1) `REGFILE_PATH.Registers[i] = 0;
        for (i = 0; i < 512;  i = i + 1) `DMEM_PATH.memory[i]       = 0;
        for (i = 0; i < 1024; i = i + 1) `IMEM_PATH.memory[i]       = 0;

        // addi x1, x0, 6
        `IMEM_PATH.memory[0]  = {12'd6, 5'd0, `FNC_ADD_SUB, 5'd1, `OPC_ARI_ITYPE};
        // addi x2, x0, 2
        `IMEM_PATH.memory[1]  = {12'd2, 5'd0, `FNC_ADD_SUB, 5'd2, `OPC_ARI_ITYPE};
        // add x4, x1, x2
        `IMEM_PATH.memory[2]  = {7'd0, 5'd2, 5'd1, `FNC_ADD_SUB, 5'd4, `OPC_ARI_RTYPE};
        // sw x4, 0x20(x0)   imm=0x20 -> imm[11:5]=7'b0000001, imm[4:0]=5'b00000
        `IMEM_PATH.memory[3]  = {7'b0000001, 5'd4, 5'd0, `FNC_SW, 5'b00000, `OPC_STORE};
        // lw x9, 0x20(x0)
        `IMEM_PATH.memory[4]  = {12'h020, 5'd0, `FNC_LW, 5'd9, `OPC_LOAD};
        // add x5, x9, x2
        `IMEM_PATH.memory[5]  = {7'd0, 5'd2, 5'd9, `FNC_ADD_SUB, 5'd5, `OPC_ARI_RTYPE};
        // add x11, x1, x2
        `IMEM_PATH.memory[6]  = {7'd0, 5'd2, 5'd1, `FNC_ADD_SUB, 5'd11, `OPC_ARI_RTYPE};
        // beq x4, x11, label  (label is 3 instructions ahead -> offset = 12 bytes)
        IMM = 32'd12;
        `IMEM_PATH.memory[7]  = {IMM[12], IMM[10:5], 5'd11, 5'd4, `FNC_BEQ, IMM[4:1], IMM[11], `OPC_BRANCH};
        // addi x9, x0, 2   (skipped by branch)
        `IMEM_PATH.memory[8]  = {12'd2, 5'd0, `FNC_ADD_SUB, 5'd9, `OPC_ARI_ITYPE};
        // addi x4, x0, 16  (skipped by branch)
        `IMEM_PATH.memory[9]  = {12'd16, 5'd0, `FNC_ADD_SUB, 5'd4, `OPC_ARI_ITYPE};
        // label: or x2, x9, x4
        `IMEM_PATH.memory[10] = {7'd0, 5'd4, 5'd9, `FNC_OR, 5'd2, `OPC_ARI_RTYPE};

        // Release reset
        repeat (2) @(posedge clk);
        rst = 0;

        // Run enough cycles to drain the pipeline (stall + branch included)
        repeat (50) @(posedge clk);

        $display("==== with_hazard results ====");
        check_rf(1,  32'd6,  "addi x1");
        check_rf(2,  32'd8,  "or   x2 = x9|x4 (final)");
        check_rf(4,  32'd8,  "add  x4 = x1+x2");
        check_rf(5,  32'd10, "add  x5 = x9+x2 (load-use)");
        check_rf(9,  32'd8,  "lw   x9 = mem[0x20]");
        check_rf(11, 32'd8,  "add  x11 = x1+x2");
        check_mem(32'h20, 32'd8, "sw   mem[0x20]");

        // Branch must be taken: the skipped 'addi x4, x0, 16' must NOT run,
        // so x4 stays 8 (already checked above) and x9 stays 8 (not overwritten to 2).
        if (errors == 0)
            $display("RESULT: with_hazard PASSED (forwarding + stall + branch all correct)");
        else
            $display("RESULT: with_hazard FAILED (%0d errors)", errors);
        $finish();
    end
endmodule
